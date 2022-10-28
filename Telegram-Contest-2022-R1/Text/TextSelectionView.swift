//
//  TextSelectionView.swift
//  TextExperiment
//
//  Created by Alexander Zimin on 24/10/2022.
//

import UIKit

class TextSelectionView: UIView {
    let shapeLayer = CAShapeLayer()
    let maskLayer = CAShapeLayer()
    
    let circleShapeLayer = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.addSublayer(self.shapeLayer)
        self.layer.addSublayer(self.circleShapeLayer)
        self.shapeLayer.mask = self.maskLayer
        self.isUserInteractionEnabled = false
        self.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        var length = self.bounds.width * 2 + self.bounds.height * 2
        length += (-12 * 4) + 6 * .pi * 2
        
        var potentialNumberOfLines = Int(length / 7)
        potentialNumberOfLines = potentialNumberOfLines % 2 == 0 ? potentialNumberOfLines : potentialNumberOfLines + 1
        let dash = length / CGFloat(potentialNumberOfLines)
        
        super.layoutSubviews()
        self.shapeLayer.frame = self.bounds
        self.maskLayer.frame = self.bounds
        self.circleShapeLayer.frame = self.bounds
        
        self.shapeLayer.lineWidth = 2
        self.shapeLayer.lineDashPattern = [dash as NSNumber, dash as NSNumber]
        self.shapeLayer.lineCap = .round
        self.shapeLayer.strokeColor = UIColor.white.cgColor
        self.shapeLayer.fillColor = UIColor.clear.cgColor
        
        let path = UIBezierPath()
        let height = (self.bounds.height - 10) / 2
        
        path.append(.init(rect: .init(x: -2, y: -2, width: self.bounds.width + 4, height: height + 2)))
        path.append(.init(rect: .init(x: -2, y: height + 10, width: self.bounds.width + 4, height: height + 2)))
        self.maskLayer.path = path.cgPath
        
        let circlePath = UIBezierPath()
        circlePath.append(.init(ovalIn: CGRect(x: -6, y: self.frame.height / 2 - 6, width: 12, height: 12)))
        circlePath.append(.init(ovalIn: CGRect(x: self.frame.width - 6, y: self.frame.height / 2 - 6, width: 12, height: 12)))
        
        self.circleShapeLayer.lineWidth = 2
        self.circleShapeLayer.path = circlePath.cgPath
        self.circleShapeLayer.fillColor = UIColor.clear.cgColor
        self.circleShapeLayer.strokeColor = UIColor.white.cgColor
        
        self.makeShape()
    }
    
    func makeShape() {
        let bezierPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: 12)
        bezierPath.lineCapStyle = .round
        self.shapeLayer.path = bezierPath.cgPath
    }
    
    enum Corner {
        case topLeft
        case bottomLeft
        case topRight
        case bottomRight
    }
}
