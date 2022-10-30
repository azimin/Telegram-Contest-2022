//
//  EditToolbarView.swift
//  Telegram-Contest-2022-R1
//
//  Created by Alexander Zimin on 10/10/2022.
//

import UIKit

protocol EditToolbarViewDelegate: NSObjectProtocol {
    func exitImageButtonClicked()
}

class EditToolbarView: View {
    enum ToolsState {
        case drawAllTools
        case drawSpecificTools
    }
    
    enum VisualState {
        case tools
        case text
    }
    
    var segmentItemSelected: ((Int) -> Void)?
    
    weak var delegate: EditToolbarViewDelegate?
    
    var toolsState: ToolsState = .drawAllTools
    var visualState: VisualState = .tools
    
    let cancelBackButton = CancelBackButton()
    let sendButton = SendButton()
    let selectColorButton = SelectColorButton()
    let addObjectButton = AddObjectButton()
    
    let toolsView = ToolsView()
    let sizeSegmentView = SizeSegmentView()
    let segmentsView = EditToolbarSegmentView(items: [.init(text: "Draw"), .init(text: "Text")])
    
    let textStyleButton = TextStyleButton()
    let textAligmentButton = TextAligmentButton()
    
    let toolDetailsButton = SelectToolDetailsButton()
    
    let bottomView = UIView()
    
