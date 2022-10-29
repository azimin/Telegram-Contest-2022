//
//  ToolsView.swift
//  Telegram-Contest-2022-R1
//
//  Created by Alexander Zimin on 11/10/2022.
//

import UIKit

enum Tool: Int, CaseIterable {
    case pen
    case brush
    case neon
    case pencil
    case lasso
    case eraiser
}

class ToolsView: View {
    var animationDuration: TimeInterval = 0.8
    lazy var mainPartDuration: TimeInterval = self.animationDuration * 0.18
    lazy var tillMiddleDuration: TimeInterval = self.animationDuration * 0.27
    
    enum State {
        case allComponents
        case componentPresented
    }
    
    var stateUpdating: ((State) -> Void)?
    var indexUpdating: IndexBlock?
    
    let shadowImageView = UIImageView()
    private let contentMaskView = UIView()
    
    private(set) var selectedToolIndex = 0 {
        didSet {
            if self.selectedToolIndex != oldValue {
                self.indexUpdating?(selectedToolIndex)
            }
        }
    }
    var selectedTool: Tool {
        return Tool(rawValue: self.selectedToolIndex) ?? .pen
    }
    
    var eraser: ToolEraserView {
        return self.tools[5] as! ToolEraserView
    }
    
    func selectTool(index: Int, animated: Bool) {
        if self.selectedToolIndex == index {
            return
        }
        self.updateSelectedTool(oldValue: self.selectedToolIndex, newValue: index, animated: animated)
        self.selectedToolIndex = index
    }
    
    func updateProgress(value: CGFloat) {
        let tool = self.tools[self.selectedToolIndex]
        if let toolView = tool as? ToolView {
            toolView.sizeProgress = value
        }
    }
    
    func updateToolColor(_ value: ColorPickerResult) {
        let tool = self.tools[self.selectedToolIndex]
        if let toolView = tool as? ToolView {
            toolView.color = value
        }
    }
    
    var tools: [UIView] = []
    
    override func setUp() {
        let pen = ToolView(style: .pen)
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
        
        self.touchReportsIndex = .init(
            itemsCount: 6,
            isVertical: false,
            canSelectMultiple: true,
            highlited: { [weak self] index in
                self?.highlight(index: index)
            },
            selected: { [weak self] index in
                self?.selected(index: index)
            }
        )
    }
    
    var preveousFrame: CGRect = .zero
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if self.frame == self.preveousFrame {
            return
        }
        
        if self.isComponentPresented {
            // TODO: Think about return in state
            return
        }
        
        self.preveousFrame = self.frame
        
        let superviewFrame = self.superview?.frame ?? .zero
        let delta = (superviewFrame.width - self.frame.width) / 2
        
        self.contentMaskView.frame = CGRect(x: -delta, y: -30, width: superviewFrame.width, height: self.frame.height + 30)
        self.shadowImageView.frame = CGRect(x: -delta, y: self.frame.height - 16, width: superviewFrame.width, height: 16)
        
