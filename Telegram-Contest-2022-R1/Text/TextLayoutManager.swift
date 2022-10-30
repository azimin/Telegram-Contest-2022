//
//  TextStorage.swift
//  TextExperiment
//
//  Created by Alexander Zimin on 20/10/2022.
//

import UIKit

class TextLayoutManager: NSLayoutManager {
    weak var textView: UITextView?
    weak var backgroundView: TextBackgroundView?
    
    var backgroundColor: UIColor? {
        didSet {
            self.refreshBackground()
        }
    }
    
    struct FrameObject {
        var frame: CGRect
        var isSpace: Bool
    }
    
    func refreshBackground() {
        if self.textView?.text.isEmpty == true {
            self.backgroundView?.update(path: UIBezierPath(), color: self.backgroundColor ?? .clear)
            return
        }
        
        if self.backgroundColor == nil {
            self.backgroundView?.update(path: UIBezierPath(), color: self.backgroundColor ?? .clear)
            return
        }
        
        var frames: [[CGRect]] = []
        var currentFrames: [CGRect] = []
        let radius: CGFloat = (textView?.font?.pointSize ?? 30) / 4.25
        
        let text = (self.textView?.text ?? "") as NSString
        self.enumerateLineFragments(forGlyphRange: NSMakeRange(0, text.length)) { rect, usedRect, textContainer, glyphRange, stop in
            var rect = usedRect
            rect.origin.x += 16
            rect.origin.y += (self.textView?.textContainerInset.top ?? 0)
            
            if glyphRange.length == 1 && text.substring(from: glyphRange.location).first?.isNewline == true {
                if currentFrames.count > 0 {
                    frames.append(currentFrames)
                    currentFrames.removeAll()
                }
            } else {
                rect.origin.x -= radius
                rect.size.width += radius * 2
                currentFrames.append(rect)
            }
        }
        if currentFrames.count > 0 {
            frames.append(currentFrames)
        }
        
        if frames.count == 0 {
            return
        }
        
        for (index, framesGroup) in frames.enumerated() {
            if framesGroup.count == 0 {
                continue
            }
            
            var frame = framesGroup[0]
            frame.origin.y -= radius / 2
            frame.size.height += radius
            frames[index][0] = frame
            
            if framesGroup.count > 1 {
                for i in 1..<framesGroup.count {
                    var frame = framesGroup[i]
                    frame.size.height += radius / 2
                    frames[index][i] = frame
                }
            }
        }
        
        let path = UIBezierPath()
        
        var processed: [FrameInfo] = []
        for framesGroup in frames {
            processed.append(contentsOf: self.processGroupOfFrames(frames: framesGroup, radius: radius * 2))
        }
        
        for value in processed {
            path.append(.init(roundedRect: value.frame, byRoundingCorners: value.corners, cornerRadii: CGSize(width: radius, height: radius)))
            if let topLeftXCorner = value.topLeftXCorner {
                let corner = UIBezierPath()
                let x = topLeftXCorner.xPosition + radius
                var y = value.frame.origin.y
                let delta = topLeftXCorner.isInner ? radius * 1.5 : -radius
                y += delta
                
                if topLeftXCorner.isInner {
                    corner.addArc(withCenter: CGPoint(x: x, y: y), radius: radius, startAngle: .pi * 1.5, endAngle: .pi, clockwise: false)
                    corner.addLine(to: CGPoint(x: x - radius, y: y - radius))
                    corner.addLine(to: CGPoint(x: x, y: y - radius))
                } else {
                    corner.addArc(withCenter: CGPoint(x: x, y: y), radius: radius, startAngle: .pi, endAngle: .pi * 0.5, clockwise: false)
                    corner.addLine(to: CGPoint(x: x - radius, y: y - delta))
                    corner.addLine(to: CGPoint(x: x - radius, y: y))
                }
                
                path.append(corner)
            }
            
            if let topRightXCorner = value.topRightXCorner {
                let corner = UIBezierPath()
                let x = topRightXCorner.xPosition - radius
                var y = value.frame.origin.y
                let delta = topRightXCorner.isInner ? radius * 1.5 : -radius
                y += delta
                
                if topRightXCorner.isInner {
                    corner.addArc(withCenter: CGPoint(x: x, y: y), radius: radius, startAngle: 0, endAngle: .pi * 1.5, clockwise: false)
                    corner.addLine(to: CGPoint(x: x + radius, y: y - radius))
                    corner.addLine(to: CGPoint(x: x + radius, y: y))
                } else {
                    corner.addArc(withCenter: CGPoint(x: x, y: y), radius: radius, startAngle: .pi * 0.5, endAngle: 0, clockwise: false)
                    corner.addLine(to: CGPoint(x: x + radius, y: y + radius))
                    corner.addLine(to: CGPoint(x: x, y: y + radius))
                }
                
                path.append(corner)
            }
        }
        
        self.backgroundView?.update(path: path, color: self.backgroundColor ?? .clear)
    }
    
    class FrameInfo: CustomStringConvertible {
        struct CornerInfo {
            var xPosition: CGFloat
            var isInner: Bool
        }
        var frame: CGRect
        var corners: UIRectCorner
        var topLeftXCorner: CornerInfo?
        var topRightXCorner: CornerInfo?
        
