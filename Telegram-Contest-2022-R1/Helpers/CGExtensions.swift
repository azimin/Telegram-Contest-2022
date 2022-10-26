//
//  CGExtensions.swift
//  MetalExperiments
//
//  Created by Alexander Zimin on 14/10/2022.
//

import CoreGraphics
import MetalKit

extension Array {
    @inlinable public mutating func appendAndAllocateCapacityIfNeeded(_ newElement: Element) {
        if self.count == self.capacity {
            self.reserveCapacity(self.capacity *  2)
        }
        self.append(newElement)
    }
}

extension CGFloat {
    static func middleValue(start: CGFloat, end: CGFloat, progress: CGFloat) -> CGFloat {
        return start + (end - start) * progress
    }
}

extension CGPoint {
    @inline(__always)
    func toVectorFloat2() -> vector_float2 {
        return .init(x: Float(self.x), y: Float(self.y))
    }
    
    @inline(__always)
    func negative() -> CGPoint {
        return CGPoint(x: -self.x, y: -self.y)
    }
    
    @inline(__always)
    func add(_ another: CGPoint) -> CGPoint {
        return CGPoint(x: self.x + another.x, y: self.y + another.y)
    }
    
    @inline(__always)
    func subtract(_ another: CGPoint) -> CGPoint {
        return CGPoint(x: self.x - another.x, y: self.y - another.y)
    }
    
    @inline(__always)
    func multiply(_ value: CGFloat) -> CGPoint {
        return CGPoint(x: self.x * value, y: self.y * value)
    }
    
    @inline(__always)
    func midPoint(_ another: CGPoint) -> CGPoint {
        return self.add(another).multiply(0.5)
    }
    
    @inline(__always)
    func dot(_ another: CGPoint) -> CGFloat {
        return self.x * another.x + self.y * another.y
    }
    
    @inline(__always)
    func perpendicular() -> CGPoint {
        return CGPoint(x: -self.y, y: self.x)
    }
    
    @inline(__always)
    func length() -> CGFloat {
        return sqrt(self.dot(self))
    }
    
    @inline(__always)
    func distance(_ another: CGPoint) -> CGFloat {
        return self.subtract(another).length()
    }
    
    @inline(__always)
    func normalize() -> CGPoint {
        return self.multiply(1 / self.length())
    }
    
    func fuzzyEqual(_ another: CGPoint, epsilon: CGFloat) -> Bool {
        if abs(self.y - another.y) < epsilon && abs(self.x - another.x) < epsilon {
            return true
        }
        return false
    }
}