        let space = ((self.frame.width - 36) - (20 * 6)) / 5
        for (index, tool) in self.tools.enumerated() {
            let x = 18 + 20 * CGFloat(index) + space * CGFloat(index)
            tool.frame = CGRect(
                x: x,
                y: 20,
                width: 20,
                height: 88
            )
            self.moveTool(index: index, shouldIgnoreActive: false, state: index == self.selectedToolIndex ? .selected : .none, animated: false)
        }
    }
    
    private func updateSelectedTool(oldValue: Int, newValue: Int, animated: Bool) {
        self.moveTool(index: oldValue, shouldIgnoreActive: false, state: .none, animated: animated)
        self.moveTool(index: newValue, shouldIgnoreActive: false, state: .selected, animated: animated)
    }
    
    var preveousHighlight: Int? = nil
    
    private func highlight(index: Int?) {
        if self.isComponentPresented {
            return
        }
        
        if let index = self.preveousHighlight {
            self.moveTool(index: index, shouldIgnoreActive: true, state: .none, animated: true)
        }
        
        self.preveousHighlight = index
        if let index = index {
            self.moveTool(index: index, shouldIgnoreActive: true, state: .highlight, animated: true)
        }
    }
    
    private func selected(index: Int) {
        if self.isComponentPresented {
            self.exitSpecificComponent()
            return
        }
        
        if self.selectedToolIndex == index && self.selectedTool != .lasso {
            self.showSpecificComponent(index: index)
        } else {
            self.selectTool(index: index, animated: true)
        }
    }
    
    enum CoordinateState {
        case selected
        case highlight
        case none
    }
    
    private func moveTool(index: Int?, shouldIgnoreActive: Bool, state: CoordinateState, animated: Bool) {
        guard let index = index else { return }
//        self.layer.speed = 0.25
        
        if (shouldIgnoreActive && index == self.selectedToolIndex) {
            return
        }
        
        let tool = self.tools[index]
        
        let movement: CGFloat
        switch state {
        case .selected:
            movement = 0
        case .highlight:
            movement = 12
        case .none:
            movement = 16
        }
        
        if animated {
            var initialY: CGFloat = tool.transform.ty
            if let transform = tool.layer.presentation()?.value(forKey: "transform") as? CATransform3D {
                initialY = transform.m42
            }
            
            tool.layer.transform = CATransform3DMakeTranslation(0, movement, 0)
            tool.layer.animateSpring(from: initialY as NSNumber, to: movement as NSNumber, keyPath: "transform.translation.y", duration: state == .highlight ? 0.25 : 0.5, damping: state == .highlight ? 90 : 62)
        } else {
            let transform = CATransform3DMakeTranslation(0, movement, 0)
            tool.layer.transform = transform
        }
    }
    
    private var isComponentPresented = false
    private var presentedCoponentInfo: PresentedCoponentInfo?
    
    private class PresentedCoponentInfo {
        var index: Int
        var xDelta: CGFloat
        
        init(index: Int, xDelta: CGFloat) {
            self.index = index
            self.xDelta = xDelta
        }
    }
    
    func exitSpecificComponent() {
        guard let info = self.presentedCoponentInfo else {
            assertionFailure("Can't exit")
            return
        }
        self.stateUpdating?(.allComponents)
        
        var scale: CGFloat = 2
        var delta = info.xDelta
        let tool = self.tools[info.index]
        
        if let transform = tool.layer.presentation()?.value(forKey: "transform") as? CATransform3D {
            delta = transform.m41
            scale = transform.m22
        }
        
        tool.layer.animateSpring(from: scale as NSNumber, to: 1 as NSNumber, keyPath: "transform.scale", duration: self.animationDuration, removeOnCompletion: false)
        tool.layer.animateSpring(from: delta as NSNumber, to: 0 as NSNumber, keyPath: "transform.translation.x", duration: self.animationDuration, damping: 80, removeOnCompletion: false)
        
        self.isComponentPresented = false
        
        let toolIndex = self.getToolIndex(tool: tool)
        let delaysMap = self.getDelayMap(tool: tool)
        let otherDuration = self.mainPartDuration
        
        var frame = self.shadowImageView.frame
        frame.size.height = 16
        frame.origin.y += 16
        self.shadowImageView.layer.animateFrame(from: self.shadowImageView.frame, to: frame, duration: otherDuration)
        self.shadowImageView.frame = frame
        
        for (index, otherTool) in self.tools.enumerated() {
            if otherTool == tool {
                continue
            }
            
            let delayIndex = abs(index - toolIndex)
            let newDelayIndex = 1 - (delaysMap[delayIndex] ?? 0)
            let delay = newDelayIndex * otherDuration * 0.8
            
            otherTool.layer.removeAllAnimations()
            otherTool.layer.transform = CATransform3DMakeTranslation(0, 16, 0)
            
            var initialY: CGFloat = 86
            if let transform = otherTool.layer.presentation()?.value(forKey: "transform") as? CATransform3D {
                initialY = transform.m42
            }
            
            otherTool.layer.animateSpring(from: delta as NSNumber, to: 0 as NSNumber, keyPath: "transform.translation.x", duration: self.animationDuration, damping: 80)
            otherTool.layer.animateSpring(from: initialY as NSNumber, to: 16 as NSNumber, keyPath: "transform.translation.y", duration: self.animationDuration * 0.9, delay: delay, damping: 72)
        }
    }
    
    private func showSpecificComponent(index: Int) {
        self.isComponentPresented = true
        self.stateUpdating?(.componentPresented)
        
        let tool = self.tools[index]
        let delta = (self.frame.width / 2) - tool.frame.midX
        
        self.presentedCoponentInfo = .init(index: index, xDelta: delta)
        
        tool.layer.animateSpring(from: 1 as NSNumber, to: 2 as NSNumber, keyPath: "transform.scale", duration: self.animationDuration, removeOnCompletion: false)
        tool.layer.animateSpring(from: 0 as NSNumber, to: delta as NSNumber, keyPath: "transform.translation.x", duration: self.animationDuration, damping: 80, removeOnCompletion: false)
        
        let toolIndex = self.getToolIndex(tool: tool)
        let delaysMap = self.getDelayMap(tool: tool)
        
        var frame = self.shadowImageView.frame
        frame.size.height = 32
        frame.origin.y -= 16
        self.shadowImageView.layer.animateFrame(from: self.shadowImageView.frame, to: frame, duration: self.mainPartDuration)
        self.shadowImageView.frame = frame
        
        
        for (index, otherTool) in self.tools.enumerated() {
            if otherTool == tool {
                continue
            }
            
            let delayIndex = abs(index - toolIndex)
            let delay = (delaysMap[delayIndex] ?? 0) * self.mainPartDuration * 0.8
            
            otherTool.layer.removeAllAnimations()
            otherTool.layer.transform = CATransform3DMakeTranslation(delta, 86, 0)
            
            otherTool.layer.animateSpring(from: 0 as NSNumber, to: delta as NSNumber, keyPath: "transform.translation.x", duration: self.animationDuration, damping: 80)
            otherTool.layer.animate(from: 16 as NSNumber, to: 86 as NSNumber, keyPath: "transform.translation.y", timingFunction: CAMediaTimingFunctionName.easeOut.rawValue, duration: self.mainPartDuration, delay: delay, mediaTimingFunction: CAMediaTimingFunction(controlPoints: 0.65, 0, 0.35, 1))
        }
    }
    
    func getToolIndex(tool: UIView) -> Int {
        return self.tools.firstIndex(of: tool) ?? 0
    }
    
    func getDelayMap(tool: UIView) -> [Int: CGFloat] {
        let toolIndex = self.getToolIndex(tool: tool)
        
        var delays: [Int] = []
        var delaysMap: [Int: CGFloat] = [:]
        
        for (index, otherTool) in self.tools.enumerated() {
            if otherTool == tool {
                continue
            }
            let delayIndex = abs(index - toolIndex)
            delays.append(delayIndex)
        }
        let maxDelay = delays.max() ?? 0
        let minDelay = delays.min() ?? 0
        let delayDelta = maxDelay - minDelay
        
        for delay in delays {
            delaysMap[delay] = CGFloat(maxDelay - delay) / CGFloat(delayDelta)
        }
        return delaysMap
    }
    
    func hideTools() {
        for (index, otherTool) in self.tools.enumerated() {
            let delay = CGFloat(index) * self.mainPartDuration * 0.3
            
            otherTool.layer.removeAllAnimations()
            otherTool.layer.transform = CATransform3DMakeTranslation(0, 86, 0)
            
            var initialY: CGFloat = 16
            if let transform = otherTool.layer.presentation()?.value(forKey: "transform") as? CATransform3D {
                initialY = transform.m42
            }

            otherTool.layer.animate(from: initialY as NSNumber, to: 86 as NSNumber, keyPath: "transform.translation.y", timingFunction: CAMediaTimingFunctionName.easeOut.rawValue, duration: self.mainPartDuration * 1.3, delay: delay, mediaTimingFunction: CAMediaTimingFunction(controlPoints: 0.65, 0, 0.35, 1)) { success in
                if success && index == self.tools.count - 1 {
                    self.isHidden = true
                }
            }
        }
    }
    
    func showTools(delay basicDelay: CGFloat) {
        self.isHidden = false
        for (index, otherTool) in self.tools.enumerated() {
            let delay = CGFloat(index) * self.mainPartDuration * 0.3
            
            let target: CGFloat = index == self.selectedToolIndex ? 0 : 16
            
            otherTool.layer.removeAllAnimations()
            otherTool.layer.transform = CATransform3DMakeTranslation(0, target, 0)
            
            var initialY: CGFloat = 86
            if let transform = otherTool.layer.presentation()?.value(forKey: "transform") as? CATransform3D {
                initialY = transform.m42
            }
            
            otherTool.layer.animateSpring(from: initialY as NSNumber, to: target as NSNumber, keyPath: "transform.translation.y", duration: self.animationDuration * 0.9, delay: delay + basicDelay, damping: 72)
        }
    }
}
