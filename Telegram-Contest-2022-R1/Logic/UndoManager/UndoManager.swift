//
//  UndoManager.swift
//  Telegram-Contest-2022-R1
//
//  Created by Alexander Zimin on 30/10/2022.
//

import Foundation

typealias TextInfo = TextLabelView.TextInfo

class UndoManager {
    static var shared = UndoManager()
    
    var undoManagerUpdated: VoidBlock?
    
    enum Action {
        case drawMetalLine
        case createdText(id: Int)
        case deleteText(id: Int, textInfo: TextInfo)
    }
    
    var actions: [Action] = []
    var lastActionCreate: TimeInterval = 0
    var saved: Bool = false
    
    func addAction(_ action: Action) {
        var shouldRemove = false
        
        switch action {
        case let .deleteText(id, info):
            if let last = self.actions.last {
                switch last {
                case let .createdText(oldId):
                    if oldId == id && info.transform.m41 == 0 && info.transform.m42 == 0 {
                        let delta = CACurrentMediaTime() - lastActionCreate
                        if delta < 10 {
                            shouldRemove = true
                        }
                    }
                default:
                    break
                }
            }
        default:
            break
        }
        
        self.saved = false
        if shouldRemove {
            self.actions.removeLast()
            self.undoManagerUpdated?()
        } else {
            self.lastActionCreate = CACurrentMediaTime()
            self.actions.append(action)
            self.undoManagerUpdated?()
        }
    }
    
    func clearAll() {
        self.saved = false
        self.actions.removeAll()
        self.undoManagerUpdated?()
    }
    
    func removeCreateEvent(removeId: Int) {
        self.actions.removeAll { action in
            switch action {
            case .createdText(let id):
                return id == removeId
            default:
                return false
            }
        }
        self.undoManagerUpdated?()
    }
    
    func undo() {
        if self.actions.isEmpty {
            return
        }
        self.saved = false
        let last = self.actions.removeLast()
        switch last {
        case .drawMetalLine:
            NotificationSystem.shared.fireEvent(.undoMetalLine)
        case let .createdText(id):
            TextPresentationController.shared.getTextView(id: id)?.deleteAction(shouldAddToUndo: false)
        case let .deleteText(id, textInfo):
            TextLabelView.recreateLabelAction(info: textInfo, id: id)
        }
        self.undoManagerUpdated?()
    }
}
