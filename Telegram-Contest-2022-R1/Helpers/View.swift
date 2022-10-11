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
        var highlited: (Int?) -> Void
        var selected: (Int) -> Void
        
        init(itemsCount: Int, canSelectMultiple: Bool, highlited: @escaping (Int?) -> Void, selected: @escaping (Int) -> Void) {
            self.itemsCount = itemsCount
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
    
    private var preSelectedIndex: Int?
    
    private func selectedIndex(touch: UITouch, count: Int) -> Int? {
        let step = self.frame.width / CGFloat(count)
        let touchPoint = touch.location(in: self)
        
        if (touchPoint.y < 0 || touchPoint.y > self.frame.height) {
            return nil
        }
        
        if (touchPoint.x < 0 || touchPoint.x > self.frame.width) {
            return nil
        }
        
        let index = Int(touchPoint.x / step)
        
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
        self.touchReportsIndex?.highlited(index)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        guard let touchReportsIndex = self.touchReportsIndex else { return }
        
        guard let touch = touches.first else {
            return
        }
        
        let index = self.selectedIndex(touch: touch, count: touchReportsIndex.itemsCount)
        
        if touchReportsIndex.canSelectMultiple {
            self.touchReportsIndex?.highlited(index)
        } else {
            if self.preSelectedIndex == index {
                self.touchReportsIndex?.highlited(index)
            } else {
                self.touchReportsIndex?.highlited(nil)
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        guard let touchReportsIndex = self.touchReportsIndex else { return }
        
        guard let touch = touches.first else {
            return
        }
        
        touchReportsIndex.highlited(nil)
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
        guard let touchReportsIndex = self.touchReportsIndex else { return }
        
        self.preSelectedIndex = nil
        touchReportsIndex.highlited(nil)
    }
    
    private func selected(index: Int?) {
        guard let touchReportsIndex = self.touchReportsIndex else { return }
        if let index = index {
            touchReportsIndex.selected(index)
        }
    }
}
