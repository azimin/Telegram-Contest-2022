//
//  TextLabelView.swift
//  TextExperiment
//
//  Created by Alexander Zimin on 14/10/2022.
//

import UIKit


class TextLabelView: UIView, KeyboardHandlerDelegate, UITextViewDelegate, UIGestureRecognizerDelegate {
    enum BackgroundStyle {
        case none
        case background
        case alphaBackground
        case outline
        
        var iconImage: UIImage? {
            switch self {
            case .none:
                return UIImage(named: "default")
            case .background:
                return UIImage(named: "filled")
            case .alphaBackground:
                return UIImage(named: "semi")
            case .outline:
                return UIImage(named: "stroke")
            }
        }
        
        func next() -> BackgroundStyle {
            switch self {
            case .none:
                return .background
            case .background:
                return .alphaBackground
            case .alphaBackground:
                return .outline
            case .outline:
                return .none
            }
        }
    }
    
    struct MutateValues {
        var scale: CGFloat
        var rotation: CGFloat
        var translation: CGPoint
        
        static var zero: MutateValues {
            return .init(scale: 0, rotation: 0, translation: .zero)
        }
        
        var transform: CATransform3D {
            let rotationTransform = CATransform3DMakeRotation(self.rotation, 0, 0, 1)
            let scaleTranform = CATransform3DMakeScale(self.scale, self.scale, 1)
            let translationTransform = CATransform3DMakeTranslation(self.translation.x, self.translation.y, 1)
            let finalTransform = CATransform3DConcat(CATransform3DConcat(rotationTransform, scaleTranform), translationTransform)
            return finalTransform
        }
    }
    
    enum AlingGestureState {
        case alignedVertically
        case freeform
        
        mutating func toggle() {
            switch self {
            case .alignedVertically:
                self = .freeform
            case .freeform:
                self = .alignedVertically
            }
        }
    }
    
    private var cacheMutateValues: MutateValues = .zero
    private var cacheTextAligment: NSTextAlignment = .center
    
    var alingGestureState: AlingGestureState = .alignedVertically
    
    var lastScaleValue: CGFloat = 1
    
    var backgroundStyle: BackgroundStyle = .none {
        didSet {
            if oldValue != self.backgroundStyle {
                self.updateBackgroundStyle()
            }
        }
    }
    
    var mutateValues: MutateValues {
        let rotation = layer.value(forKeyPath: "transform.rotation.z") as? CGFloat ?? 0
        let translationX = layer.value(forKeyPath: "transform.translation.x") as? CGFloat ?? 0
        let translationY = layer.value(forKeyPath: "transform.translation.y") as? CGFloat ?? 0
        return MutateValues(scale: self.lastScaleValue, rotation: rotation, translation: .init(x: translationX, y: translationY))
    }
    
    enum State {
        case startTransition
        case editingTransition
        case editing
        case presentingTransition
        case presenting
    }
    
    var isSelected: Bool = false {
        didSet {
            self.selectionView.isHidden = !isSelected
        }
    }
    
    let outlineView = TextLabelOutlineView()
    let backgroundView = TextBackgroundView(frame: .zero)
    let textView = CustomTextView()
    
