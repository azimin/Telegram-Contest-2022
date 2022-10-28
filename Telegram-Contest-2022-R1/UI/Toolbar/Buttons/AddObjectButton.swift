//
//  AddButton.swift
//  Telegram-Contest-2022-R1
//
//  Created by Alexander Zimin on 11/10/2022.
//

import UIKit

class AddObjectButton: Button {
    enum State {
        case none
        case addShape
        case addText
    }
    
    var addShapeImageView = UIImageView(image: UIImage(named: "new_add_shape"))
    var addTextImageView = UIImageView(image: UIImage(named: "new_text_2"))
    
    private var visualState: State = .none
    
    override func setUp() {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.layer.cornerRadius = 33 / 2
        blurEffectView.layer.masksToBounds = true
        self.addSubview(blurEffectView)
        
        let ovalView = UIView()
        ovalView.backgroundColor = .white.withAlphaComponent(0.1)
        ovalView.frame = self.bounds
        ovalView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        ovalView.layer.cornerRadius = 33 / 2
        self.addSubview(ovalView)
        
        self.addSubview(self.addShapeImageView)
        self.addSubview(self.addTextImageView)
        
        
    }
    
    override func layoutSubviewsOnChangeBounds() {
        self.addShapeImageView.frame = self.bounds
        self.addTextImageView.frame = self.bounds
        
        if self.visualState == .none {
            self.updateState(state: .addShape, animated: false)
        }
    }
    
    func updateState(state: State, animated: Bool) {
        if state == self.visualState {
            return
        }
        self.visualState = state
        
        let inView: UIView
        let outView: UIView
        
        switch state {
        case .addShape, .none:
            inView = self.addShapeImageView
            outView = self.addTextImageView
        case .addText:
            inView = self.addTextImageView
            outView = self.addShapeImageView
        }
        
        let duration: TimeInterval = animated ? 0.25 : 0
        
        inView.layer.transform = CATransform3DMakeScale(0.5, 0.5, 1)
        inView.layer.opacity = 1

        if animated {
            inView.layer.animate(from: 0 as NSNumber, to: 0.5 as NSNumber, keyPath: "transform.scale", duration: duration)
            inView.layer.animate(from: 0  as NSNumber, to: 1 as NSNumber, keyPath: "opacity", duration: duration)
        }
        
        
        outView.layer.transform = CATransform3DMakeScale(0, 0, 1)
        outView.layer.opacity = 0
        
        if animated {
            outView.layer.animate(from: 0.5 as NSNumber, to: 0 as NSNumber, keyPath: "transform.scale", duration: duration)
            outView.layer.animate(from: 1  as NSNumber, to: 0 as NSNumber, keyPath: "opacity", duration: duration)
        }
    }
}
