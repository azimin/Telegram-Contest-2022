//
//  SendButton.swift
//  Telegram-Contest-2022-R1
//
//  Created by Alexander Zimin on 11/10/2022.
//

import UIKit
import Lottie

class SendButton: Button {
    enum Style {
        case arrow
        case circle
        case cross
        case blur
    }
    
    let contentImageView = UIImageView()
    let animationViewContrainer = UIView()
    let animationView = LottieAnimationView()
    
    override func setUp() {
        self.addSubview(self.contentImageView)
        self.contentImageView.image = UIImage(named: "download")
        self.addSubview(self.animationViewContrainer)
        self.animationViewContrainer.addSubview(self.animationView)
    }
    
    override func layoutSubviewsOnChangeBounds() {
        self.contentImageView.frame = self.bounds
        self.animationViewContrainer.frame = self.bounds
        self.animationView.frame = self.bounds
    }
    
    func animateIntoFrame(frame: CGRect = .zero, duration: TimeInterval, complited: VoidBlock?) {
        var frame = frame
        frame.origin.x *= 0.515
        frame.origin.y *= 0.515
        
        frame.origin.x += 0.7
        frame.origin.y -= 2
        
        self.contentImageView.isHidden = true
        self.animationView.isHidden = false
        let animation = LottieAnimation.named(
          "send_to_arrow",
          bundle: .main
        )
        self.animationView.animation = animation
        self.animationView.animationSpeed = 1.05 / duration
        
        self.animationView.play(fromFrame: 0, toFrame: (animation?.endFrame ?? 0) - 1) { success in
            if (success) {
                self.animationView.animation = nil
                complited?()
            }
        }
        
        self.animationViewContrainer.layer.transform = CATransform3DMakeScale(0.515, 0.515, 1)
        
        self.animationViewContrainer.layer.animateScale(from: 1, to: 0.515, duration: duration, removeOnCompletion: false)
        
        self.animationViewContrainer.layer.transform = CATransform3DMakeTranslation(frame.origin.x, frame.origin.y, 0)
        
        self.animationViewContrainer.layer.animate(from: 0 as NSNumber, to: frame.origin.x as NSNumber, keyPath: "transform.translation.x", duration: duration)
        self.animationViewContrainer.layer.animate(from: 0 as NSNumber, to: frame.origin.y as NSNumber, keyPath: "transform.translation.y", duration: duration)
    }
    
    func animateFromFrame(duration: TimeInterval) {
        self.contentImageView.isHidden = true
        self.animationView.isHidden = false
        let animation = LottieAnimation.named(
          "send_to_arrow_reverse",
          bundle: .main
        )
        self.animationView.animation = animation
        self.animationView.animationSpeed = 1.05 / duration
        
        self.animationView.play(fromFrame: 0, toFrame: (animation?.endFrame ?? 0) - 1) { success in
            if (success) {
                self.contentImageView.isHidden = false
                self.animationView.isHidden = true
                self.animationView.animation = nil
            }
        }
//        self.animationView.play(completion: { success in
//            if (success) {
//                self.contentImageView.isHidden = false
//                self.animationView.isHidden = true
//                self.animationView.animation = nil
//            }
//        })
        
        
//        self.animationView.play(fromFrame: animation?.endFrame ?? 0, toFrame: 0, loopMode: .playOnce, completion: {
//            success in
//            if (success) {
//                self.contentImageView.isHidden = false
//                self.animationView.isHidden = true
//                self.animationView.animation = nil
//            }
//        })

        
        self.animationViewContrainer.layer.transform = CATransform3DMakeScale(1, 1, 1)
        
        self.animationViewContrainer.layer.animateScale(from: self.animationViewContrainer.layer.translateScaleExact, to: 1, duration: duration, removeOnCompletion: false, completion: { success in
//            if (success) {
//                self.contentImageView.isHidden = false
//                self.animationView.isHidden = true
//                self.animationView.animation = nil
//            }
        })
        
        self.animationViewContrainer.layer.transform = CATransform3DMakeTranslation(frame.origin.x, frame.origin.y, 0)
        
        self.animationViewContrainer.layer.animate(from: self.animationViewContrainer.layer.translateXExact as NSNumber, to: 0 as NSNumber, keyPath: "transform.translation.x", duration: duration)
        self.animationViewContrainer.layer.animate(from: self.animationViewContrainer.layer.translateYExact as NSNumber, to: 0 as NSNumber, keyPath: "transform.translation.y", duration: duration)
    }
}
