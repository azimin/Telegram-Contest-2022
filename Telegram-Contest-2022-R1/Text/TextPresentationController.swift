//
//  TextPresentationController.swift
//  TextExperiment
//
//  Created by Alexander Zimin on 24/10/2022.
//

import Foundation

class TextPresentationController {
    static var shared = TextPresentationController()
    
    weak var contentView: UIView?
    weak var backgroundView: UIView?
    weak var frontView: TextEnterFrontView?
    
    weak var presentedLabel: TextLabelView?
    
    var isTextPresented: Bool = false
    var isNextStepIsOpen: Bool = false
    
    func getTextView(id: Int) -> TextLabelView? {
        var subviews: [TextLabelView] = []
        for view in (contentView?.subviews ?? []) + (frontView?.labelsContentView.subviews ?? []) {
            if let label = view as? TextLabelView {
                subviews.append(label)
            }
        }
        return subviews.first(where: { $0.id == id })
    }
    
    func presentView(view: TextLabelView) {
        TextGestureController.shared.isEnable = false
        
        self.presentedLabel = view
        self.isTextPresented = true
        
        NotificationSystem.shared.fireEvent(.textPresentationStateChanged(isPresenting: true))
        self.frontView?.fontToProgress(textView: view)
        
        self.isNextStepIsOpen = false
        
        self.frontView?.isUserInteractionEnabled = true
        view.removeFromSuperview()
        self.frontView?.labelsContentView.addSubview(view)
        self.frontView?.performAnimation(isShowing: true)
        
        UIView.animate(withDuration: 0.2) {
            self.backgroundView?.alpha = 1
        }
    }
    
    func hideView(view: TextLabelView) {
        self.presentedLabel = nil
        self.isTextPresented = false
        self.frontView?.performAnimation(isShowing: false)
        
        NotificationSystem.shared.fireEvent(.textPresentationStateChanged(isPresenting: false))
        
        self.frontView?.isUserInteractionEnabled = false
        
        UIView.animate(withDuration: 0.2, animations: {
            self.backgroundView?.alpha = 0
        }) {
            _ in
            let wasRemoved = view.superview == nil
            view.removeFromSuperview()
            if !wasRemoved {
                self.contentView?.addSubview(view)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            TextGestureController.shared.isEnable = true
        })
    }
    
    func deleteView(view: TextLabelView) {
        UndoManager.shared.removeCreateEvent(removeId: view.id)
        
        self.presentedLabel = nil
        self.isTextPresented = false
        self.frontView?.performAnimation(isShowing: false)
        
        NotificationSystem.shared.fireEvent(.textPresentationStateChanged(isPresenting: false))
        
        self.frontView?.isUserInteractionEnabled = false
        
        view.deleteAnimation()
        UIView.animate(withDuration: 0.2, animations: {
            self.backgroundView?.alpha = 0
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            TextGestureController.shared.isEnable = true
        })
    }
}
