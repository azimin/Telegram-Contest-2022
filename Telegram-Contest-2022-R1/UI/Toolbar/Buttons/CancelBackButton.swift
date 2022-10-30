//
//  CancelBackButton.swift
//  Telegram-Contest-2022-R1
//
//  Created by Alexander Zimin on 11/10/2022.
//

import UIKit
import Lottie

class CancelBackButton: Button {
    let containerView = UIView()
    let animationView = LottieAnimationView()
    
    override func setUp() {
        self.backgroundColor = UIColor.white.withAlphaComponent(0.02)
        self.addSubview(self.containerView)
        self.addSubview(self.animationView)
        self.animationView.currentFrame = 30
        self.containerView.isUserInteractionEnabled = false
        self.animationView.isUserInteractionEnabled = false
        self.switchToState(state: .back, duration: 0)
    }
    
    override func layoutSubviewsOnChangeBounds() {
        self.containerView.frame = self.bounds
        self.animationView.frame = self.bounds
    }
    
    enum State {
        case back
        case cancel
    }
    
    func switchToState(state: State, duration: TimeInterval) {
        let animation = LottieAnimation.named(
            state == .back ? "cancel_to_back" : "back_to_cancel",
            bundle: .main,
            animationCache: LRUAnimationCache.sharedCache
        )
        self.animationView.animation = animation
        
        if duration == 0 {
            self.animationView.currentFrame = 0
            return
        }
        
        self.animationView.play()
    }
}
