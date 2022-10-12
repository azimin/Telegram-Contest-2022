//
//  EditToolbarView.swift
//  Telegram-Contest-2022-R1
//
//  Created by Alexander Zimin on 10/10/2022.
//

import UIKit

class EditToolbarView: View {
    enum State {
        case draw
    }
    
    let cancelBackButton = CancelBackButton()
    let sendButton = SendButton()
    let selectColorButton = SelectColorButton()
    let addObjectButton = AddObjectButton()
    
    let toolsView = ToolsView()
    let sizeSegmentView = SizeSegmentView()
    let segmentsView = EditToolbarSegmentView(items: [.init(text: "Draw"), .init(text: "Text")])
    
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
        
        self.layer.speed = 0.1
        self.toolsView.stateUpdating = { [weak self] state in
            guard let self else { return }
            switch state {
            case .componentPresented:
                self.selectColorButton.animateButton(isHide: true, duration: self.toolsView.mainPartDuration)
                self.addObjectButton.animateButton(isHide: true, duration: self.toolsView.mainPartDuration)
                
                let frame = self.hierarhyConvertFrame(self.segmentsView.selectedView.frame, from: self.segmentsView, to: self.sizeSegmentView)
                
                self.sizeSegmentView.isHidden = false
                self.sizeSegmentView.animateIntoTumblerView(
                    fromFrame: frame,
                    toProgress: 0.6,
                    duration: self.toolsView.tillMiddleDuration
                )
                
                self.sizeSegmentView.animateBackground(to: true, frame: self.segmentsView.bounds, duration: self.toolsView.tillMiddleDuration)
                
                self.segmentsView.switchAnimatedComponentsVisibility(isVisible: false, duration: self.toolsView.tillMiddleDuration)
                
            case .allComponents:
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
    }
    
    override func layoutSubviewsOnChangeBounds() {
        self.sizeSegmentView.frame = CGRect(x: self.segmentsView.frame.origin.x, y: self.segmentsView.frame.origin.y + 2, width: self.segmentsView.frame.width - 50, height: 28)
    }
}
