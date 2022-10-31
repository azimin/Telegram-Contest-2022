//
//  AllowAccessButton.swift
//  Telegram-Contest-2022-R1
//
//  Created by Alexander Zimin on 31/10/2022.
//

import UIKit

class AllowAccessButton: Button {
    let animationGradient = CAGradientLayer()
    var timer: Timer!
    
    override func setUp() {
        self.layer.masksToBounds = true
        
        self.constraintSize(width: nil, height: 50)
        self.titleLabel?.font = .sfProTextSemibold(17)
        self.setTitle("Select Media", for: .normal)
        self.backgroundColor = UIColor(hex: "007AFF")
        self.layer.cornerRadius = 10
        self.setTitleColor(.white, for: .normal)
        self.layer.addSublayer(animationGradient)
        
        self.animationGradient.colors = [UIColor.white.withAlphaComponent(0).cgColor, UIColor.white.withAlphaComponent(0.32).cgColor, UIColor.white.withAlphaComponent(0.37).cgColor, UIColor.white.withAlphaComponent(0.32).cgColor, UIColor.white.withAlphaComponent(0).cgColor]
        self.animationGradient.startPoint = CGPoint(x: 0, y: 0.5)
        self.animationGradient.endPoint = CGPoint(x: 1, y: 0.5)
        self.animationGradient.locations = [0, 0.1, 0.165, 0.23, 0.33]
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            self.runAnimation()
            let timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(self.runAnimation), userInfo: nil, repeats: true)
            RunLoop.main.add(timer, forMode: RunLoop.Mode.common)
            self.timer = timer
        })
        
    }
    
    override func layoutSubviewsOnChangeBounds() {
        self.animationGradient.frame = CGRect(
            x: -self.frame.width,
            y: 0,
            width: self.frame.width * 3,
            height: self.frame.height
        )
    }
    
    @objc
    func runAnimation() {
        let start: [NSNumber] = [0, 0.132, 0.165, 0.198, 0.33]
        let end: [NSNumber] = [0.67, 0.802, 0.835, 0.868, 1]
        self.animationGradient.animate(from: start as AnyObject, to: end as AnyObject, keyPath: "locations", duration: 1)
    }
}
