//
//  Renderer.swift
//  MetalExperiments
//
//  Created by Alexander Zimin on 17/10/2022.
//

import UIKit
import MetalKit

protocol RendererDelegate: NSObjectProtocol {
    func renderRequestedDateUpdate()
    func presentLine(texture: MTLTexture?, color: UIColor)
}

class Renderer: NSObject, MTKViewDelegate {
    struct VertexInfos {
        let width: Float
        let height: Float
        let offset: UInt32
    }
    
    let smapleCount = 4
    var mtkView: MTKView
    var dataController: RenderDataController
    weak var delegate: RendererDelegate?
    
    private var drawColor: UIColor = .white {
        didSet {
            self.updateColor()
        }
    }
    
    lazy var color: UIColor = self.drawColor {
        didSet {
            if self.isDrawInProgress == false {
                self.drawColor = self.color
            }
        }
    }
    
    private(set) var isDrawInProgress: Bool = false {
        didSet {
            if self.isDrawInProgress == false {
                self.drawColor = self.color
            }
        }
    }
    private var isEnding: Bool = false
    private var isEnded: Bool = false
    var isSaving: Bool = false
    
    private var device: MTLDevice!
    
    private var renderPipelineDescriptor: MTLRenderPipelineDescriptor
    private var renderPipelineState: MTLRenderPipelineState!
    private var commandQueue: MTLCommandQueue!
    
    private var verticesBuffer: MTLBuffer!
    private var verticesIndicesBuffer: MTLBuffer!
    
    private var verticesBuffer2: MTLBuffer!
    private var progressesBuffer: MTLBuffer!
    
    private var verticesInfosBuffer: MTLBuffer!
    private var fragmentInfosBuffer: MTLBuffer!
    
//    var imageFuncton
    
    init(mtkView: MTKView, dataController: RenderDataController) {
        self.mtkView = mtkView
        self.device = mtkView.device
        self.renderPipelineDescriptor = MTLRenderPipelineDescriptor()
        self.dataController = dataController
        
        super.init()
        
        mtkView.preferredFramesPerSecond = 120
        mtkView.framebufferOnly = false
        mtkView.sampleCount = self.smapleCount
    
        let library = self.device.makeDefaultLibrary()!
        self.renderPipelineDescriptor.vertexFunction = library.makeFunction(name: "draw_vertex")
        self.renderPipelineDescriptor.fragmentFunction = library.makeFunction(name: "draw_fragment")
        self.renderPipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm

        self.renderPipelineDescriptor.sampleCount = self.smapleCount
        
        do {
            self.renderPipelineState = try self.device.makeRenderPipelineState(descriptor: self.renderPipelineDescriptor)
        } catch let error as NSError {
            print("error: \(error.localizedDescription)")
        }
        
        mtkView.clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0)
        mtkView.layer.isOpaque = false
        
        self.commandQueue = self.device.makeCommandQueue()
        self.updateInfo(offset: 0)
        self.updateVertices(isEnding: false)
        self.updateColor()
        
