//
//  OpacitySelectView.swift
//  Telegram-Contest-2022-R1
//
//  Created by Alexander Zimin on 30/10/2022.
//

import UIKit

class OpacitySelectView: View {
    let backgroundImage = UIImageView(image: UIImage(named: "color_opacity_bg"))
    let backgroundView = UIView()
    
    var tumblerView = UIView()
    
    var progressUpdated: ProgressBlock?
    
    let overlayColorShape = CAGradientLayer()
    
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
    
    func setColor(color: UIColor) {
        self.tumblerView.backgroundColor = color
        CATransaction.begin()
        CATransaction.setValue(true, forKey: kCATransactionDisableActions)
        self.overlayColorShape.colors = [color.withAlphaComponent(0).cgColor, color.cgColor]
        self.overlayColorShape.locations = [0, 1]
        self.overlayColorShape.startPoint = CGPoint(x: 0, y: 0.5)
        self.overlayColorShape.endPoint = CGPoint(x: 1, y: 0.5)
        CATransaction.commit()
    }
    
    override func setUp() {
        self.addSubview(self.backgroundView)
        self.backgroundView.layer.cornerRadius = 18
        self.backgroundView.layer.masksToBounds = true
        self.addSubview(self.tumblerView)
        
        self.backgroundView.addSubview(self.backgroundImage)
        self.backgroundView.layer.addSublayer(self.overlayColorShape)
        
        self.tumblerView.layer.cornerRadius = 16
        self.tumblerView.backgroundColor = .white
        
        self.tumblerView.layer.borderWidth = 3
        self.tumblerView.layer.borderColor = UIColor.black.cgColor
        
        self.tumblerView.backgroundColor = UIColor.white
    }
    
    override func layoutSubviewsOnChangeBounds() {
        self.backgroundView.frame = self.bounds
        let width = self.bounds.height * 11
        self.backgroundImage.frame = CGRect(x: 0, y: 0, width: width, height: self.bounds.height)
        self.overlayColorShape.frame = self.bounds
        
        self.updateTumblerFrame()
    }
    
    private func updateTumblerFrame() {
        let originX = self.calculateOriginX()
        self.tumblerView.frame = CGRect(x: originX, y: 2, width: 32, height: 32)
    }
    
    var preveousLocationX: CGFloat = 0
    
    func gestureUpdated(gesture: UIPanGestureRecognizer) {
        if gesture.state == .began {
            let locationX = gesture.location(in: self).x
            self.preveousLocationX = locationX
        }
            
        if gesture.state == .changed || gesture.state == .ended || gesture.state == .cancelled {
            let locationX = gesture.location(in: self).x
            let delta = locationX - self.preveousLocationX
            
            self.moveTumbler(on: delta)
            
            self.preveousLocationX = locationX
        }
    }
    
    private func moveTumbler(on: CGFloat) {
        var currentX = self.tumblerView.frame.origin.x
        currentX += on
        
        currentX = max(currentX, 2)
        currentX = min(currentX, self.frame.width - 34)
        
        self.tumblerView.frame.origin.x = currentX
        
        self.calculateProgress()
    }
    
    private func calculateProgress() {
        let progress = (self.tumblerView.frame.origin.x - 2) / (self.frame.width - 36)
        self.progress = progress
    }
    
    private func calculateOriginX() -> CGFloat {
        let originX = self.progress * (self.frame.width - 36) + 2
        return originX
    }
}
