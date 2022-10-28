//
//  RootTextView.swift
//  Telegram-Contest-2022-R1
//
//  Created by Alexander Zimin on 28/10/2022.
//

import UIKit

class MaskView: View {
    override func setUp() {
        self.backgroundColor = .black
    }
}

class RootTextView: View {
    let aligmentView = TextLineAligmentView()
    let maskTopView = MaskView()
    
    var holderView = UIView()
    
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
        
        let tapGesture = UITapGestureRecognizer(target: gestureController, action: #selector(gestureController.tapGesture(_:)))
        self.addGestureRecognizer(tapGesture)
        
        TextGestureController.shared.gesture = moveGesture
        TextGestureController.shared.labelsContentView = self.contentView
        TextSelectionController.shared.labelsContentView = self.contentView
        
        self.addSubview(self.holderView)
        
        TextLineAligmentView.shared = self.aligmentView
        self.holderView.addSubview(self.aligmentView)
        
        self.holderView.addSubview(self.contentView)
        
        self.holderView.addSubview(self.backgroundView)
        self.backgroundView.backgroundColor = .black.withAlphaComponent(0.5)
        self.backgroundView.alpha = 0
        
        self.holderView.addSubview(self.frontView)
        
        TextPresentationController.shared.contentView = self.contentView
        TextPresentationController.shared.backgroundView = self.backgroundView
        TextPresentationController.shared.frontView = self.frontView
        
        NotificationSystem.shared.subscribeOnEvent(self) { [weak self] event in
            switch event {
            case let .maskUpdated(view, frame):
                self?.updateMask(view: view, frame: frame)
            default:
                break
            }
        }
    }
    
    private func updateMask(view: UIView, frame: CGRect) {
        self.maskTopView.frame = frame
        self.holderView.mask = self.maskTopView
    }
    
    override func layoutSubviewsOnChangeBounds() {
        self.aligmentView.frame = self.bounds
        self.contentView.frame = self.bounds
        self.backgroundView.frame = self.bounds
        self.frontView.frame = self.bounds
    }
}
