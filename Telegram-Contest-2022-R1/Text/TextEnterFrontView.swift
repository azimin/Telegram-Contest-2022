//
//  TextEnterFrontView.swift
//  Telegram-Contest-2022-R1
//
//  Created by Alexander Zimin on 29/10/2022.
//

import UIKit

class TextEnterFrontView: View, KeyboardHandlerDelegate {
    let sizeView = FontSizeView()
    
    override func setUp() {
        self.addSubview(self.sizeView)
        self.sizeView.isHidden = false
        self.keyboardDelegate = self
        
        self.sizeView.progressUpdated = { value in
            guard let label = TextPresentationController.shared.presentedLabel else {
                return
            }
            let progress = 1 - value
            label.updateRecommendedFont(font: UIFont.sfProTextSemibold(42 * progress + 7))
        }
    }
    
    func fontToProgress(textView: TextLabelView) {
        let font = textView.cachedRecommendedFont ?? textView.textView.recommendedFont
        let size = font.pointSize
        let progress = (size - 7) / 42
        self.sizeView.setProgress(value: (1 - progress))
    }
    
    override func layoutSubviewsOnChangeBounds() {
        self.updateSize()
        self.sizeView.layer.setTransform(translateX: -40)
    }
    
    var recommendedHeight: CGFloat = 339
    
    func updateSize() {
        let frame = GlobalConfig.textScreenFrame
        var delta = frame.origin.y + 60
        var height = frame.height - self.recommendedHeight - 120
        
        if height < 150 {
            delta = frame.origin.y + 30
            height = frame.height - self.recommendedHeight - 60
        }
        
        self.sizeView.frame = CGRect(
            x: -14,
            y: delta,
            width: 28,
            height: height
        )
    }
    
    func performAnimation(isShowing: Bool) {
        if isShowing {
            self.sizeView.isHidden = false
            self.sizeView.layer.transform = CATransform3DMakeTranslation(0, 0, 0)
            self.sizeView.layer.animateSpring(from: -40 as NSNumber, to: 0 as NSNumber, keyPath: "transform.translation.x", duration: 0.6)
        } else {
            self.sizeView.isUserInteractionEnabled = false
            let translationX = self.sizeView.layer.value(forKeyPath: "transform.translation.x") as? CGFloat ?? 0
            self.sizeView.layer.setTransform(translateX: -40)
            self.sizeView.layer.animateSpring(from: translationX as NSNumber, to: -40 as NSNumber, keyPath: "transform.translation.x", duration: 0.6) { success in
                self.sizeView.isUserInteractionEnabled = true
                if success {
                    self.sizeView.isHidden = true
                }
            }
        }
    }
    
    func keyboardStateChanged(input: UIView?, state: KeyboardState, info: KeyboardInfo) {
        switch state {
        case .frameChanged, .opened:
            self.recommendedHeight = info.endFrame.height
            self.updateSize()
        case .hidden:
            break
        }
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let frame = self.sizeView.frame
        if frame.insetBy(dx: -20, dy: 8).contains(point) {
            return super.point(inside: point, with: event)
        }
        return false
    }
}
