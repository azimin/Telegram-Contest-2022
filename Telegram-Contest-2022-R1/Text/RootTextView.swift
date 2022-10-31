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
    
    var isAppear: Bool = false
    var fullFrame: CGRect = .zero
    var recommendedFrame: CGRect = .zero {
        didSet {
            self.update()
        }
    }
    
    func update() {
        self.frame = isAppear ? fullFrame : recommendedFrame
    }
    
    func animate(isAppear: Bool, duration: CGFloat) {
        self.isAppear = isAppear
        self.layer.animateFrame(from: isAppear ? recommendedFrame : fullFrame, to: isAppear ? fullFrame : recommendedFrame, duration: duration)
        self.frame = isAppear ? fullFrame : recommendedFrame
    }
}

class RootTextView: View, UIGestureRecognizerDelegate {
    let aligmentView = TextLineAligmentView()
    let maskTopView = MaskView()
    let maskContentView = MaskView()
    
    var holderView = UIView()
    let contentView = UIView()
    let backgroundView = UIView()
    let frontView = UIView()
    let frontSizeControlView = TextEnterFrontView()
    
    let gestureController = TextGestureController.shared
    
    func createTextView(color: ColorPickerResult) {
        let textLabelView = TextLabelView(id: Int.random(in: 0..<Int.max))
        UndoManager.shared.addAction(.createdText(id: textLabelView.id))
        textLabelView.updateTextColor(colorResult: color)
        self.contentView.addSubview(textLabelView)
        TextPresentationController.shared.isNextStepIsOpen = true
        textLabelView.goToEditState(isOpen: true)
    }
    
    var tapGesture: UITapGestureRecognizer!
    
    override func setUp() {
        self.backgroundColor = UIColor.white.withAlphaComponent(0.001)
        self.gestureController.rootView = self
        
        let moveGesture = UIPanGestureRecognizer(target: gestureController, action: #selector(gestureController.fingerGesture(_:)))
        moveGesture.minimumNumberOfTouches = 1
        moveGesture.maximumNumberOfTouches = 2
        self.addGestureRecognizer(moveGesture)
        
        let tapGesture = UITapGestureRecognizer(target: gestureController, action: #selector(gestureController.tapGesture(_:)))
        tapGesture.delegate = self
        self.addGestureRecognizer(tapGesture)
        self.tapGesture = tapGesture
        
        TextGestureController.shared.gesture = moveGesture
        TextGestureController.shared.tapGesture = tapGesture
        TextGestureController.shared.labelsContentView = self.contentView
        TextSelectionController.shared.labelsContentView = self.contentView
        
        self.addSubview(self.holderView)
        
        TextLineAligmentView.shared = self.aligmentView
        self.holderView.addSubview(self.aligmentView)
        
        self.holderView.addSubview(self.contentView)
        
        self.holderView.addSubview(self.backgroundView)
        self.backgroundView.backgroundColor = .black.withAlphaComponent(0.5)
        self.backgroundView.alpha = 0
        
        self.addSubview(self.frontView)
        self.addSubview(self.frontSizeControlView)
        
        TextPresentationController.shared.contentView = self.contentView
        TextPresentationController.shared.backgroundView = self.backgroundView
        TextPresentationController.shared.frontView = self.frontView
        TextPresentationController.shared.frontSizeControlView = self.frontSizeControlView
        TextPresentationController.shared.frontMaskView = self.maskContentView
        
        NotificationSystem.shared.subscribeOnEvent(self) { [weak self] event in
            switch event {
            case let .maskUpdated(view, frame):
                self?.updateMask(view: view, frame: frame)
            case let .changeTextStyle(style):
                let textView = TextPresentationController.shared.presentedLabel ?? TextSelectionController.shared.selectedText
                textView?.backgroundStyle = style
            case let .changeTextAligment(aligment):
                let textView = TextPresentationController.shared.presentedLabel ?? TextSelectionController.shared.selectedText
                textView?.changeAligment(newAligment: aligment)
            default:
                break
            }
        }
    }
    
    func clearAll() {
        TextSelectionController.shared.deselectText()
        
        self.contentView.subviews.forEach({
            $0.removeFromSuperview()
        })
        
        self.frontView.subviews.forEach({
            $0.removeFromSuperview()
        })
    }
    
    private func updateMask(view: UIView, frame: CGRect) {
        self.maskTopView.frame = frame
        self.holderView.mask = self.maskTopView
        
        self.maskContentView.recommendedFrame = frame
        self.frontView.mask = self.maskContentView
    }
    
    override func layoutSubviewsOnChangeBounds() {
        self.holderView.frame = self.bounds
        self.aligmentView.frame = self.bounds
        self.contentView.frame = self.bounds
        self.backgroundView.frame = self.bounds
        self.frontView.frame = self.bounds
        self.frontSizeControlView.frame = self.bounds
        self.maskContentView.fullFrame = self.bounds
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == self.tapGesture {
            TextGestureController.shared.isMenuVisible = UIMenuController.shared.isMenuVisible
            return true
        }
        return true
    }
}
