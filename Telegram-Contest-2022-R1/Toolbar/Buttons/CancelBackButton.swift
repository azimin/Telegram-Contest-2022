//
//  CancelBackButton.swift
//  Telegram-Contest-2022-R1
//
//  Created by Alexander Zimin on 11/10/2022.
//

import UIKit
import Lottie

class CancelBackButton: Button {
    let animationView = LottieAnimationView(animation: .named("backToCancel", animationCache: LRUAnimationCache.sharedCache))
    
    override func setUp() {
        self.addSubview(self.animationView)
        self.animationView.currentFrame = 30
        self.animationView.isUserInteractionEnabled = false
    }
    
    override func layoutSubviewsOnChangeBounds() {
        self.animationView.frame = self.bounds
    }
    
    enum State {
        case back
        case cancel
    }
    
    func switchToState(state: State, duration: TimeInterval) {
        let from: AnimationFrameTime = state == .back ? 30 : 0
        let to: AnimationFrameTime = state == .back ? 59 : 30
        
        if duration == 0 {
            self.animationView.currentFrame = to
            return
        }
        
        let defaultDuration = self.animationView.animation?.duration ?? 1
        self.animationView.animationSpeed = defaultDuration / duration * CALayer.currentSpeed()
        
        self.animationView.play(fromFrame: from, toFrame: to, completion: { success in
            if (success) {
                self.animationView.currentFrame = to
            }
        })
    }
}
