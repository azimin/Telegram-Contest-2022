//
//  TouchableView.swift
//  Telegram-Contest-2022-R1
//
//  Created by Alexander Zimin on 11/10/2022.
//

import UIKit

class View: UIView {
    class TouchReportsIndex {
        var itemsCount: Int
        
        var canSelectMultiple: Bool
        var isVertical: Bool
        var highlited: (Int?) -> Void
        var selected: (Int) -> Void
        
        init(itemsCount: Int, isVertical: Bool, canSelectMultiple: Bool, highlited: @escaping (Int?) -> Void, selected: @escaping (Int) -> Void) {
            self.itemsCount = itemsCount
            self.isVertical = isVertical
            self.canSelectMultiple = canSelectMultiple
            self.highlited = highlited
            self.selected = selected
        }
    }
    
    var touchReportsIndex: TouchReportsIndex? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setUp()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setUp()
    }
    
    func setUp() { }
    
    private var preveousBounds: CGRect = .zero
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if self.bounds != self.preveousBounds {
            self.layoutSubviewsOnChangeBounds()
            self.preveousBounds = self.bounds
        }
    }
    
    func layoutSubviewsOnChangeBounds() { }
    
    private var preSelectedIndex: Int?
    
    private func selectedIndex(touch: UITouch, count: Int) -> Int? {
        let step: CGFloat
        
        if self.touchReportsIndex?.isVertical == true {
            step = self.frame.height / CGFloat(count)
        } else {
            step = self.frame.width / CGFloat(count)
        }
        
        let touchPoint = touch.location(in: self)
        
        if (touchPoint.y < 0 || touchPoint.y > self.frame.height) {
            return nil
        }
        
        if (touchPoint.x < 0 || touchPoint.x > self.frame.width) {
            return nil
        }
        
        let index: Int
        if self.touchReportsIndex?.isVertical == true {
            index = Int(touchPoint.y / step)
        } else {
            index = Int(touchPoint.x / step)
        }
        
        if (index < 0 || index >= count) {
            return nil
        }
        
        return index
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let touchReportsIndex = self.touchReportsIndex else { return }
        
        guard let touch = touches.first else {
            return
        }
        
        let index = self.selectedIndex(touch: touch, count: touchReportsIndex.itemsCount)
        
        self.preSelectedIndex = index
        self.highlite(index: index)
    }
    
    private var hightlitedIndex: Int? = nil
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        guard let touchReportsIndex = self.touchReportsIndex else { return }
        
        guard let touch = touches.first else {
            return
        }
        
        let index = self.selectedIndex(touch: touch, count: touchReportsIndex.itemsCount)
        
        if touchReportsIndex.canSelectMultiple {
            self.highlite(index: index)
        } else {
            if self.preSelectedIndex == index {
                self.highlite(index: index)
            } else {
                self.highlite(index: nil)
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        guard let touchReportsIndex = self.touchReportsIndex else { return }
        
        guard let touch = touches.first else {
            return
        }
        
        self.highlite(index: nil)
        let index = self.selectedIndex(touch: touch, count: touchReportsIndex.itemsCount)
        if touchReportsIndex.canSelectMultiple == false && self.preSelectedIndex == index {
            self.selected(index: index)
        } else if touchReportsIndex.canSelectMultiple {
            self.selected(index: index)
        }
        
        self.preSelectedIndex = nil
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        guard self.touchReportsIndex != nil else { return }
        
        self.preSelectedIndex = nil
        self.highlite(index: nil)
    }
    
    private func highlite(index: Int?) {
        if self.hightlitedIndex == index {
            return
        }
        self.hightlitedIndex = index
        guard let touchReportsIndex = self.touchReportsIndex else { return }
        touchReportsIndex.highlited(index)
    }
    
    private func selected(index: Int?) {
        guard let touchReportsIndex = self.touchReportsIndex else { return }
        if let index = index {
            touchReportsIndex.selected(index)
        }
    }
    
    func hierarhyConvertFrame(_ frame: CGRect, from fromView: UIView, to toView: UIView) -> CGRect {
        let sourceWindowFrame = fromView.convert(frame, to: nil)
        var targetWindowFrame = toView.convert(sourceWindowFrame, from: nil)
        if let fromWindow = fromView.window, let toWindow = toView.window {
            targetWindowFrame.origin.x += toWindow.bounds.width - fromWindow.bounds.width
        }
        return targetWindowFrame
    }
}
