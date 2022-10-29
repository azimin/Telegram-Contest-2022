//
//  MetalDrawingView.swift
//  Telegram-Contest-2022-R1
//
//  Created by Alexander Zimin on 26/10/2022.
//

import UIKit
import MetalKit

protocol DrawMetalViewDelegate: NSObjectProtocol {
    func presentLine(texture: MTLTexture?, color: UIColor)
}

class DrawMetalView: UIView, RendererDelegate, MetalLineDrawerDelegate {
    weak var delegate: DrawMetalViewDelegate?
    
    var metalView: MTKView!
    var renderer: Renderer!
    
    var dataController = RenderDataController()
    let lineDrawer = MetalLineDrawer()
    
    let maskTopView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        self.maskTopView.backgroundColor = .black
        
        self.metalView = MTKView(frame: self.bounds, device: MTLCreateSystemDefaultDevice())
        self.addSubview(self.metalView)
        self.renderer = Renderer(mtkView: self.metalView, dataController: self.dataController)
        self.renderer.delegate = self
        
        self.addSubview(self.lineDrawer)
        self.lineDrawer.frame = self.bounds
        
        self.lineDrawer.delegate = self
    }
    
    // MARK: - RendererDelegate
    
    func renderRequestedDateUpdate() {
        self.lineDrawer.doDrawing()
    }
    
    func presentLine(texture: MTLTexture?, color: UIColor) {
        self.delegate?.presentLine(texture: texture, color: color)
    }
    
    // MARK: - MetalLineDrawerDelegate
    
    func draw(vertices: [Vertex], vertices2: [Vertex], isEnding: Bool) {
        if self.renderer.isDrawInProgress == false && vertices.count > 0 {
            self.renderer.color = ToolbarSettings.shared.getToolSetting(style: .fromTool(ToolbarSettings.shared.selectedTool)).color.color
        }
        self.dataController.append(vertices: vertices, vertices2: vertices2, isEnding: isEnding)
        self.renderer.updateVertices(isEnding: isEnding)
    }
    
    func updateMask(frame: CGRect) {
        self.maskTopView.frame = frame
        self.metalView.mask = self.maskTopView
    }
}
