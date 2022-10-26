//
//  RenderDataController.swift
//  MetalExperiments
//
//  Created by Alexander Zimin on 17/10/2022.
//

import MetalKit

struct Progress {
    var progress: Float
    
    init(progress: Float) {
        self.progress = progress
    }
}

struct Vertex {
    var position: vector_float2
    
    init(position: vector_float2) {
        self.position = vector_float2(position.x, position.y)
    }
    
    init() {
        self.position = .zero
    }
}

struct FragmentColor {
    var color: vector_float4
    
    init(uiColorFullAlpha: UIColor) {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        uiColorFullAlpha.getRed(&r, green: &g, blue: &b, alpha: &a)
        self.color = vector_float4(Float(r), Float(g), Float(b), 1)
    }
    
    init(uiColor: UIColor) {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        self.color = vector_float4(Float(r), Float(g), Float(b), Float(a))
    }
}

class RenderDataController {
    var indices: [UInt32] = []
    var vertices: [Vertex] = []
    var vertices2: [Vertex] = []
    var progresses: [Progress] = []
    
    var offset: UInt = 0
    
    func append(vertices: [Vertex], vertices2: [Vertex], isEnding: Bool) {
        var verticesData: [Vertex] = self.vertices
        var verticesData2: [Vertex] = self.vertices2
        var indicesData: [UInt32] = self.indices
        
        let offset = UInt32(indicesData.count)

//        if Float(verticesData.count) > 0.8 * Float(verticesData.capacity) {
//            verticesData.reserveCapacity(verticesData.capacity * 2)
//        }
        verticesData2.append(contentsOf: vertices2)
        verticesData.append(contentsOf: vertices)
//
//        if Float(indicesData.count) > 0.8 * Float(indicesData.capacity) {
//            indicesData.reserveCapacity(indices.capacity * 2)
//        }

        var newIndices: [UInt32] = []
        for i in 0..<vertices.count {
            newIndices.append(UInt32(i) + offset)
        }
        indicesData.append(contentsOf: newIndices)
        
        if verticesData2.count > 1650 {
            self.offset += UInt((verticesData2.count - 1650))
            let values = verticesData2[(verticesData2.count - 1650)..<verticesData2.count]
            verticesData2 = Array(values)
        }
        
        self.vertices = verticesData
        self.indices = indicesData
        self.vertices2 = verticesData2
    }
    
    func reset() {
        self.indices = []
        self.vertices = []
        self.vertices2 = []
        self.offset = 0
    }
    
    func reduceOffset() -> Bool {
        let verticesData2: [Vertex] = self.vertices2
        if verticesData2.count <= 165 {
            self.vertices2 = [self.vertices.last!]
            self.offset = UInt(self.vertices.count)
            return false
        }
        
        self.offset += 165
        self.vertices2 = Array(verticesData2[165..<verticesData2.count])
        return true
    }
}
