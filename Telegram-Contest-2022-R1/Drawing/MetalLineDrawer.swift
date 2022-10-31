//
//  LineDrawer.swift
//  MetalExperiments
//
//  Created by Alexander Zimin on 17/10/2022.
//

import UIKit

struct MetalLinePoint {
    var pos: CGPoint
    var width: CGFloat
}

protocol MetalLineDrawerDelegate: NSObjectProtocol {
    func draw(vertices: [Vertex], vertices2: [Vertex], isEnding: Bool)
}

// I used https://www.merowing.info/drawing-smooth-lines-with-cocos2d-ios-inspired-by-paper/ as source of insperation
class MetalLineDrawer: UIView {
    struct PenSize {
        var minSize: CGFloat
        var maxSize: CGFloat
        var sizeEffect: CGFloat
        
        init(minSize: CGFloat, maxSize: CGFloat, sizeEffect: CGFloat) {
            self.minSize = minSize
            self.maxSize = maxSize
            self.sizeEffect = sizeEffect
        }
        
        func findMiddle(anotherPen: PenSize, width: CGFloat, lowerBound: CGFloat, upperBound: CGFloat) -> PenSize {
            let progress = (width - lowerBound) / (upperBound - lowerBound)
            let minSize = CGFloat.middleValue(start: self.minSize, end: anotherPen.minSize, progress: progress)
            let maxSize = CGFloat.middleValue(start: self.maxSize, end: anotherPen.maxSize, progress: progress)
            let sizeEffect = CGFloat.middleValue(start: self.sizeEffect, end: anotherPen.sizeEffect, progress: progress)
            return PenSize(minSize: minSize, maxSize: maxSize, sizeEffect: sizeEffect)
        }
        
        static func penWith(width: CGFloat) -> PenSize {
            if width < 0.25 {
                let first = PenSize(minSize: 0.4, maxSize: 1, sizeEffect: 2.6)
                let second = PenSize(minSize: 3, maxSize: 5, sizeEffect: 2.4)
                return first.findMiddle(anotherPen: second, width: width, lowerBound: 0, upperBound: 0.25)
            } else if width < 0.65 {
                let first = PenSize(minSize: 3, maxSize: 5, sizeEffect: 2.4)
                let second = PenSize(minSize: 10, maxSize: 18, sizeEffect: 1.6)
                return first.findMiddle(anotherPen: second, width: width, lowerBound: 0.25, upperBound: 0.65)
            } else if width < 1.0 {
                let first = PenSize(minSize: 10, maxSize: 18, sizeEffect: 1.6)
                let second = PenSize(minSize: 16.125, maxSize: 29.375, sizeEffect: 1.25)
                return first.findMiddle(anotherPen: second, width: width, lowerBound: 0.65, upperBound: 1)
            } else {
                return PenSize(minSize: 16.125, maxSize: 29.375, sizeEffect: 1.25)
            }
        }
        
        static var basic: PenSize {
            // 25%
            return PenSize(minSize: 10, maxSize: 18, sizeEffect: 2.5)
        }
    }
    
    var penSize: PenSize = .basic
    
    weak var delegate: MetalLineDrawerDelegate?
    
    var points: [MetalLinePoint] = []
    var velocities: [CGFloat] = []
    var circlesPoints: [MetalLinePoint] = []
    
    var connectingLine = false
    
    class TakeValues {
        var prevC: CGPoint = .zero
        var prevD: CGPoint = .zero
    }
    
    var takeValuesCache1: TakeValues = .init()
    var takeValuesCache2: TakeValues = .init()
    
    var sizeEffectCoef: CGFloat = 3
    
    private var finishingLine = false
    private var isEnding = false
    
    var gesture: UIPanGestureRecognizer!
    var tapGesture: UITapGestureRecognizer!
    
