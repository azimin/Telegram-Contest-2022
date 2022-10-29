//
//  FontSizeView.swift
//  Telegram-Contest-2022-R1
//
//  Created by Alexander Zimin on 29/10/2022.
//

import UIKit

class FontSizeView: View {
    var backgroundView = UIView()
    var tumblerView = UIView()
    
    var progressUpdated: ProgressBlock?
    
    private let segmentShape = FontSizeSegmentShape()
    
    private(set) var progress: CGFloat = 0 {
        didSet {
            if oldValue != self.progress {
                progressUpdated?(progress)
            }
        }
    }
    
    func setProgress(value: CGFloat) {
        self.progress = value
        self.updateTumblerFrame()
    }
    
    override func setUp() {
        self.addSubview(self.backgroundView)
        self.addSubview(self.tumblerView)
        
        self.backgroundView.layer.addSublayer(self.segmentShape)
        
        self.tumblerView.layer.cornerRadius = 14
        self.tumblerView.backgroundColor = .white.withAlphaComponent(0.3)
        
        self.tumblerView.backgroundColor = UIColor.white
    }
    
    override func layoutSubviewsOnChangeBounds() {
        self.backgroundView.frame = CGRect(x: (self.frame.width - 26) / 2, y: 0, width: 26, height: self.frame.height)
        self.segmentShape.frame = self.backgroundView.bounds
                
        self.segmentShape.setRect(rect: self.bounds)
        
        self.updateTumblerFrame()
    }
    
    private func updateTumblerFrame() {
        let originX = self.calculateOriginY()
        self.tumblerView.frame = CGRect(x: 0, y: originX, width: 28, height: 28)
    }
    
    var preveousLocationY: CGFloat = 0
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        guard let touch = touches.first else {
            return
        }
        
        self.startEdit()
        let locationY = touch.location(in: self).y
        self.preveousLocationY = locationY
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        guard let touch = touches.first else {
            return
        }
        
        let locationY = touch.location(in: self).y
        let delta = locationY - self.preveousLocationY
        
        self.moveTumbler(on: delta)
        
        self.preveousLocationY = locationY
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        guard let touch = touches.first else {
            return
        }
        
        let locationY = touch.location(in: self).y
        let delta = locationY - self.preveousLocationY
        self.moveTumbler(on: delta)
        self.endEdit()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        self.endEdit()
    }
    
    private func moveTumbler(on: CGFloat) {
        var currentY = self.tumblerView.frame.origin.y
        currentY += on
        
        currentY = max(currentY, 0)
        currentY = min(currentY, self.frame.height - 28)
        
        self.tumblerView.frame.origin.y = currentY
        
        self.calculateProgress()
    }
    
    private func calculateProgress() {
        let progress = self.tumblerView.frame.origin.y / (self.frame.height - 28)
        self.progress = progress
    }
    
    private func calculateOriginY() -> CGFloat {
        let originY = self.progress * (self.frame.height - 28)
        return originY
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return bounds.insetBy(dx: -20, dy: 8).contains(point)
    }
    
    func startEdit() {
        let move: CGFloat = 22
        
        let translationX = self.layer.value(forKeyPath: "transform.translation.x") as? CGFloat ?? 0
        self.layer.transform = CATransform3DMakeTranslation(move, 0, 0)
        self.layer.animateSpring(from: translationX as NSNumber, to: move as NSNumber, keyPath: "transform.translation.x", duration: 0.6)
    }
    
    func endEdit() {
        let translationX = self.layer.value(forKeyPath: "transform.translation.x") as? CGFloat ?? 0
        self.layer.transform = CATransform3DMakeTranslation(0, 0, 0)
        self.layer.animateSpring(from: translationX as NSNumber, to: 0 as NSNumber, keyPath: "transform.translation.x", duration: 0.6)
    }
}

fileprivate class FontSizeSegmentShape: CAShapeLayer {
    func setRect(rect: CGRect) {
        self.fillColor = UIColor.white.withAlphaComponent(0.2).cgColor
        
        let path = UIBezierPath()
        
        path.addArc(withCenter: .init(x: rect.width / 2 - 1, y: rect.height - 2.1), radius: 2.1, startAngle: .pi, endAngle: 0, clockwise: false)
        path.addArc(withCenter: .init(x: rect.width / 2 - 1, y: 11), radius: 11, startAngle: 0, endAngle: .pi, clockwise: false)
        
        
        self.path = path.cgPath
    }
}