        mtkView.delegate = self
    }
    
    var pipeline: MTLComputePipelineState!
    
    var currentRenderPassDescriptor: MTLRenderPassDescriptor!
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        updateInfo(offset: self.dataController.offset)
    }
    
    var count = 0
    var isEmpty = true
    
    var texture: MTLTexture?
    
    func draw(in view: MTKView) {
        if self.isSaving {
            return
        }
        
        if self.dataController.indices.count == 0 && self.isEmpty == true {
            OperationQueue.main.addOperation {
                self.delegate?.renderRequestedDateUpdate()
            }
            return
        }
        
        let verticesCommandBuffer = self.commandQueue.makeCommandBuffer()!
        self.currentRenderPassDescriptor = mtkView.currentRenderPassDescriptor!
        
        let verticesCommandEncoder = verticesCommandBuffer.makeRenderCommandEncoder(descriptor: self.currentRenderPassDescriptor)!
        
        if self.dataController.indices.count > 0 {
            self.isEmpty = false
            verticesCommandEncoder.setRenderPipelineState(self.renderPipelineState)
            verticesCommandEncoder.setVertexBuffer(self.verticesInfosBuffer, offset: 0, index: 0)
            verticesCommandEncoder.setVertexBuffer(self.verticesBuffer, offset: 0, index: 1)
            verticesCommandEncoder.setVertexBuffer(self.verticesBuffer2, offset: 0, index: 2)
            verticesCommandEncoder.setFragmentBuffer(self.fragmentInfosBuffer, offset: 0, index: 0)
            
            verticesCommandEncoder.drawIndexedPrimitives(
                type: .triangle,
                indexCount: self.dataController.indices.count,
                indexType: .uint32,
                indexBuffer: self.verticesIndicesBuffer,
                indexBufferOffset: 0
            )
        } else {
            self.isEmpty = true
        }
        
        verticesCommandEncoder.endEncoding()
        verticesCommandBuffer.present(view.currentDrawable!)
        var endTexture: MTLTexture?
        if self.isEnded {
            endTexture = view.currentDrawable?.texture
            self.isEnding = false
            self.isSaving = true
        }
        verticesCommandBuffer.commit()
        
        OperationQueue.main.addOperation {
            if let texture = endTexture {
                self.saveLine(texture: texture)
                self.isEnded = false
            }
            if self.isEnding == false && self.isEnded == false && self.isSaving == false {
                self.delegate?.renderRequestedDateUpdate()
            }
        }
    }
    
    func updateVertices(isEnding: Bool) {
        guard self.dataController.indices.count > 0 else { return }
        
        self.isDrawInProgress = true
        
        self.verticesIndicesBuffer = self.device.makeBuffer(
            bytes: self.dataController.indices,
            length: self.dataController.indices.count * MemoryLayout<UInt32>.stride,
            options: .storageModeShared
        )
        
        self.verticesBuffer = self.device.makeBuffer(
            bytes: self.dataController.vertices,
            length: self.dataController.vertices.count * MemoryLayout<Vertex>.stride,
            options: .storageModeShared
        )
        
        self.verticesBuffer2 = self.device.makeBuffer(
            bytes: self.dataController.vertices2,
            length: self.dataController.vertices2.count * MemoryLayout<Vertex>.stride,
            options: .storageModeShared
        )
        
        self.progressesBuffer = self.device.makeBuffer(
            bytes: self.dataController.vertices2,
            length: self.dataController.vertices2.count * MemoryLayout<Vertex>.stride,
            options: .storageModeShared
        )
        
        self.updateInfo(offset: self.dataController.offset)
        
        if isEnding {
            self.isEnding = true
            self.ending()
        }
    }
    
    func ending() {
        if self.dataController.reduceOffset() {
            self.updateVertices(isEnding: false)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01, execute: {
                self.ending()
            })
        } else {
            self.updateVertices(isEnding: false)
            self.isEnded = true
        }
    }
    
    private func updateColor() {
        var colorInfo = FragmentColor(uiColorFullAlpha: self.drawColor)
        self.mtkView.alpha = self.drawColor.alpha
        
        self.fragmentInfosBuffer = self.device.makeBuffer(
            bytes: &colorInfo,
            length: MemoryLayout<FragmentColor>.size,
            options: .storageModeShared
        )
    }
    
    private func updateInfo(offset: UInt) {
        var verticesInfos = VertexInfos(
            width: Float(self.mtkView.bounds.width),
            height: Float(self.mtkView.bounds.height),
            offset: UInt32(offset)
        )
        
        self.verticesInfosBuffer = self.device.makeBuffer(
            bytes: &verticesInfos,
            length: MemoryLayout<VertexInfos>.size,
            options: .storageModeShared
        )
    }
    
    private func saveLine(texture: MTLTexture?) {
        self.delegate?.presentLine(texture: texture, color: self.drawColor)
        self.dataController.reset()
        self.isDrawInProgress = false
    }
}

extension UIColor {
    var alpha: CGFloat {
        var a: CGFloat = 0
        self.getRed(nil, green: nil, blue: nil, alpha: &a)
        return a
    }
    
    var colorWithoutAlpha: UIColor {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        self.getRed(&r, green: &g, blue: &b, alpha: nil)
        return .init(red: r, green: g, blue: b, alpha: 1)
    }
}
