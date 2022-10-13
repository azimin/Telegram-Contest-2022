//
//  SizeSegmentShapes.swift
//  Telegram-Contest-2022-R1
//
//  Created by Alexander Zimin on 12/10/2022.
//

import Foundation

class SizeSegmentShape: CAShapeLayer {
    enum Style {
        case none
        case full
        case part
    }
    
    private var preveousRect: CGRect = .zero
    
    func animateTo(fromStyle: Style, toStyle: Style, fromRect: CGRect?, toRect: CGRect, duration: TimeInterval) {
        
        let oldPath = self.getPath(style: fromStyle, rect: fromRect ?? self.preveousRect)
        let oldColor = self.getColor(style: fromStyle).cgColor
        
        let newPath = self.getPath(style: toStyle, rect: toRect)
        let newColor = self.getColor(style: toStyle).cgColor
        
        self.preveousRect = toRect
        self.fillColor = newColor
        
        self.animate(from: oldPath, to: newPath, keyPath: "path", timingFunction: CAMediaTimingFunctionName.linear.rawValue, duration: duration)
        self.animate(from: oldColor, to: newColor, keyPath: "fillColor", timingFunction: CAMediaTimingFunctionName.linear.rawValue, duration: duration)
        
        self.path = newPath
    }
    
    private func getColor(style: Style) -> UIColor {
        switch style {
        case .none:
            return .clear
        case .full:
            return UIColor.white.withAlphaComponent(0.1)
        case .part:
            return UIColor.white.withAlphaComponent(0.2)
        }
    }
    
    private func getPath(style: Style, rect: CGRect) -> CGPath {
        switch style {
        case .none:
            return UIBezierPath().cgPath
        case .full:
            let path = UIBezierPath()
            let middle = frame.height / 2
            
            path.addArc(withCenter: .init(x: 16, y: middle), radius: 16, startAngle: .pi * 1.5, endAngle: .pi * 0.5, clockwise: false)
            path.addArc(withCenter: .init(x: rect.width - 16, y: middle), radius: 16, startAngle: .pi / 2, endAngle: .pi * 1.5, clockwise: false)
            
            return path.cgPath
        case .part:
            let path = UIBezierPath()
            
            path.addArc(withCenter: .init(x: 2.1, y: rect.height / 2), radius: 2.1, startAngle: .pi * 1.5, endAngle: .pi * 0.5, clockwise: false)
            path.addArc(withCenter: .init(x: rect.width - 11, y: rect.height / 2), radius: 11, startAngle: .pi / 2, endAngle: .pi * 1.5, clockwise: false)
            
            return path.cgPath
        }
    }
}
