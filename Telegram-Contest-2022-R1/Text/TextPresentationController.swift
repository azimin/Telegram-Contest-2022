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
    weak var frontView: UIView?
    
    weak var presentedLabel: TextLabelView?
    
    var isTextPresented: Bool = false
    var isNextStepIsOpen: Bool = false
    
    func presentView(view: TextLabelView) {
        self.presentedLabel = view
        self.isTextPresented = true
        
        NotificationSystem.shared.fireEvent(.textPresentationStateChanged(isPresenting: true))
        
        self.isNextStepIsOpen = false
        
        self.frontView?.isUserInteractionEnabled = true
        view.removeFromSuperview()
        self.frontView?.addSubview(view)
        
        UIView.animate(withDuration: 0.2) {
            self.backgroundView?.alpha = 1
        }
    }
    
    func hideView(view: TextLabelView) {
        self.presentedLabel = nil
        self.isTextPresented = false
        NotificationSystem.shared.fireEvent(.textPresentationStateChanged(isPresenting: false))
        
        self.frontView?.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.2, animations: {
            self.backgroundView?.alpha = 0
        }) {
            _ in
            view.removeFromSuperview()
            self.contentView?.addSubview(view)
        }
    }
    
    func deleteView(view: TextLabelView) {
        self.presentedLabel = nil
        self.isTextPresented = false
        
        NotificationSystem.shared.fireEvent(.textPresentationStateChanged(isPresenting: false))
        
        self.frontView?.isUserInteractionEnabled = false
        
        view.deleteAnimation()
        UIView.animate(withDuration: 0.2, animations: {
            self.backgroundView?.alpha = 0
        })
    }
}
