//
//  SizeSegmentView.swift
//  Telegram-Contest-2022-R1
//
//  Created by Alexander Zimin on 12/10/2022.
//

import UIKit

class SizeSegmentView: View {
    enum Gestures {
        case enabled
        case disabled
        case delayed
    }
    
    var backgroundView = UIView()
    var tumblerView = UIView()
    
    let segmentShape = SizeSegmentShape()
    
    private(set) var progress: CGFloat = 0
    var gestures: Gestures = .disabled {
        didSet {
            self.isUserInteractionEnabled = self.gestures == .disabled ? false : true
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
    }
    
    override func layoutSubviewsOnChangeBounds() {
        self.backgroundView.frame = CGRect(x: 0, y: (self.frame.height - 26) / 2, width: self.frame.width, height: 26)
        self.segmentShape.frame = self.backgroundView.bounds
                
        self.updateTumblerFrame()
    }
    
    func animateIntoTumblerView(fromFrame: CGRect, toProgress: CGFloat, duration: TimeInterval) {
        self.gestures = .delayed
        
        self.progress = toProgress
        
        let originX = self.calculateOriginX()
        let newFrame = CGRect(x: originX, y: 0, width: 28, height: 28)
        
        let oldColor = self.tumblerView.layer.backgroundColor
        self.tumblerView.layer.backgroundColor = UIColor.white.cgColor
        
        self.tumblerView.frame = newFrame
        
        self.tumblerView.layer.animateFrame(from: fromFrame, to: newFrame, duration: duration, completion: {
            success in
            if (success) {
                self.gestures = .enabled
            }
        })
        self.tumblerView.layer.animate(from: oldColor, to: UIColor.white.cgColor, keyPath: "backgroundColor", duration: duration * 0.5)
    }
    
    func animateBackground(to: Bool, frame: CGRect, duration: TimeInterval) {
        if to {
            self.segmentShape.animateTo(fromStyle: .full, toStyle: .part, fromRect: frame, toRect: self.bounds, duration: duration)
        } else {
            self.segmentShape.animateTo(fromStyle: .part, toStyle: .full, fromRect: nil, toRect: frame, duration: duration)
        }
    }
    
    func animateFromTumblerView(toFrame: CGRect, duration: TimeInterval, completionBlock: VoidBlock?) {
        self.gestures = .disabled
        
        let oldColor = self.tumblerView.layer.backgroundColor
        self.tumblerView.layer.backgroundColor = UIColor.white.withAlphaComponent(0.3).cgColor
        
        let oldFrame = self.tumblerView.frame
        self.tumblerView.frame = toFrame
        
        self.tumblerView.layer.animateFrame(from: oldFrame, to: toFrame, duration: duration, completion: {
            success in
            if (success) {
                completionBlock?()
            }
        })
        self.tumblerView.layer.animate(from: oldColor, to: UIColor.white.withAlphaComponent(0.3).cgColor, keyPath: "backgroundColor", duration: duration * 0.5, delay: duration * 0.5)
    }
    
    private func updateTumblerFrame() {
        let originX = self.calculateOriginX()
        self.tumblerView.frame = CGRect(x: originX, y: 0, width: 28, height: 28)
    }
    
    var preveousLocationX: CGFloat = 0
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        guard let touch = touches.first else {
            return
        }
        
        let locationX = touch.location(in: self).x
        self.preveousLocationX = locationX
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        guard let touch = touches.first else {
            return
        }
        
        let locationX = touch.location(in: self).x
        let delta = locationX - self.preveousLocationX
        
        if self.gestures == .enabled {
            self.moveTumbler(on: delta)
        }
        
        self.preveousLocationX = locationX
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        guard let touch = touches.first else {
            return
        }
        
        let locationX = touch.location(in: self).x
        let delta = locationX - self.preveousLocationX
        if self.gestures == .enabled {
            self.moveTumbler(on: delta)
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
    }
    
    private func moveTumbler(on: CGFloat) {
        var currentX = self.tumblerView.frame.origin.x
        currentX += on
        
        currentX = max(currentX, 0)
        currentX = min(currentX, self.frame.width - 28)
        
        self.tumblerView.frame.origin.x = currentX
        
        self.calculateProgress()
    }
    
    private func calculateProgress() {
        let progress = self.tumblerView.frame.origin.x / (self.frame.width - 28)
        self.progress = progress
    }
    
    private func calculateOriginX() -> CGFloat {
        let originX = self.progress * (self.frame.width - 28)
        return originX
    }
}
