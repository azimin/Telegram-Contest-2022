//
//  FeatureUnderDevelopment.swift
//  Telegram-Contest-2022-R1
//
//  Created by Alexander Zimin on 30/10/2022.
//

import UIKit

class FeatureUnderDevelopmentView: View {
    let iconLabel = UILabel()
    let titleLabel = UILabel()
    
    override func setUp() {
        self.autolayout {
            self.constraintSize(width: nil, height: 54)
        }
        
        self.layer.cornerRadius = 16
        self.layer.masksToBounds = true
        
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(blurEffectView)
        
        self.addSubview(self.iconLabel)
        self.addSubview(self.titleLabel)
        
        self.iconLabel.numberOfLines = 1
        self.titleLabel.numberOfLines = 1
        
        self.iconLabel.font = .sfProTextRegular(17)
        self.titleLabel.font = .sfProTextRegular(17)
        
        self.iconLabel.text = "🚧"
        self.titleLabel.text = "This feature is under development"
        
        self.titleLabel.adjustsFontSizeToFitWidth = true
        
        self.iconLabel.autolayout {
            self.iconLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16).activate()
            self.iconLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).activate()
        }
        self.iconLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        self.titleLabel.autolayout {
            self.titleLabel.leadingAnchor.constraint(equalTo: self.iconLabel.trailingAnchor, constant: 16).activate()
            self.titleLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).activate()
            self.titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16).activate()
        }
        
        self.hideView(animated: false)
    }
    
    var isViewIsPresented = true
    var timer: Timer? = nil
    
    func showView() {
        self.timer?.invalidate()
        let timer = Timer.scheduledTimer(timeInterval: 4, target: self, selector: #selector(self.hideViewAction), userInfo: nil, repeats: false)
        RunLoop.main.add(timer, forMode: RunLoop.Mode.common)
        self.timer = timer
        
        if self.isViewIsPresented {
            self.shake()
            return
        }
        
        self.isViewIsPresented = true
        
        let currentScale = self.layer.translateScaleExact
        let currentAlpha = layer.value(forKeyPath: "opacity") as? CGFloat ?? 0
        
        self.layer.setTransform(scale: 1)
        self.layer.opacity = 1
        
        self.layer.animateSpring(from: currentScale as NSNumber, to: 1 as NSNumber, keyPath: "transform.scale", duration: 0.62)
        self.layer.animateAlpha(from: currentAlpha, to: 1, duration: 0.25)
    }
    
    @objc
    func hideViewAction() {
        self.hideView(animated: true)
    }
    
    func hideView(animated: Bool) {
        if !self.isViewIsPresented {
            return
        }
        
        self.isViewIsPresented = false
        
        let currentScale = self.layer.translateScaleExact
        let currentAlpha = layer.value(forKeyPath: "opacity") as? CGFloat ?? 0
        
        self.layer.setTransform(scale: 0)
        self.layer.opacity = 0
        
        if animated {
            self.layer.animateSpring(from: currentScale as NSNumber, to: 0 as NSNumber, keyPath: "transform.scale", duration: 0.62)
            self.layer.animateAlpha(from: currentAlpha, to: 0, duration: 0.25)
        }
        
    }
}

public extension UIView {
    private static let shakeAnimationKey = "shake"

    func shake() {
        self.stopShaking()
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        animation.duration = 1
        animation.repeatCount = 1
        let angle1 = 10
        let angle2 = angle1 / 2
        let angle3 = angle2 / 2
        animation.values = [ 0.0, -angle1, angle1, -angle1, angle1, -angle2, angle2, -angle3, angle3, 0.0 ]
        self.layer.add(animation, forKey: UIView.shakeAnimationKey)
    }

    func stopShaking() {
        self.layer.removeAnimation(forKey: UIView.shakeAnimationKey)
    }
}