    weak var editToolsbarView: EditToolbarView?
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.handlePanGesture))
        panGestureRecognizer.maximumNumberOfTouches = 1
        self.addGestureRecognizer(panGestureRecognizer)
        self.gesture = panGestureRecognizer
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleTapGesture))
        self.addGestureRecognizer(tapGestureRecognizer)
        self.tapGesture = tapGestureRecognizer
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let location = gestureRecognizer.location(in: self)
        let window = UIApplication.shared.windows.first
        let offset = (window?.safeAreaInsets.bottom ?? 0) + 136
        
        if location.y > (self.frame.height - offset) {
            return false
        }
        
        if gestureRecognizer == self.tapGesture && self.editToolsbarView?.toolsState != .drawSpecificTools {
            if TextGestureController.shared.textViewByTap(gesture: self.tapGesture, includingFrame: false) != nil {
                TextGestureController.shared.drawTapGesture(self.tapGesture)
                NotificationSystem.shared.fireEvent(.selectTextTab)
                return false
            }
        }
        return ToolbarSettings.shared.selectedTool == .pen
    }
    
    @objc
    func handleTapGesture(gesture: UITapGestureRecognizer) {
        let point = gesture.location(in: self)
        self.points.removeAll(keepingCapacity: true)
        self.velocities.removeAll(keepingCapacity: true)
        self.penSize = PenSize.penWith(width: ToolbarSettings.shared.getToolSetting(style: .pen).widthProgress)
        self.sizeEffectCoef = self.penSize.sizeEffect
        
        let size = self.penSize.minSize
        
        self.connectingLine = false
        self.addPoint(point, size: size)
        self.addPoint(point, size: size)
        self.addPoint(point, size: size)
        self.addPoint(CGPoint(x: point.x + 0.01, y: point.y + 0.01), size: size)
        self.finishingLine = true
        self.isEnding = true
    }
    
    @objc
    func handlePanGesture(gesture: UIPanGestureRecognizer) {
        let point = gesture.location(in: self)
        
        switch gesture.state {
        case .began:
            self.points.removeAll(keepingCapacity: true)
            self.velocities.removeAll(keepingCapacity: true)
            
            self.penSize = PenSize.penWith(width: ToolbarSettings.shared.getToolSetting(style: .pen).widthProgress)
            self.sizeEffectCoef = self.penSize.sizeEffect
            
            let point = gesture.location(in: self)
            let size = self.calculateSize(gesture: gesture)
            
            self.connectingLine = false
            self.addPoint(point, size: size)
            self.addPoint(point, size: size)
            self.addPoint(point, size: size)
        case .changed:
            let size = self.calculateSize(gesture: gesture)
            let eps: CGFloat = 1.5
            if (self.points.count > 0) {
                let length = self.points.last!.pos.subtract(point).length()
                if (length < eps) {
                    return
                }
            }
            self.addPoint(point, size: size)
        case .ended, .cancelled, .failed:
            let size = self.calculateSize(gesture: gesture)
            self.addPoint(point, size: size)
            self.finishingLine = true
            self.isEnding = true
        default:
            break
        }
    }
    
    func addPoint(_ point: CGPoint, size: CGFloat) {
        let point = MetalLinePoint(pos: point, width: size)
        self.points.append(point)
    }
    
    func calculateSize(gesture: UIPanGestureRecognizer) -> CGFloat {
        var size: CGFloat = 0
        let velocity = gesture.velocity(in: self).length()
        var speed = velocity / 170
        speed = min(max(0, speed), 6)
        speed = speed / 6
        size = self.penSize.minSize + (self.penSize.maxSize - self.penSize.minSize) * speed
        size = size * 0.2 + (self.velocities.last ?? size) * 0.8
        
        self.velocities.append(size)
        
        return size
    }
    
    func doDrawing() {
        let smoothPoints = calculateSmoothLinePoints(points: self.points)
        if self.points.count > 2 {
            points.removeSubrange(0..<(points.count - 2))
        }
        
        if smoothPoints.count > 1 {
            self.drawLines(linePoints: smoothPoints)
        }
    }
    
    // Drawing
    
    func calculateSmoothLinePoints(points: [MetalLinePoint]) -> [MetalLinePoint] {
        if points.count < 3 {
            return []
        }
        
        var smoothedPoints: [MetalLinePoint] = .init()
        smoothedPoints.reserveCapacity(10)
        
        for i in 2..<points.count {
            let prev2 = points[i - 2]
            let prev1 = points[i - 1]
            let cur = points[i]
            
            let midPoint1 = prev1.pos.midPoint(prev2.pos)
            let midPoint2 = cur.pos.midPoint(prev1.pos)
            
            let segmentDistance: CGFloat = 2
            let distance = midPoint1.distance(midPoint2)
            let numberOfSegments = min(64, max(floor(distance / segmentDistance), 16))
            
            var t: CGFloat = 0
            let step = 1 / numberOfSegments
            for _ in 0..<Int(numberOfSegments) {
                let posBeg = midPoint1.multiply(pow(1 - t, 2))
                let posMid = prev1.pos.multiply(2 * (1 - t) * t)
                let posEnd = midPoint2.multiply(t * t)
                let position = posBeg.add(posMid).add(posEnd)
                
                let width = pow(1 - t, 2) * ((prev1.width + prev2.width) * 0.5) + 2.0 * (1 - t) * t * prev1.width + t * t * ((cur.width + prev1.width) * 0.5)
                
                let newPoint = MetalLinePoint(pos: position, width: width)
                smoothedPoints.appendAndAllocateCapacityIfNeeded(newPoint)
                
                t += step
            }
            
            let finalPoint = MetalLinePoint(
                pos: midPoint2,
                width: (cur.width + prev1.width) * 0.5
            )
            smoothedPoints.appendAndAllocateCapacityIfNeeded(finalPoint)
        }
        
        return smoothedPoints
    }
    
    func drawLines(linePoints: [MetalLinePoint]) {
        let mainVertices = self.calculateVertices(linePoints: linePoints, widthCoef: 1, shouldDoMainCirclesPoints: true, takeValuesCache: self.takeValuesCache1)
        let addedVertices = self.calculateVertices(linePoints: linePoints, widthCoef: self.sizeEffectCoef, shouldDoMainCirclesPoints: false, takeValuesCache: self.takeValuesCache2)
        
        self.fillLineTriangles(vertices: mainVertices.0, vertices2: addedVertices.0)
        
        if mainVertices.1 > 0 {
            connectingLine = true
        }
    }
    
    func calculateVertices(linePoints: [MetalLinePoint], widthCoef: CGFloat, shouldDoMainCirclesPoints: Bool, takeValuesCache: TakeValues) -> ([Vertex], Int) {
        let numberOfVertices = (linePoints.count - 1) * 18
        
        var vertices: [Vertex] = .init(repeating: .init(), count: numberOfVertices)
        
        var prevPoint = linePoints[0].pos
        var prevValue = linePoints[0].width * widthCoef
        var curValue: CGFloat = 0
        var index = 0
        
        for i in 1..<linePoints.count {
            let pointValue = linePoints[i]
            let curPoint = pointValue.pos
            curValue = pointValue.width * widthCoef
            
            if curPoint.fuzzyEqual(prevPoint, epsilon: 0.0001) {
                continue
            }
            
            let dir = curPoint.subtract(prevPoint)
            let perpendicular = dir.perpendicular().normalize()
            var a = prevPoint.add(perpendicular.multiply(prevValue / 2))
            var b = prevPoint.subtract(perpendicular.multiply(prevValue / 2))
            let c = curPoint.add(perpendicular.multiply(curValue / 2))
            let d = curPoint.subtract(perpendicular.multiply(curValue / 2))
            
            if self.connectingLine || index > 0 {
                a = takeValuesCache.prevC
                b = takeValuesCache.prevD
            } else {
                if shouldDoMainCirclesPoints {
                    self.circlesPoints.append(pointValue)
                    self.circlesPoints.append(linePoints[i - 1])
                }
            }
            
            index = vertices.addTriagnle(a, b, c, index: index)
            index = vertices.addTriagnle(b, c, d, index: index)
            
            takeValuesCache.prevD = d
            takeValuesCache.prevC = c
            
            if self.finishingLine && i == linePoints.count - 1 && shouldDoMainCirclesPoints {
                circlesPoints.append(linePoints[i - 1])
                circlesPoints.append(pointValue)
                self.finishingLine = false
            }
            
            prevPoint = curPoint
            prevValue = curValue
        }
        
        vertices = Array(vertices[0..<index])
        return (vertices, index)
    }
    
    func fillLineTriangles(vertices: [Vertex], vertices2: [Vertex]) {
        if (vertices.isEmpty) {
            return
        }
        
        var circlePoints: [Vertex] = []
        var circlePoints2: [Vertex] = []
        
        for i in 0..<(self.circlesPoints.count / 2) {
            let prevPoint = self.circlesPoints[i * 2]
            let curPoint = self.circlesPoints[i * 2 + 1]
            let dirVector = curPoint.pos.subtract(prevPoint.pos).normalize()
            let cornerVertices = self.generateLineEnd(center: curPoint.pos, direction: dirVector, radius: curPoint.width * 0.5)
            circlePoints.append(contentsOf: cornerVertices)
        }
        
        for i in 0..<(self.circlesPoints.count / 2) {
            let prevPoint = self.circlesPoints[i * 2]
            let curPoint = self.circlesPoints[i * 2 + 1]
            let dirVector = curPoint.pos.subtract(prevPoint.pos).normalize()
            let cornerVertices = self.generateLineEnd(center: curPoint.pos, direction: dirVector, radius: curPoint.width * 0.5 * self.sizeEffectCoef)
            circlePoints2.append(contentsOf: cornerVertices)
        }
        
        if circlePoints.count > 0 {
            self.delegate?.draw(vertices: vertices + circlePoints, vertices2: vertices2 + circlePoints2, isEnding: self.isEnding)
        } else {
            self.delegate?.draw(vertices: vertices, vertices2: vertices2, isEnding: self.isEnding)
        }
        
        self.isEnding = false
        self.circlesPoints.removeAll(keepingCapacity: true)
    }
    
    func generateLineEnd(center: CGPoint, direction: CGPoint, radius: CGFloat) -> [Vertex] {
        let numberOfSegments = 32
        var vertices: [Vertex] = .init(repeating: .init(), count: numberOfSegments * 6)
        let anglePerSegment = CGFloat.pi / CGFloat(numberOfSegments - 1)
        let perpendicular = direction.perpendicular()
        var angle = acos(perpendicular.dot(.init(x: 0, y: 1)))
        let rightDot = perpendicular.dot(.init(x: 1, y: 0))
        if rightDot < 0 {
            angle *= -1
        }
        
        var prevPoint = center
        
        for i in 0..<numberOfSegments {
            let dir = CGPoint(x: sin(angle), y: cos(angle))
            let curPoint = CGPoint(
                x: center.x + radius * dir.x,
                y: center.y + radius * dir.y
            )
            vertices[i * 6].position = center.toVectorFloat2()
            vertices[i * 6 + 1].position = prevPoint.toVectorFloat2()
            vertices[i * 6 + 2].position = curPoint.toVectorFloat2()
            vertices[i * 6 + 3].position = prevPoint.toVectorFloat2()
            vertices[i * 6 + 4].position = prevPoint.toVectorFloat2()
            vertices[i * 6 + 5].position = curPoint.toVectorFloat2()

            prevPoint = curPoint
            angle += anglePerSegment
        }
        
        return vertices
    }
}

fileprivate extension Array where Element == Vertex {
    @inline(__always)
    mutating func addTriagnle(_ a: CGPoint, _ b: CGPoint, _ c: CGPoint, index: Int) -> Int {
        self[index].position = .init(x: Float(a.x), y: Float(a.y))
        self[index + 1].position = .init(x: Float(b.x), y: Float(b.y))
        self[index + 2].position = .init(x: Float(c.x), y: Float(c.y))
        return index + 3
    }
}
