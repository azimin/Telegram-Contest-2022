//
//  TextEnterFrontView.swift
//  Telegram-Contest-2022-R1
//
//  Created by Alexander Zimin on 29/10/2022.
//

import UIKit

class TextEnterFrontView: View {
    let sizeView = FontSizeView()
    
    override func setUp() {
        self.addSubview(self.sizeView)
        self.sizeView.isHidden = false
        
        self.sizeView.progressUpdated = { value in
            guard let label = TextPresentationController.shared.presentedLabel else {
                return
            }
            let progress = 1 - value
            label.updateRecommendedFont(font: UIFont.sfProTextSemibold(46 * progress + 5))
        }
    }
    
    override func layoutSubviewsOnChangeBounds() {
        self.sizeView.frame = CGRect(x: -14, y: 120, width: 28, height: 240)
    }
    
    func performAnimation(isShowing: Bool) {
        if isShowing {
            self.sizeView.isHidden = false
            self.sizeView.layer.transform = CATransform3DMakeTranslation(0, 0, 0)
            self.sizeView.layer.animateSpring(from: -40 as NSNumber, to: 0 as NSNumber, keyPath: "transform.translation.x", duration: 0.6)
        } else {
            self.sizeView.isUserInteractionEnabled = false
            let translationX = self.sizeView.layer.value(forKeyPath: "transform.translation.x") as? CGFloat ?? 0
            self.sizeView.layer.animateSpring(from: translationX as NSNumber, to: -40 as NSNumber, keyPath: "transform.translation.x", duration: 0.6) { success in
                self.sizeView.isUserInteractionEnabled = true
                if success {
                    self.sizeView.isHidden = true
                }
            }
        }
    }
}
