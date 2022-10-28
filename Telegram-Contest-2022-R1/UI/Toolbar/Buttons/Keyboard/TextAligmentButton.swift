//
//  TextAligmentButton.swift
//  Telegram-Contest-2022-R1
//
//  Created by Alexander Zimin on 28/10/2022.
//

import UIKit

class TextAligmentButton: Button {
    let alignState: NSTextAlignment = .left
    let shapeLayer: CAShapeLayer = CAShapeLayer()
    
    override func setUp() {
        self.layer.addSublayer(self.shapeLayer)
        self.shapeLayer.lineWidth = 2
        self.shapeLayer.lineCap = .round
        self.shapeLayer.strokeColor = UIColor.red.cgColor
    }
    
    override func layoutSubviewsOnChangeBounds() {
        self.shapeLayer.frame = self.bounds
        self.updateStyle(alignState: self.alignState, animated: false)
    }
    
    func updateStyle(alignState: NSTextAlignment, animated: Bool) {
        if !animated {
            self.shapeLayer.removeAllAnimations()
            self.shapeLayer.path = self.shapeBaseOnStyle(alignState: alignState).cgPath
            return
        }
        
        let newPath = self.shapeBaseOnStyle(alignState: alignState).cgPath
        self.shapeLayer.animateSpring(from: self.shapeLayer.path ?? newPath, to: newPath, keyPath: "path", duration: 0.65)
        self.shapeLayer.path = newPath
    }
    
    func shapeBaseOnStyle(alignState: NSTextAlignment) -> UIBezierPath {
        let path = UIBezierPath()
        let leftOffset = (self.bounds.width - 20.5) / 2
        let topOffset = (self.bounds.height - 17) / 2
        let step: CGFloat = 5
        var alignOffset: CGFloat = 0
        
        if alignState == .left {
            alignOffset = 0
        } else if alignState == .center {
            alignOffset = 3.75
        } else {
            alignOffset = 7.5
        }
        
        path.move(to: .init(x: leftOffset, y: topOffset))
        path.addLine(to: .init(x: leftOffset + 20.5, y: topOffset))
        
        path.move(to: .init(x: alignOffset + leftOffset, y: topOffset + step))
        path.addLine(to: .init(x: alignOffset + leftOffset + 13, y: topOffset + step))
        
        path.move(to: .init(x: leftOffset, y: topOffset + step * 2))
        path.addLine(to: .init(x: leftOffset + 20.5, y: topOffset + step * 2))
        
        path.move(to: .init(x: alignOffset + leftOffset, y: topOffset + step * 3))
        path.addLine(to: .init(x: alignOffset + leftOffset + 13, y: topOffset + step * 3))
        
        return path
    }
}
