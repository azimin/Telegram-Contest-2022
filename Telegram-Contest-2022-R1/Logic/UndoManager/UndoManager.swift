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
    
    func addAction(_ action: Action) {
        self.actions.append(action)
        self.undoManagerUpdated?()
    }
    
    func clearAll() {
        self.actions.removeAll()
        self.undoManagerUpdated?()
    }
    
    func undo() {
        if self.actions.isEmpty {
            return
        }
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
