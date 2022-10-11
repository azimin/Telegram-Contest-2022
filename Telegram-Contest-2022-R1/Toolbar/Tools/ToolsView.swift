//
//  ToolsView.swift
//  Telegram-Contest-2022-R1
//
//  Created by Alexander Zimin on 11/10/2022.
//

import UIKit

class ToolsView: View {
    enum State {
        case allComponents
        case componentPresented
    }
    
    let shadowImageView = UIImageView()
    private let contentMaskView = UIView()
    
    private var selectedToolIndex = 0
    
    func selectTool(index: Int, animated: Bool) {
        if self.selectedToolIndex == index {
            return
        }
        self.updateSelectedTool(oldValue: self.selectedToolIndex, newValue: index, animated: animated)
        self.selectedToolIndex = index
    }
    
    var tools: [UIView] = []
    
    override func setUp() {
        let pen = ToolView(style: .pencil)
        let brush = ToolView(style: .brush)
        let neon = ToolView(style: .neon)
        let pencil = ToolView(style: .pencil)
        let lasso = ToolLassoView()
        let eraser = ToolEraserView()
        
        self.tools = [pen, brush, neon, pencil, lasso, eraser]
        for tool in self.tools {
            self.addSubview(tool)
        }
        
        self.contentMaskView.backgroundColor = .black
        self.mask = self.contentMaskView
        
        self.addSubview(self.shadowImageView)
        self.shadowImageView.image = UIImage(named: "toolsShadow")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let superviewFrame = self.superview?.frame ?? .zero
        let delta = (superviewFrame.width - self.frame.width) / 2
        
        self.contentMaskView.frame = CGRect(x: -delta, y: 0, width: superviewFrame.width, height: self.frame.height)
        self.shadowImageView.frame = CGRect(x: -delta, y: self.frame.height - 16, width: superviewFrame.width, height: 32)
        
        let space = ((self.frame.width - 36) - (20 * 6)) / 5
        for (index, tool) in self.tools.enumerated() {
            let x = 18 + 20 * CGFloat(index) + space * CGFloat(index)
            let y: CGFloat = (self.selectedToolIndex == index) ? 0 : 16
            tool.frame = CGRect(
                x: x,
                y: 20 + y,
                width: 20,
                height: 88
            )
        }
    }
    
    private func updateSelectedTool(oldValue: Int, newValue: Int, animated: Bool) {
        let oldTool = self.tools[oldValue]
        let newTool = self.tools[newValue]
        
        var updatedOldFrame = oldTool.frame
        updatedOldFrame.origin.y = 20
        
        var updatedNewFrame = newTool.frame
        updatedNewFrame.origin.y = 36
        
        oldTool.layer.animateFrame(from: oldTool.frame, to: updatedOldFrame, duration: animated ? 0.1 : 0)
        newTool.layer.animateFrame(from: newTool.frame, to: updatedNewFrame, duration: animated ? 0.1 : 0)
    }
}