    var state: State = .presenting {
        didSet {
            self.updateState()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    enum TouchStyle {
        case none
        case view
        case viewResize
    }
    
    var isInDisapearState = false
    
    func touchStyle(point: CGPoint, supportsResize: Bool) -> TouchStyle {
        if self.isInDisapearState {
            return .none
        }
        
        if supportsResize {
            let side: CGFloat = 20
            
            let circleLocation1 = CGRect(
                x: -side / self.lastScaleValue,
                y: self.bounds.height / 2 - side / self.lastScaleValue,
                width: (side * 2) / self.lastScaleValue,
                height: (side * 2) / self.lastScaleValue
            )
            
            let circleLocation2 = CGRect(
                x: self.bounds.width - side / self.lastScaleValue,
                y: self.bounds.height / 2 - side / self.lastScaleValue,
                width: (side * 2) / self.lastScaleValue,
                height: (side * 2) / self.lastScaleValue
            )
            
            if self.isSelected && (circleLocation1.contains(point) || circleLocation2.contains(point)) {
                return .viewResize
            }
            
            if self.textView.bounds.contains(point) {
                return .view
            }
        } else if self.textView.bounds.contains(point) {
            return .view
        }
        return .none
    }
    
    func updateState() {
        switch self.state {
        case .presentingTransition:
            if self.createdFrame == .zero {
                self.createdFrame = self.lastFrame
            }
            self.textView.isUserInteractionEnabled = false
        case .editingTransition, .startTransition:
            break
        case .editing:
            self.textView.isUserInteractionEnabled = true
        case .presenting:
            break
        }
    }
    
    func showControlls() {
        self.becomeFirstResponder()
        
        let menu = UIMenuController.shared
        menu.menuItems = [
            UIMenuItem(
                title: "Delete",
                action: #selector(self.deleteAction)
            ),
            UIMenuItem(
                title: "Edit",
                action: #selector(self.editAction)
            ),
            UIMenuItem(
                title: "Duplicate",
                action: #selector(self.dublicateAction)
            )
        ]
        var frame = self.frame
        
        frame.origin.y -= 16
        frame.size.height += 32
        
        menu.showMenu(from: self.superview ?? self, rect: frame)
        UIMenuController.shared.menuItems = []
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    @objc func deleteAction() {
        TextSelectionController.shared.deselectText()
        self.deleteAnimation()
    }
    
    func deleteAnimation() {
        self.isInDisapearState = true
        self.isUserInteractionEnabled = false
        
        self.layer.animate(from: self.mutateValues.scale as NSNumber, to: 0 as NSNumber, keyPath: "transform.scale", duration: 0.25, completion: {
            _ in
            self.removeFromSuperview()
        })
    }
    
    @objc func editAction() {
        self.goToEditState()
    }
    
    @objc func dublicateAction() {
        let textLabelView = self.copyView()
        self.superview?.addSubview(textLabelView)
        TextPresentationController.shared.isNextStepIsOpen = true
        textLabelView.goToEditState()
    }
    
    private var selectionView = TextSelectionView()
    
    func setup() {
        self.keyboardDelegate = self
        
        self.addSubview(self.backgroundView)
        self.backgroundView.backgroundColor = .clear
        
        self.addSubview(self.outlineView)
        
        self.addSubview(self.textView)
        self.textView.delegate = self
        self.textView.updateTextColor(color: .white)
        self.textView.textAlignment = .center
        self.textView.backgroundColor = .clear
        self.textView.recommendedFont = UIFont.sfProTextSemibold(46)
        self.textView.text = "Yo\nSome Content\nThe"
        self.textView.textContainerInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        self.textView.frame = self.bounds
        self.textView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.isHidden = true
        self.textView.autocorrectionType = .no
        self.textView.spellCheckingType = .no
        self.textView.inputAssistantItem.leadingBarButtonGroups = []
        self.textView.inputAssistantItem.trailingBarButtonGroups = []
        self.textView.rootView = self
        
        self.textView.customLayoutManager.backgroundView = self.backgroundView
        
        self.addSubview(self.selectionView)
        self.selectionView.frame = CGRectMake(0, -8, self.bounds.width, self.bounds.height + 16)
        self.selectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        self.updateState()
        
        self.outlineView.textLabelView = self
        
        // TODO: Color
        self.textView.customLayoutManager.backgroundColor = .clear
        
        self.isSelected = false
        
        self.setupView()
    }
    
    private func setupView() {
        self.refreshLayoutBackground()
        self.outlineView.updateWithVisual(textView: self.textView)
        self.outlineView.updateWith(text: self.textView.text, font: self.textView.recommendedFont)
    }
    
    var isMenuVisible = false
    
    @objc func tapAction() {
        if self.isSelected == false {
            TextSelectionController.shared.selectText(selectedText: self)
            self.showControlls()
        } else {
            if self.isMenuVisible {
                self.goToEditState()
            } else {
                self.showControlls()
            }
        }
        self.isMenuVisible = false
    }
    
    private func goToEditState() {
        TextSelectionController.shared.deselectText()
        self.goToEditState(isOpen: false)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        //        self.textView.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height)
        
        self.outlineView.frame = self.bounds
        self.textView.frame = self.bounds
        self.backgroundView.frame = self.bounds
        
        self.textView.adjustContentSize()
        self.outlineView.updateWith(text: self.textView.text, font: self.textView.font)
        
        self.selectionView.setNeedsDisplay()
        
        self.refreshLayoutBackground()
    }
    
    private var contentOffset: CGPoint = .zero
    
    func goToPresentState() {
        self.state = .presentingTransition
        TextPresentationController.shared.hideView(view: self)
        
        let width = self.textView.minimalWidth()
        let height = self.createdFrame.height
        let contentHeight = self.textView.contentHeight
        
        self.textView.forceWidth = self.createdFrame.width
        
        let distance = self.cacheTextAligment.findDistance(new: self.textView.textAlignment)
        let delta = distance * (self.createdFrame.width - width) / 2
        self.cacheMutateValues.translation.x += delta
        self.layer.transform = self.cacheMutateValues.transform
        
        var additionalTranslation: CGFloat = 0
        switch self.textView.textAlignment {
        case .center:
            break
        case .left:
            additionalTranslation = -(self.createdFrame.width - width) / 2
        case .right:
            additionalTranslation = (self.createdFrame.width - width) / 2
        default:
            break
        }
        
        let frame = CGRect(
            x: (self.createdFrame.width - width) / 2,
            y: self.createdFrame.origin.y + (height - contentHeight) / 2,
            width: width,
            height: contentHeight
        )
        
        self.frame = frame
        
        if self.cacheMutateValues.scale * UIScreen.main.scale > 1 {
            self.applyScaleFactor(scale: self.cacheMutateValues.scale * UIScreen.main.scale)
        }
        
        self.layer.animateSpring(from: additionalTranslation as NSNumber, to: self.mutateValues.translation.x as NSNumber, keyPath: "transform.translation.x", duration: 0.62)
        self.layer.animateSpring(from: 0 as NSNumber, to: self.mutateValues.translation.y as NSNumber, keyPath: "transform.translation.y", duration: 0.62)
        self.layer.animateSpring(from: 1 as NSNumber, to: self.mutateValues.scale as NSNumber, keyPath: "transform.scale", duration: 0.62)
        self.layer.animateSpring(from: 0 as NSNumber, to: self.mutateValues.rotation as NSNumber, keyPath: "transform.rotation.z", duration: 0.62, completion: {
            _ in
            self.applyScaleFactor(scale: self.cacheMutateValues.scale * UIScreen.main.scale)
        })
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            self.state = .presenting
        })
        
        if self.backgroundStyle == .outline {
            self.outlineView.changeState(state: .presenting)
        }
    }
    
    func goToEditState(isOpen: Bool) {
        UIMenuController.shared.hideMenu()
        
        self.cacheTextAligment = self.textView.textAlignment
        self.textView.forceWidth = nil
        
        TextPresentationController.shared.presentView(view: self)
        
        self.cacheMutateValues = self.mutateValues
        self.state = isOpen ? .startTransition : .editingTransition
        
        self.animateToEditPhase(info: nil)
        
        if isOpen {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                self.isHidden = false
            })
        }
        
