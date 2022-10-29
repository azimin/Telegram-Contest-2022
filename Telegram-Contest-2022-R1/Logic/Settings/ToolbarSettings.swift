//
//  ToolbarSettings.swift
//  Telegram-Contest-2022-R1
//
//  Created by Alexander Zimin on 13/10/2022.
//

import Foundation

class ToolbarSettings {
    static var shared = ToolbarSettings()
    
    var selectedTool: Tool = .pen

    class ToolItem {
        enum State: Int {
            case round
            case arrow
        }
        
        var widthProgress: CGFloat
        var color: ColorPickerResult
        var state: State
        
        init(widthProgress: CGFloat, color: ColorPickerResult, state: State = .round) {
            self.widthProgress = widthProgress
            self.color = color
            self.state = state
        }
        
        func reset() {
            self.state = .round
        }
    }
    
    class Eraser {
        typealias Mode = ToolEraserView.State
        
        var widthProgress: CGFloat
        var mode: Mode
        
        init(widthProgress: CGFloat, mode: Mode = .eraser) {
            self.widthProgress = widthProgress
            self.mode = mode
        }
        
        func reset() {
            self.mode = .eraser
        }
    }
    
    var toolsSettings: [ToolView.Style: ToolItem] = [:]
    var eraserSettings: Eraser
    
    func getToolSetting(style: ToolView.Style) -> ToolItem {
        return self.toolsSettings[style] ?? self.toolsSettings[.pen]!
    }
    
    init() {
        self.toolsSettings = [
            .pen: .init(widthProgress: 0.3, color: .white),
            .brush: .init(widthProgress: 0.5, color: .yellow),
            .neon: .init(widthProgress: 0.7, color: .green),
            .pencil: .init(widthProgress: 0.5, color: .blue)
        ]
        self.eraserSettings = .init(widthProgress: 0.5)
    }
    
    func reset() {
        self.toolsSettings.values.forEach({ $0.reset() })
        self.eraserSettings.reset()
    }
}
