//
//  TextBackgroundView.swift
//  TextExperiment
//
//  Created by Alexander Zimin on 27/10/2022.
//

import UIKit

class TextBackgroundView: UIView {
    let shapeLayer = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.addSublayer(shapeLayer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var color: UIColor = .clear {
        didSet {
            if color != oldValue {
                CATransaction.begin()
                CATransaction.setValue(true, forKey: kCATransactionDisableActions)
                self.shapeLayer.fillColor = color.cgColor
                CATransaction.commit()
            }
        }
    }
    
    var bezierPath: UIBezierPath = UIBezierPath() {
        didSet {
            if self.color == UIColor.clear {
                shapeLayer.path = UIBezierPath().cgPath
            } else {
                shapeLayer.path = bezierPath.cgPath
            }
        }
    }
    
    func update(path: UIBezierPath, color: UIColor) {
        self.color = color
        self.bezierPath = path
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.shapeLayer.frame = self.bounds
    }
}
