//
//  TextLineAligmentView.swift
//  TextExperiment
//
//  Created by Alexander Zimin on 28/10/2022.
//

import UIKit

class TextLineAligmentView: UIView {
    static weak var shared: TextLineAligmentView? = nil
    
    let lineLayer = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isUserInteractionEnabled = false
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        self.lineLayer.lineDashPattern = [2, 1]
        self.lineLayer.strokeColor = UIColor.yellow.cgColor
        self.lineLayer.lineWidth = 1
        
        
        self.layer.addSublayer(self.lineLayer)
    }
    
    func updateVisibility(shouldShow: Bool) {
        self.lineLayer.isHidden = !shouldShow
    }
    
    func updatePositionY(_ positionY: CGFloat) {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: positionY))
        path.addLine(to: CGPoint(x: self.frame.width, y: positionY))
        
        self.lineLayer.path = path.cgPath
    }
}

//fileprivate class LineView: UIView {
//    var point: CGPoint = .zero {
//        didSet {
//            self.setNeedsDisplay()
//        }
//    }
//
//    override func draw(_ rect: CGRect) {
//        super.draw(rect)
//
//        let path = UIBezierPath()
//        path.move(to: CGPoint(x: 0, y: self.point.y))
//        path.addLine(to: CGPoint(x: self.frame.width, y: self.point.y))
//
//    }
//}