        init(frame: CGRect, corners: UIRectCorner, topLeftXCorner: CornerInfo? = nil, topRightXCorner: CornerInfo? = nil) {
            self.frame = frame
            self.corners = corners
            self.topLeftXCorner = topLeftXCorner
            self.topRightXCorner = topRightXCorner
        }
        
        var description: String {
            return "frame: \(self.frame), corners: \(self.corners), topLeftXCorner: \(topLeftXCorner ?? .init(xPosition: 0, isInner: false)), topRightXCorner: \(topRightXCorner ?? .init(xPosition: 0, isInner: false))\n"
        }
    }
    
    func processGroupOfFrames(frames: [CGRect], radius: CGFloat) -> [FrameInfo] {
        var result: [FrameInfo] = []
        let framesCombined: [CGRect] = TextLayoutManager.combineFrames(frames: frames, radius: radius, textAligment: self.textView?.textAlignment ?? .center)
        
        if framesCombined.count == 0 {
            return []
        }
        
        if framesCombined.count == 1 {
            return [
                .init(frame: framesCombined[0], corners: [.allCorners])
            ]
        }
        
        var preveousObject: FrameInfo?
        
        for i in 0..<(framesCombined.count - 1) {
            let first = framesCombined[i]
            let second = framesCombined[i + 1]
            
            let firstObject = preveousObject ?? FrameInfo(
                frame: first,
                corners: [],
                topLeftXCorner: nil,
                topRightXCorner: nil
            )
            result.append(firstObject)
            
            let secondObject = FrameInfo(
                frame: second,
                corners: [],
                topLeftXCorner: nil,
                topRightXCorner: nil
            )
            
            if i == 0 {
                firstObject.corners = [firstObject.corners, .topRight, .topLeft]
            }
            
            if i == framesCombined.count - 2 {
                secondObject.corners = [secondObject.corners, .bottomLeft, .bottomRight]
            }
            
            if second.origin.x.semiequal(first.origin.x) {
                
            } else if second.origin.x < first.origin.x {
                secondObject.corners = [secondObject.corners, .topLeft]
                secondObject.topRightXCorner = .init(xPosition: first.origin.x, isInner: false)
            } else if second.origin.x > first.origin.x {
                firstObject.corners = [firstObject.corners, .bottomLeft]
                secondObject.topRightXCorner = .init(xPosition: second.origin.x, isInner: true)
            }
            
            if second.maxX.semiequal(first.maxX) {
                
            } else if second.maxX < first.maxX {
                firstObject.corners = [firstObject.corners, .bottomRight]
                secondObject.topLeftXCorner = .init(xPosition: second.maxX, isInner: true)
            } else if second.maxX > first.maxX {
                secondObject.corners = [secondObject.corners, .topRight]
                secondObject.topLeftXCorner = .init(xPosition: first.maxX, isInner: false)
            }
            
            preveousObject = secondObject
        }
        result.append(preveousObject!)
        return result
    }
    
    static func combineFrames(frames: [CGRect], radius: CGFloat, textAligment: NSTextAlignment) -> [CGRect] {
        var frames = frames
        var isFrameChanged = false
        
        for i in 0..<(frames.count - 1) {
            var first = frames[i]
            var second = frames[i + 1]
            
            switch textAligment {
            case .center:
                let delta = abs(first.origin.x - second.origin.x)
                
                if delta < radius && delta > 0 {
                    let maxWidth = max(first.size.width, second.size.width)
                    let minOrigin = min(first.origin.x, second.origin.x)
                    
                    first.size.width = maxWidth
                    second.size.width = maxWidth
                    
                    first.origin.x = minOrigin
                    second.origin.x = minOrigin
                    
                    isFrameChanged = true
                }
            case .left:
                let delta = abs(first.size.width - second.size.width)
                
                if delta < radius && delta > 0 {
                    let maxWidth = max(first.size.width, second.size.width)
                    
                    first.size.width = maxWidth
                    second.size.width = maxWidth
                    
                    isFrameChanged = true
                }
            case .right:
                let delta = abs(first.origin.x - second.origin.x)
                
                if delta < radius && delta > 0 {
                    let minOrigin = min(first.origin.x, second.origin.x)
                    let maxWidth = max(first.size.width, second.size.width)
                    
                    first.size.width = maxWidth
                    second.size.width = maxWidth
                    
                    first.origin.x = minOrigin
                    second.origin.x = minOrigin
                    
                    isFrameChanged = true
                }
            default:
                break
            }
            
            frames[i] = first
            frames[i + 1] = second
        }
        
        if isFrameChanged {
            frames = self.combineFrames(frames: frames, radius: radius, textAligment: textAligment)
        }
        
        return frames
    }
    
//    func getCornersInfo(frames: [FrameObject], index: Int, spaceNeeded: Bool) -> UIRectCorner {
//
//    }
    
    func updateFrame(frame: CGRect) -> CGRect {
        var frame = frame
        frame.origin.x -= 8
        frame.origin.y -= 4
        frame.size.width += 16
        frame.size.height += 8
        return frame
    }
}

extension CGFloat {
    func semiequal(_ another: CGFloat) -> Bool {
        return abs(self - another) < 0.001
    }
}
