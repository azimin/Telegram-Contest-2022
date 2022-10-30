//
//  ContextMenuView.swift
//  Telegram-Contest-2022-R1
//
//  Created by Alexander Zimin on 13/10/2022.
//

import UIKit

class ContextMenuView: View {
    struct Item {
        var title: String
        var iconName: String
    }
    
    let items: [Item]
    let selection: IndexBlock?
    
    init(items: [Item], selection: IndexBlock?, width: CGFloat) {
        self.items = items
        self.selection = selection
        let frame = CGRect(x: 0, y: 0, width: width, height: CGFloat(items.count) * 44)
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var highlightView = UIView()
    
    override func setUp() {
        self.layer.cornerRadius = 16
        self.layer.masksToBounds = true
        
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(blurEffectView)
        
        self.highlightView.backgroundColor = .white.withAlphaComponent(0.3)
        self.addSubview(self.highlightView)
        
        self.fillWithItems()
        
        self.touchReportsIndex = .init(
            itemsCount: self.items.count,
            isVertical: true,
            canSelectMultiple: true,
            highlited: { [weak self] index in
                self?.highlight(index: index)
            },
            selected: { [weak self] index in
                self?.selected(index: index)
            }
        )
    }
    
    private func fillWithItems() {
        for (index, item) in self.items.enumerated() {
            let label = UILabel()
            label.textColor = .white
            label.font = UIFont.sfProTextRegular(17)
            label.setText(string: item.title, tgKern: .m041)
            label.frame = CGRect(
                x: 16,
                y: 12 + 44 * CGFloat(index),
                width: self.frame.width - 60,
                height: 20
            )
            self.addSubview(label)
            
            let icon = UIImageView(image: UIImage(named: item.iconName))
            icon.frame = CGRect(x: label.frame.maxX + 4, y: 10 + 44 * CGFloat(index), width: 24, height: 24)
            self.addSubview(icon)
            
            if index < self.items.count - 1 {
                let seperator = UIView()
                self.addSubview(seperator)
                seperator.backgroundColor = .white.withAlphaComponent(0.3)
                seperator.frame = CGRect(x: 0, y: 44 * CGFloat(index + 1), width: self.frame.width, height: 0.33)
            }
        }
    }
    
    func animateTransition(transition: Transition, duration: TimeInterval, completion: VoidBlock? = nil) {
        if transition == .appear {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
        
        let fromOpacityAndScale: CGFloat = transition == .appear ? 0 : 1
        let toOpacityAndScale: CGFloat = transition == .appear ? 1 : 0
        
        let fromTranslationX = transition == .appear ? self.frame.width / 2 : 0
        let fromTranslationY = transition == .appear ? self.frame.height / 2 : 0
        
        let toTranslationX = transition == .appear ? 0 : self.frame.width / 2
        let toTranslationY = transition == .appear ? 0 : self.frame.height / 2
        
        self.layer.animateSpring(from: fromOpacityAndScale, to: toOpacityAndScale, keyPath: "opacity", duration: duration)
        self.layer.animateSpring(from: fromOpacityAndScale, to: toOpacityAndScale, keyPath: "transform.scale", duration: duration, completion: { _ in
            completion?()
        })
        self.layer.animateSpring(from: fromTranslationX, to: toTranslationX, keyPath: "transform.translation.x", duration: duration)
        self.layer.animateSpring(from: fromTranslationY, to: toTranslationY, keyPath: "transform.translation.y", duration: duration)
        
        self.layer.opacity = Float(toOpacityAndScale)
        self.layer.setTransform(scale: toOpacityAndScale, translateX: toTranslationX, translateY: toTranslationY)
    }
    
    private func selected(index: Int?) {
        if let index = index {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            ContextMenuController.shared.hideMenu()
            self.selection?(index)
        }
    }
    
    private func highlight(index: Int?) {
        guard let index = index else {
            self.highlightView.isHidden = true
            return
        }
        
        self.highlightView.isHidden = false
        self.highlightView.frame = CGRect(x: 0, y: CGFloat(index) * 44, width: self.frame.width, height: 44)
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return true
    }
    
    var startedInFrame: Bool = false
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        guard let touch = touches.first else {
            return
        }
        
        let touchPoint = touch.location(in: self)
        self.startedInFrame = self.bounds.contains(touchPoint)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        guard let touch = touches.first else {
            return
        }
        
        let touchPoint = touch.location(in: self)
        
        if self.startedInFrame == false && !self.bounds.contains(touchPoint) {
            ContextMenuController.shared.hideMenu()
        }
    }
}
