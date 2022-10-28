//
//  RootTextView.swift
//  Telegram-Contest-2022-R1
//
//  Created by Alexander Zimin on 28/10/2022.
//

import UIKit

class RootTextView: View {
    let aligmentView = TextLineAligmentView()
    
    let contentView = UIView()
    let backgroundView = UIView()
    let frontView = UIView()
    
    let gestureController = TextGestureController.shared
    
    func createTextView() {
        let textLabelView = TextLabelView()
        self.contentView.addSubview(textLabelView)
        TextPresentationController.shared.isNextStepIsOpen = true
        textLabelView.goToEditState(isOpen: true)
    }
    
    override func setUp() {
        self.gestureController.rootView = self
        
        let moveGesture = UIPanGestureRecognizer(target: gestureController, action: #selector(gestureController.fingerGesture(_:)))
        moveGesture.minimumNumberOfTouches = 1
        moveGesture.maximumNumberOfTouches = 2
        self.addGestureRecognizer(moveGesture)
        
        TextGestureController.shared.gesture = moveGesture
        TextGestureController.shared.labelsContentView = self.contentView
        TextSelectionController.shared.labelsContentView = self.contentView
        
        TextLineAligmentView.shared = self.aligmentView
        self.addSubview(self.aligmentView)
        
        self.addSubview(self.contentView)
        
        self.addSubview(self.backgroundView)
        self.backgroundView.backgroundColor = .black.withAlphaComponent(0.5)
        self.backgroundView.alpha = 0
        
        self.addSubview(self.frontView)
        
        TextPresentationController.shared.contentView = self.contentView
        TextPresentationController.shared.backgroundView = self.backgroundView
        TextPresentationController.shared.frontView = self.frontView
    }
    
    override func layoutSubviewsOnChangeBounds() {
        self.aligmentView.frame = self.bounds
        self.contentView.frame = self.bounds
        self.backgroundView.frame = self.bounds
        self.frontView.frame = self.bounds
    }
}