        self.textView.becomeFirstResponder()
        let text = (self.textView.text as NSString)
        self.textView.selectedRange = NSMakeRange(text.length, 0)
        
        if self.backgroundStyle == .outline {
            self.outlineView.changeState(state: .editing)
        }
    }
    
    func changeAligment(newAligment: NSTextAlignment) {
        self.textView.textAlignment = newAligment
        self.refreshLayoutBackground()
        self.outlineView.updateWithVisual(textView: self.textView)
    }
    
    private func updateBackgroundStyle() {
        switch self.backgroundStyle {
        case .none:
            self.textView.customLayoutManager.backgroundColor = nil
            self.outlineView.changeState(state: .hidden)
        case .outline:
            self.textView.customLayoutManager.backgroundColor = nil
            switch self.state {
            case .presenting, .presentingTransition:
                self.outlineView.changeState(state: .presenting)
            case .editing, .editingTransition, .startTransition:
                self.outlineView.changeState(state: .editing)
            }
        case .background:
            self.outlineView.changeState(state: .hidden)
            self.textView.customLayoutManager.backgroundColor = UIColor.black
        case .alphaBackground:
            self.outlineView.changeState(state: .hidden)
            self.textView.customLayoutManager.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        }
    }
    
    // Keyboard delegate
    
    func keyboardStateChanged(input: UIView?, state: KeyboardState, info: KeyboardInfo) {
        switch self.state {
        case .editing, .editingTransition, .startTransition:
            self.updateKeyboardFrame(state: state, info: info)
        case .presenting, .presentingTransition:
            break
        }
    }
    
    private var lastFrame: CGRect = .zero
    private var createdFrame: CGRect = .zero
    
    func updateKeyboardFrame(state: KeyboardState, info: KeyboardInfo?) {
        switch state {
        case .opened:
            if self.state == .editingTransition || self.state == .startTransition || self.state == .editing {
                OperationQueue.main.addOperation {
                    self.animateToEditPhase(info: info)
                    self.isHidden = false
                }
            }
        case .frameChanged:
            // TODO: Check
            self.frame = CGRect(x: 0, y: 84, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 84 - (info?.endFrame.height ?? 0) - 16)
            //            self.lastFrame = self.frame
            break
        case .hidden:
            break
        }
    }
    
    func keyboardActiveInputViewChanged(input: UIView?, info: KeyboardInfo) { }
    
    var isPresentInProgress = false
    
    private func animateToEditPhase(info: KeyboardInfo?) {
        var finalFrame: CGRect = .zero
        
        if self.createdFrame != .zero, info == nil {
            finalFrame = self.createdFrame
        } else {
            finalFrame = CGRect(x: 0, y: 84, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 84 - (info?.endFrame.height ?? 0) - 16)
        }
        
        self.lastFrame = finalFrame
        
        if self.state == .startTransition {
            self.frame = finalFrame
            self.state = .editing
            return
        }
        
        self.frame = finalFrame
        
        if self.isPresentInProgress == false {
            if self.mutateValues.scale < UIScreen.main.scale {
                self.applyScaleFactor(scale: UIScreen.main.scale)
            }
            
            var additionalTranslation: CGFloat = 0
            let width = self.textView.minimalWidth()
            
            switch self.textView.textAlignment {
            case .center:
                break
            case .left:
                additionalTranslation = -(self.createdFrame.width - width) / 2
            case .right:
                additionalTranslation = (self.createdFrame.width - width) / 2
            default:
                break
            }
            
            self.layer.animateSpring(from: self.mutateValues.translation.x - additionalTranslation as NSNumber, to: 0 as NSNumber, keyPath: "transform.translation.x", duration: 0.62)
            self.layer.animateSpring(from: self.mutateValues.translation.y as NSNumber, to: 0 as NSNumber, keyPath: "transform.translation.y", duration: 0.62)
            self.layer.animateSpring(from: self.mutateValues.scale as NSNumber, to: 1 as NSNumber, keyPath: "transform.scale", duration: 0.62)
            self.layer.animateSpring(from: self.mutateValues.rotation as NSNumber, to: 0 as NSNumber, keyPath: "transform.rotation.z", duration: 0.62, completion: { _ in
                self.isPresentInProgress = false
                if self.state == .editingTransition {
                    self.state = .editing
                }
                self.applyScaleFactor(scale: UIScreen.main.scale)
            })
            self.layer.transform = CATransform3DIdentity
        }
        
        self.isPresentInProgress = true
    }
    
    // Mark Text Field
    
    func textViewDidChange(_ textView: UITextView) {
        self.textView.adjustContentSize()
        self.refreshLayoutBackground()
        
        self.outlineView.updateWith(text: self.textView.text, font: self.textView.font ?? .systemFont(ofSize: 20))
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        textView.inputAccessoryView = TextKeybaordControllsView(textAligment: self.textView.textAlignment, style: self.backgroundStyle)
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.textView.startHandleDiscardTapAfterDelay()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        self.textView.handleTap = false
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfLines = newText.components(separatedBy: .newlines).count
        
        return numberOfLines < 70 && newText.count < 2000
    }
    
    func refreshLayoutBackground() {
        self.textView.customLayoutManager.refreshBackground()
    }
    
    func copyView() -> TextLabelView {
        let view = TextLabelView()
        
        view.frame = self.frame
        view.layer.transform = self.layer.transform
        
        view.cacheTextAligment = self.cacheTextAligment
        view.cacheMutateValues = self.cacheMutateValues
        view.textView.text = self.textView.text
        view.textView.textAlignment = self.textView.textAlignment
        view.isHidden = false
        view.textView.recommendedFont = self.textView.recommendedFont
        view.lastScaleValue = self.lastScaleValue
        view.createdFrame = self.createdFrame
        view.state = self.state
        view.backgroundStyle = self.backgroundStyle
        
        view.setupView()
        
        return view
    }
}

extension NSTextAlignment {
    func next() -> NSTextAlignment {
        switch self {
        case .center:
            return .left
        case .left:
            return .right
        default:
            return .center
        }
    }
    
    func findDistance(new: NSTextAlignment) -> CGFloat {
        if self == new {
            return 0
        }
        
        switch self {
        case .center:
            if new == .left {
                return -1
            } else if new == .right {
                return 1
            }
        case .left:
            if new == .center {
                return 1
            } else if new == .right {
                return 2
            }
        case .right:
            if new == .center {
                return -1
            } else if new == .right {
                return -2
            }
        default:
            return 0
        }
        
        return 0
    }
}
