//
//  ContextMenuController.swift
//  Telegram-Contest-2022-R1
//
//  Created by Alexander Zimin on 13/10/2022.
//

import Foundation

class ContextMenuController {
    var showDuration: TimeInterval = 0.8
    var hideDuration: TimeInterval = 0.7
    
    static var shared = ContextMenuController()
    
    weak var presentView: UIView? = nil
    weak var currentMenu: ContextMenuView? = nil
    
    func attachToView(view: UIView) {
        self.presentView = view
    }
    
    func hideMenu() {
        let menu = self.currentMenu
        menu?.isUserInteractionEnabled = false
        menu?.animateTransition(transition: .disappear, duration: self.hideDuration, completion: {
            menu?.removeFromSuperview()
        })
    }
    
    func showItems(items: [ContextMenuView.Item], fromView: UIView) {
        self.hideMenu()
        
        guard let presentView = self.presentView else {
            return
        }
        
        let newMenu = ContextMenuView(items: items)
        presentView.addSubview(newMenu)
        newMenu.animateTransition(transition: .appear, duration: self.showDuration)
        
        let frame = presentView.hierarhyConvertFrame(fromView.frame, from: fromView.superview ?? fromView, to: presentView)
        
        newMenu.frame = CGRect(
            x: frame.maxX - newMenu.frame.width,
            y: frame.origin.y - newMenu.frame.height - 8,
            width: newMenu.frame.width,
            height: newMenu.frame.height
        )
        
        self.currentMenu = newMenu
    }
}
