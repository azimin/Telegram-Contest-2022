//
//  EditToolbarView.swift
//  Telegram-Contest-2022-R1
//
//  Created by Alexander Zimin on 10/10/2022.
//

import UIKit

class EditToolbarView: View {
    enum State {
        case drawAllTools
        case drawSpecificTools
    }
    
    var state: State = .drawAllTools
    
    let cancelBackButton = CancelBackButton()
    let sendButton = SendButton()
    let selectColorButton = SelectColorButton()
    let addObjectButton = AddObjectButton()
    
    let toolsView = ToolsView()
    let sizeSegmentView = SizeSegmentView()
    let segmentsView = EditToolbarSegmentView(items: [.init(text: "Draw"), .init(text: "Text")])
    
    let toolDetailsButton = SelectToolDetailsButton()
    
    override func setUp() {
        self.autolayout {
            self.constraintSize(width: nil, height: 149)
        }
        
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
        
        self.layer.speed = Float(CALayer.currentSpeed())
        
        self.toolsView.stateUpdating = { [weak self] state in
            guard let self else { return }
            switch state {
            case .componentPresented:
                self.state = .drawSpecificTools
                
                self.cancelBackButton.switchToState(state: .back, duration: self.toolsView.tillMiddleDuration)
                
                self.detailsStyle = self.detailsStyle.getNextSrtyle()
                
                self.toolDetailsButton.setContent(style: self.detailsStyle, animated: false)
                
                self.selectColorButton.animateButton(isHide: true, duration: self.toolsView.mainPartDuration)
                self.addObjectButton.animateButton(isHide: true, duration: self.toolsView.mainPartDuration)
                
                let frame = self.hierarhyConvertFrame(self.segmentsView.selectedView.frame, from: self.segmentsView, to: self.sizeSegmentView)
                
                self.sizeSegmentView.isHidden = false
                self.sizeSegmentView.animateIntoTumblerView(
                    fromFrame: frame,
                    toProgress: CGFloat.random(in: 0.1..<0.95),
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
    }
    
    func addActions() {
        self.addObjectButton.addAction(action: { [weak self] in
            guard let self else { return }
            let items: [ContextMenuView.Item] = [.init(title: "Rectangle", iconName: "shapeRectangle"), .init(title: "Bubble", iconName: "shapeStar"), .init(title: "Ellipse", iconName: "shapeEllipse")]
            ContextMenuController.shared.showItems(items: items, fromView: self.addObjectButton)
        })
        
        self.cancelBackButton.addAction(action: { [weak self] in
            guard let self else { return }
            switch self.state {
            case .drawAllTools:
                break
            case .drawSpecificTools:
                self.toolsView.exitSpecificComponent()
            }
        })
    }
    
    var detailsStyle = SelectToolDetailsStyle.arrow
    
    override func layoutSubviewsOnChangeBounds() {
        self.sizeSegmentView.frame = CGRect(x: self.segmentsView.frame.origin.x, y: self.segmentsView.frame.origin.y + 2, width: self.segmentsView.frame.width - 50, height: 28)
        
        self.toolDetailsButton.isHidden = true
        
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
        } else {
//            let frame = self.hierarhyConvertFrame(self.toolDetailsButton.contentView?.icon.frame ?? .zero, from: self.toolDetailsButton.contentView ?? self.sendButton, to: self.sendButton)
            let frame = CGRect.init(x: 10.5, y: 5, width: 24, height: 24)
            self.sendButton.animateIntoFrame(frame: frame, style: self.detailsStyle, duration: duration) {
                self.toolDetailsButton.cahngeContentIconVisiblity(isHidden: false)
            }
            self.toolDetailsButton.cahngeContentIconVisiblity(isHidden: true)
            self.toolDetailsButton.isHidden = false
            self.toolDetailsButton.animate(isAppear: true, duration: duration)
        }
    }
    
    func showAllComponents() {
        self.state = .drawAllTools
        
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
}