    override func setUp() {
        self.autolayout {
            self.constraintSize(width: nil, height: 149)
        }
        
        self.bottomView.backgroundColor = UIColor.black
        self.addSubview(self.bottomView)
        
        self.addSubview(self.sendButton)
        self.sendButton.autolayout {
            self.sendButton.constraintSize(width: 33, height: 33)
            self.sendButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8).activate()
            self.sendButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8).activate()
        }
        
        self.addSubview(self.cancelBackButton)
        self.cancelBackButton.autolayout {
            self.cancelBackButton.constraintSize(width: 33, height: 33)
            self.cancelBackButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8).activate()
            self.cancelBackButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8).activate()
        }
        
        self.addSubview(self.selectColorButton)
        self.selectColorButton.autolayout {
            self.selectColorButton.constraintSize(width: 36, height: 36)
            self.selectColorButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 5).activate()
            self.selectColorButton.bottomAnchor.constraint(equalTo: self.cancelBackButton.topAnchor, constant: -14.5).activate()
        }
        
        self.addSubview(self.textStyleButton)
        self.textStyleButton.isHidden = true
        self.textStyleButton.isEnabled = false
        self.textStyleButton.autolayout {
            self.textStyleButton.constraintSize(width: 46, height: 46)
            self.textStyleButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 47).activate()
            self.textStyleButton.centerYAnchor.constraint(equalTo: self.selectColorButton.centerYAnchor).activate()
        }
        
        self.addSubview(self.textAligmentButton)
        self.textAligmentButton.isEnabled = false
        self.textAligmentButton.isHidden = true
        self.textAligmentButton.autolayout {
            self.textAligmentButton.constraintSize(width: 46, height: 46)
            self.textAligmentButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 91).activate()
            self.textAligmentButton.centerYAnchor.constraint(equalTo: self.selectColorButton.centerYAnchor).activate()
        }
        
        self.addSubview(self.toolDetailsButton)
        
        self.addSubview(self.addObjectButton)
        self.addObjectButton.autolayout {
            self.addObjectButton.constraintSize(width: 33, height: 33)
            self.addObjectButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8).activate()
            self.addObjectButton.bottomAnchor.constraint(equalTo: self.cancelBackButton.topAnchor, constant: -16).activate()
        }
        
        self.addSubview(self.sizeSegmentView)
        self.sizeSegmentView.isHidden = true
        
        self.addSubview(self.segmentsView)
        self.segmentsView.autolayout {
            self.segmentsView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8).activate()
            self.segmentsView.leadingAnchor.constraint(equalTo: self.cancelBackButton.trailingAnchor, constant: 16).activate()
            self.segmentsView.trailingAnchor.constraint(equalTo: self.sendButton.leadingAnchor, constant: -16).activate()
        }
        
        self.insertSubview(self.toolsView, belowSubview: self.selectColorButton)
        self.toolsView.autolayout {
            self.toolsView.constraintSize(width: nil, height: 108)
            self.toolsView.leadingAnchor.constraint(equalTo: self.segmentsView.leadingAnchor, constant: 0).activate()
            self.toolsView.trailingAnchor.constraint(equalTo: self.segmentsView.trailingAnchor, constant: 0).activate()
            self.toolsView.bottomAnchor.constraint(equalTo: self.segmentsView.topAnchor, constant: -1).activate()
        }
        
        self.bottomView.autolayout {
            self.bottomView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).activate()
            self.bottomView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).activate()
            self.bottomView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).activate()
            self.bottomView.topAnchor.constraint(equalTo: self.toolsView.bottomAnchor, constant: 0).activate()
        }
        
        self.toolsView.stateUpdating = { [weak self] state in
            guard let self else { return }
            switch state {
            case .componentPresented:
                self.toolsState = .drawSpecificTools
                
                self.cancelBackButton.switchToState(state: .back, duration: self.toolsView.tillMiddleDuration)
                
                let widthProgress: CGFloat
                switch self.toolsView.selectedTool {
                case .eraiser:
                    self.detailsStyle = .fromEraiser(ToolbarSettings.shared.eraserSettings.mode)
                    widthProgress = ToolbarSettings.shared.eraserSettings.widthProgress
                case .lasso:
                    widthProgress = 0
                    break
                case .pen, .brush, .neon, .pencil:
                    let currentTool = ToolbarSettings.shared.getToolSetting(style: .fromTool(self.toolsView.selectedTool))
                    self.detailsStyle = .fromTool(currentTool.state)
                    widthProgress = currentTool.widthProgress
                }
                self.toolDetailsButton.setContent(style: self.detailsStyle, animated: false)
                
                self.selectColorButton.animateButton(isHide: true, duration: self.toolsView.mainPartDuration)
                self.addObjectButton.animateButton(isHide: true, duration: self.toolsView.mainPartDuration)
                
                let frame = self.hierarhyConvertFrame(self.segmentsView.selectedView.frame, from: self.segmentsView, to: self.sizeSegmentView)
                
                self.sizeSegmentView.isHidden = false
                self.sizeSegmentView.animateIntoTumblerView(
                    fromFrame: frame,
                    toProgress: widthProgress,
                    duration: self.toolsView.tillMiddleDuration
                )
                
                self.sizeSegmentView.animateBackground(to: true, frame: self.segmentsView.bounds, duration: self.toolsView.tillMiddleDuration)
                
                self.segmentsView.switchAnimatedComponentsVisibility(isVisible: false, duration: self.toolsView.tillMiddleDuration)
                
                self.animateSendButton(duration: self.toolsView.tillMiddleDuration, disapear: false)
                
            case .allComponents:
                self.showAllComponents()
            }
        }
        
        self.addActions()
        
        NotificationSystem.shared.subscribeOnEvent(self) { [weak self] event in
            guard let self else { return }
            switch event {
            case let .textPresentationStateChanged(isPresenting):
                self.isUserInteractionEnabled = !isPresenting
            case let .textSelectionStateChanged(isSelected):
                self.textAligmentButton.isEnabled = isSelected
                self.textStyleButton.isEnabled = isSelected
                self.selectColorButton.isEnabled = isSelected
                
                if isSelected, let textView = TextSelectionController.shared.selectedText {
                    self.textAligmentButton.updateStyle(alignState: textView.textView.textAlignment, animated: true)
                    self.textStyleButton.updateStyle(style: textView.backgroundStyle, animated: true)
                    self.selectColorButton.colorPickerResult = textView.colorResult
                }
            default:
                break
            }
        }
        
        self.updateVisualState(.tools, animated: false, firstLaunch: true)
    }
    
    func addActions() {
        self.sizeSegmentView.progressUpdated = { value in
            self.toolsView.updateProgress(value: value)
            switch self.toolsView.selectedTool {
            case .eraiser:
                ToolbarSettings.shared.eraserSettings.widthProgress = value
            case .lasso:
                break
            case .pen, .brush, .neon, .pencil:
                let currentTool = ToolbarSettings.shared.getToolSetting(style: .fromTool(self.toolsView.selectedTool))
                currentTool.widthProgress = value
            }
        }
        
        self.addObjectButton.addAction(action: { [weak self] in
            guard let self else { return }
            
            if self.segmentsView.selectedItem == 1 {
                NotificationSystem.shared.fireEvent(.createText)
                return
            }
            
            let shapes = Shape.allCases
            let items: [ContextMenuView.Item] = shapes.map({ .init(title: $0.title, iconName: $0.iconName)} )
            NotificationSystem.shared.fireEvent(.showFeatureUnderDevelopment)
            ContextMenuController.shared.showItems(items: items, fromView: self.addObjectButton, preferableWidth: 180) { _ in
                NotificationSystem.shared.fireEvent(.showFeatureUnderDevelopment)
            }
        })
        
        self.toolDetailsButton.addAction(action: { [weak self] in
            guard let self else { return }
            self.toolsDetailsClicked()
        })
        
        self.cancelBackButton.addAction(action: { [weak self] in
            guard let self else { return }
            switch self.toolsState {
            case .drawAllTools:
                self.delegate?.exitImageButtonClicked()
            case .drawSpecificTools:
                self.toolsView.exitSpecificComponent()
            }
        })
        
        self.segmentsView.itemSelected = { [weak self] index in
            guard let self else { return }
            NotificationSystem.shared.fireEvent(.segmentTabChanged(index: index))
            self.segmentItemSelected?(index)
            
            if index == 1 {
                self.addObjectButton.updateState(state: .addText, animated: true)
                self.updateVisualState(.text, animated: true)
            } else {
                self.addObjectButton.updateState(state: .addShape, animated: true)
                self.updateVisualState(.tools, animated: true)
            }
        }
        
        self.textAligmentButton.addAction { [weak self] in
            guard let self else { return }
            let nextValue = self.textAligmentButton.alignState.next()
            self.textAligmentButton.updateStyle(alignState: nextValue, animated: true)
            NotificationSystem.shared.fireEvent(.changeTextAligment(aligment: nextValue))
        }
        
        self.textStyleButton.addAction(action: {
            [weak self] in
            guard let self else { return }
            let nextValue = self.textStyleButton.style.next()
            self.textStyleButton.updateStyle(style: nextValue, animated: true)
            NotificationSystem.shared.fireEvent(.changeTextStyle(style: nextValue))
        })
        
        self.toolsView.indexUpdating = { [weak self] index in
            guard let self else { return }
            
            if self.toolsView.selectedTool != .pen {
                NotificationSystem.shared.fireEvent(.showFeatureUnderDevelopment)
            } else {
                NotificationSystem.shared.fireEvent(.hideFeatureUnderDevelopment)
            }
            
            self.updateBrushColor()
        }
    }
    
    private func updateTextColor() {
        self.selectColorButton.isEnabled = true
    }
    
    private func updateBrushColor() {
        ToolbarSettings.shared.selectedTool = self.toolsView.selectedTool
        let index = self.toolsView.selectedToolIndex
        
        if index > 3 {
            self.selectColorButton.isEnabled = false
        } else {
            self.selectColorButton.isEnabled = true
            self.selectColorButton.colorPickerResult = ToolbarSettings.shared.getToolSetting(style: .fromTool(self.toolsView.selectedTool)).color
        }
    }
    
    var testFlag: Bool = true
    
    func toolsDetailsClicked() {
        switch self.toolsView.selectedTool {
        case .pen, .pencil, .brush, .neon:
            let items: [ContextMenuView.Item] = [
                .init(title: "Round", iconName: "roundTip"),
                .init(title: "Arrow", iconName: "arrowTip"),
            ]
            ContextMenuController.shared.showItems(items: items, fromView: self.toolDetailsButton, preferableWidth: 150) { [weak self] selectedIndex in
                guard let self else { return }
                let state = ToolbarSettings.ToolItem.State(rawValue: selectedIndex) ?? .round
                let settings = ToolbarSettings.shared.getToolSetting(style: .fromTool(self.toolsView.selectedTool))
                settings.state = state
                self.toolDetailsButton.setContent(style: .fromTool(state), animated: true)
                self.detailsStyle = .fromTool(state)
            }
        case .eraiser:
            let items: [ContextMenuView.Item] = [
                .init(title: "Eraser", iconName: "roundTip"),
                .init(title: "Object Eraser", iconName: "xmarkTip"),
                .init(title: "Background Blur", iconName: "blurTip"),
            ]
            ContextMenuController.shared.showItems(items: items, fromView: self.toolDetailsButton, preferableWidth: 194) { [weak self] index in
                guard let self else { return }
                let state = ToolEraserView.State(rawValue: index) ?? .eraser
                ToolbarSettings.shared.eraserSettings.mode = state
                self.toolsView.eraser.setState(state: ToolbarSettings.shared.eraserSettings.mode, animated: true)
                self.toolDetailsButton.setContent(style: .fromEraiser(state), animated: true)
                self.detailsStyle = .fromEraiser(state)
            }
        case .lasso:
            assertionFailure("Can't do this")
        }
    }
    
    var detailsStyle = SelectToolDetailsStyle.arrow
    
    override func layoutSubviewsOnChangeBounds() {
        self.sizeSegmentView.frame = CGRect(x: self.segmentsView.frame.origin.x, y: self.segmentsView.frame.origin.y + 2, width: self.segmentsView.frame.width - 50, height: 28)
        
        self.toolDetailsButton.isHidden = true
        self.toolDetailsButton.isUserInteractionEnabled = false
        
        self.toolDetailsButton.frame = CGRect(
            x: self.frame.width - 85,
            y: 0,
            width: 77,
            height: 22
        )
        self.toolDetailsButton.center.y = self.segmentsView.center.y
        
        self.toolDetailsButton.setContent(title: "Eraiser", imageName: "blurTip", animated: false)
    }
    
    private func animateSendButton(duration: TimeInterval, disapear: Bool) {
        if disapear {
            self.toolDetailsButton.cahngeContentIconVisiblity(isHidden: true)
            self.sendButton.animateFromFrame(style: self.detailsStyle, duration: duration)
            self.toolDetailsButton.animate(isAppear: false, duration: duration)
            self.toolDetailsButton.isUserInteractionEnabled = false
        } else {
//            let frame = self.hierarhyConvertFrame(self.toolDetailsButton.contentView?.icon.frame ?? .zero, from: self.toolDetailsButton.contentView ?? self.sendButton, to: self.sendButton)
            let frame = CGRect.init(x: 10.5, y: 5, width: 24, height: 24)
            self.sendButton.animateIntoFrame(frame: frame, style: self.detailsStyle, duration: duration) {
                self.toolDetailsButton.cahngeContentIconVisiblity(isHidden: false)
            }
            self.toolDetailsButton.cahngeContentIconVisiblity(isHidden: true)
            self.toolDetailsButton.isHidden = false
            self.toolDetailsButton.isUserInteractionEnabled = true
            self.toolDetailsButton.animate(isAppear: true, duration: duration)
        }
    }
    
    func showAllComponents() {
        self.toolsState = .drawAllTools
        
        self.cancelBackButton.switchToState(state: .cancel, duration: self.toolsView.tillMiddleDuration)
        
        self.animateSendButton(duration: self.toolsView.tillMiddleDuration, disapear: true)
        
        self.selectColorButton.animateButton(isHide: false, duration: self.toolsView.mainPartDuration)
        self.addObjectButton.animateButton(isHide: false, duration: self.toolsView.mainPartDuration)
        
        let frame = self.hierarhyConvertFrame(self.segmentsView.selectedView.frame, from: self.segmentsView, to: self.sizeSegmentView)
        self.sizeSegmentView.animateFromTumblerView(toFrame: frame, duration: self.toolsView.tillMiddleDuration, completionBlock: {
            self.sizeSegmentView.isHidden = true
            self.segmentsView.changeItemsVisible(isVisible: true)
        })
        
        self.sizeSegmentView.animateBackground(to: false, frame: self.segmentsView.bounds, duration: self.toolsView.tillMiddleDuration)
        self.segmentsView.switchAnimatedComponentsVisibility(isVisible: true, duration: self.toolsView.tillMiddleDuration)
    }
    
    func updateVisualState(_ state: VisualState, animated: Bool, firstLaunch: Bool = false) {
        if self.visualState == state && !firstLaunch {
            return
        }
        self.visualState = state
        
        switch state {
        case .tools:
            self.updateBrushColor()
            self.textAligmentButton.isUserInteractionEnabled = false
            self.textStyleButton.isUserInteractionEnabled = false
            self.toolsView.isUserInteractionEnabled = true
            
            if !firstLaunch {
                self.toolsView.showTools(delay: 0.12)
                self.animateTextButtons(isShow: false)
            }
        case .text:
            NotificationSystem.shared.fireEvent(.hideFeatureUnderDevelopment)
            self.updateTextColor()
            self.selectColorButton.isEnabled = false
            self.textAligmentButton.isHidden = false
            self.textAligmentButton.isUserInteractionEnabled = true
            self.textStyleButton.isHidden = false
            self.textStyleButton.isUserInteractionEnabled = true
            self.toolsView.isUserInteractionEnabled = false
            self.animateTextButtons(isShow: true)
            self.toolsView.hideTools()
        }
    }
    
    func animateTextButtons(isShow: Bool) {
        let fullValue = self.textAligmentButton.isEnabled ? 1 : 0.3
        let startValue: CGFloat = isShow ? 0 : fullValue
        let endValue: CGFloat = isShow ? fullValue : 0
        
        let startScaleValue: CGFloat = isShow ? 0 : 1
        let endScaleValue: CGFloat = isShow ? 1 : 0
        
        let delay: CGFloat = isShow ? 0.12 : 0
        
        self.textAligmentButton.layer.opacity = Float(endValue)
        self.textStyleButton.layer.opacity = Float(endValue)
        
        self.textAligmentButton.layer.transform = CATransform3DMakeScale(endScaleValue, endScaleValue, 1)
        self.textStyleButton.layer.transform = CATransform3DMakeScale(endScaleValue, endScaleValue, 1)
        
        self.textAligmentButton.layer.animateSpring(from: startScaleValue as NSNumber, to: endScaleValue as NSNumber, keyPath: "transform.scale", duration: 0.7, delay: delay)
        self.textAligmentButton.layer.animate(from: startValue as NSNumber, to: endValue as NSNumber, keyPath: "opacity", duration: 0.25, delay: delay)
        self.textStyleButton.layer.animateSpring(from: startScaleValue as NSNumber, to: endScaleValue as NSNumber, keyPath: "transform.scale", duration: 0.7, delay: delay)
        self.textStyleButton.layer.animate(from: startValue as NSNumber, to: endValue as NSNumber, keyPath: "opacity", duration: 0.25, delay: delay, completion: {
            success in
            if success && isShow == false {
                self.textStyleButton.isHidden = true
                self.textAligmentButton.isHidden = true
            }
        })
    }
}
