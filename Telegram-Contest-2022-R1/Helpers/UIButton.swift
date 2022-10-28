//
//  UIButton.swift
//  Telegram-Contest-2022-R1
//
//  Created by Alexander Zimin on 10/10/2022.
//

import Foundation
import UIKit

class ClosureSleeve {
    let closure: () -> ()
    
    init(attachTo: AnyObject, closure: @escaping () -> ()) {
        self.closure = closure
        objc_setAssociatedObject(attachTo, "[\(arc4random())]", self, .OBJC_ASSOCIATION_RETAIN)
    }
    
    @objc func invoke() {
        closure()
    }
}

extension UIControl {
    func addAction(for controlEvents: UIControl.Event = .primaryActionTriggered, action: @escaping () -> ()) {
        let sleeve = ClosureSleeve(attachTo: self, closure: action)
        addTarget(sleeve, action: #selector(ClosureSleeve.invoke), for: controlEvents)
    }
}

class Button: UIButton {
    override init(frame: CGRect) {
        super.init(frame: .zero)
        self.setUp()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isEnabled: Bool {
        didSet {
            self.updateState()
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            self.updateState()
        }
    }
    
    private var preveousBounds: CGRect = .zero
    
    var shouldAlignImageSize: CGSize? = nil
    func setImage(image: UIImage?, inSize size: CGSize?, forState state: UIControl.State) {
        self.shouldAlignImageSize = size
        self.setImage(image, for: state)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if self.bounds != self.preveousBounds {
            self.layoutSubviewsOnChangeBounds()
            self.preveousBounds = self.bounds
        }
        
        if let size = self.shouldAlignImageSize {
            self.imageEdgeInsets = UIEdgeInsets(
                top: (frame.height - size.height) / 2,
                left: (frame.width - size.width) / 2,
                bottom: (frame.height - size.height) / 2,
                right: (frame.width - size.width) / 2
            )
        }
    }
    
    func layoutSubviewsOnChangeBounds() { }
    
    func updateState() {
        if self.isInHideState {
            return
        }
        
        if self.isEnabled == false {
            self.alpha = 0.3
        } else {
            if self.isHighlighted {
                self.alpha = 0.7
            } else {
                self.alpha = 1.0
            }
        }
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if self.isUserInteractionEnabled == false {
            return super.hitTest(point, with: event)
        }
        
        let rect = CGRect(x: -10, y: -10, width: self.bounds.width + 20, height: self.bounds.height + 20)
        if rect.contains(point) {
            return self
        }
        return super.hitTest(point, with: event)
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return bounds.insetBy(dx: -10, dy: -10).contains(point)
    }
    
    func setUp() { }
    
    var isInHideState = false
    
    func animateButton(isHide: Bool, duration: CGFloat) {
        self.isInHideState = isHide
        self.isEnabled = !isHide
        
        var currentScale: CGFloat = isHide ? 0 : 1
        if let transform = self.layer.presentation()?.value(forKey: "transform") as? CATransform3D {
            currentScale = transform.m22
        }
        
        if (isHide) {
            self.layer.transform = CATransform3DMakeScale(0, 0, 1)
            self.layer.animate(from: currentScale as NSNumber, to: 0 as NSNumber, keyPath: "transform.scale", timingFunction: CAMediaTimingFunctionName.easeOut.rawValue, duration: duration)
        } else {
            self.layer.transform = CATransform3DMakeScale(1, 1, 1)
            self.layer.animate(from: currentScale as NSNumber, to: 1 as NSNumber, keyPath: "transform.scale", timingFunction: CAMediaTimingFunctionName.easeOut.rawValue, duration: duration)
        }
    }
}
