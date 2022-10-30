//
//  TopControlsView.swift
//  Telegram-Contest-2022-R1
//
//  Created by Alexander Zimin on 28/10/2022.
//

import UIKit

class TopControlsView: View {
    let undoButton = Button()
    let clearAllButton = Button()
    let zoomOutButton = UIButton()
    let cancelButton = Button()
    let doneButton = Button()
    
    var hasChanges: Bool = false {
        didSet {
            self.updateState()
        }
    }
    
    enum TextEnterState {
        case none
        case firstTime
        case edit
        
        var isActive: Bool {
            switch self {
            case .none:
                return false
            case .firstTime, .edit:
                return true
            }
        }
    }
    
    var isTextEnterState: TextEnterState = .none {
        didSet {
            self.updateState()
        }
    }
    
    var hasZoom: Bool = false {
        didSet {
            self.updateState()
        }
    }
    
    override func setUp() {
        self.addSubview(undoButton)
        self.addSubview(clearAllButton)
        self.addSubview(cancelButton)
        self.addSubview(doneButton)
        
        undoButton.backgroundColor = UIColor.black.withAlphaComponent(0.01)
        undoButton.setImage(image: UIImage(named: "undo"), inSize: .init(width: 24, height: 24), forState: .normal)
        clearAllButton.setTitle("Clear All", for: .normal)
        clearAllButton.titleLabel?.font = UIFont.sfProTextRegular(17)
        
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.titleLabel?.font = UIFont.sfProTextRegular(17)
        
        doneButton.setTitle("Done", for: .normal)
        doneButton.titleLabel?.font = UIFont.sfProTextSemibold(17)
        
        self.undoButton.autolayout {
            self.undoButton.constraintSize(width: 44, height: 44)
            self.undoButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 4).activate()
            self.undoButton.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0).activate()
        }
        
        self.cancelButton.autolayout {
            self.cancelButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 12).activate()
            self.cancelButton.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0).activate()
        }
        
        self.clearAllButton.autolayout {
            self.clearAllButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -12).activate()
            self.clearAllButton.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0).activate()
        }
        
        self.doneButton.isExclusiveTouch = true
        self.doneButton.autolayout {
            self.doneButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -12).activate()
            self.doneButton.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0).activate()
        }
        
        self.updateState()
        
        NotificationSystem.shared.subscribeOnEvent(self) { [weak self] event in
            switch event {
            case let .textPresentationStateChanged(isPresenting):
                let isNextStepIsOpen = TextPresentationController.shared.isNextStepIsOpen
                if isPresenting {
                    self?.isTextEnterState = isNextStepIsOpen ? .firstTime : .edit
                } else {
                    self?.isTextEnterState = .none
                }
            default:
                break
            }
        }
    }
    
    func updateState() {
        self.undoButton.isHidden = true
        self.clearAllButton.isHidden = true
        self.zoomOutButton.isHidden = true
        self.cancelButton.isHidden = true
        self.doneButton.isHidden = true
        
        self.cancelButton.isUserInteractionEnabled = false
        self.doneButton.isUserInteractionEnabled = false
        
        if self.hasZoom && self.isTextEnterState.isActive == false {
            self.zoomOutButton.isHidden = false
        }
        
        self.undoButton.isEnabled = self.hasChanges
        self.clearAllButton.isEnabled = self.hasChanges
        
        if self.isTextEnterState.isActive {
            if self.isTextEnterState == .firstTime {
                self.cancelButton.isHidden = false
                self.cancelButton.isUserInteractionEnabled = true
            }
            self.doneButton.isHidden = false
            self.doneButton.isUserInteractionEnabled = true
        } else {
            self.undoButton.isHidden = false
            self.clearAllButton.isHidden = false
        }
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let value = super.hitTest(point, with: event)
        
        if self.point(inside: point, with: event) {
            if value is UIButton {
                return value
            }
            return nil
        }
 
        return value
    }
}
