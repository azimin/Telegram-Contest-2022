//
//  TextSelectionController.swift
//  TextExperiment
//
//  Created by Alexander Zimin on 27/10/2022.
//

import UIKit

class TextSelectionController {
    static var shared = TextSelectionController()
    var labelsContentView: UIView?
    
    var selectedText: TextLabelView?
    
    func selectText(selectedText: TextLabelView) {
        if selectedText == self.selectedText {
            return
        }
        
        self.deselectText()
        selectedText.isSelected = true
        self.selectedText = selectedText
        
        let index = self.labelsContentView?.subviews.count ?? 1
        self.labelsContentView?.insertSubview(selectedText, at: index - 1)
        
        NotificationSystem.shared.fireEvent(.textSelectionStateChanged(isSelected: true))
    }
    
    func deselectText() {
        UIMenuController.shared.hideMenu()
        self.selectedText?.isSelected = false
        self.selectedText = nil
        
        NotificationSystem.shared.fireEvent(.textSelectionStateChanged(isSelected: false))
    }
}
