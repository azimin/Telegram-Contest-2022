//
//  SpecifiToolView.swift
//  Telegram-Contest-2022-R1
//
//  Created by Alexander Zimin on 11/10/2022.
//

import UIKit

class ToolView: View {
    enum Style: Int {
        case pen
        case brush
        case neon
        case pencil
        
        static func fromTool(_ tool: Tool) -> ToolView.Style {
            switch tool {
            case .pen:
                return .pen
            case .brush:
                return .brush
            case .neon:
                return .neon
            case .pencil:
                return .pencil
            case .lasso, .eraiser:
                return .pen
            }
        }
    }
    
    var baseImageView = UIImageView()
    var tipImageView = UIImageView()
    
    var tipSizeViewGradient = CAGradientLayer()
    var tipSizeView = UIView()
    var tipFrame: CGRect = .zero
    
    var sizeProgress: CGFloat = 0.3 {
        didSet {
            self.updateTipSize()
        }
    }
    
    var color: UIColor = .blue {
        didSet {
            self.updateColor()
        }
    }
    
    init(style: Style) {
        super.init(frame: .zero)
        
        self.addSubview(baseImageView)
        self.addSubview(tipImageView)
        self.addSubview(tipSizeView)
        
        switch style {
        case .pen:
            baseImageView.image = UIImage(named: "pen")
            tipImageView.image = UIImage(named: "pen_tip")
            tipFrame = .init(x: 1.5, y: 40, width: 17, height: 42)
            self.addClassicGradientToTip()
        case .neon:
            baseImageView.image = UIImage(named: "neon")
            tipImageView.image = UIImage(named: "neon_tip")
            tipFrame = .init(x: 1.5, y: 36, width: 17, height: 46)
            self.addClassicGradientToTip()
        case .brush:
            baseImageView.image = UIImage(named: "brush")
            tipImageView.image = UIImage(named: "brush_tip")
            tipFrame = .init(x: 1.5, y: 36, width: 17, height: 46)
            self.addClassicGradientToTip()
        case .pencil:
            baseImageView.image = UIImage(named: "pencil")
            tipImageView.image = UIImage(named: "pencil_tip")
            tipFrame = .init(x: 1.5, y: 40, width: 17, height: 42)
            self.addMiddleGradientToTip()
        }
        
        let size = CGSize(width: 20, height: 88)
        self.baseImageView.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        self.tipImageView.frame = self.baseImageView.bounds
        self.frame.size = size
        
        self.tipSizeView.layer.cornerRadius = 0.5
        
        let tool = ToolbarSettings.shared.getToolSetting(style: style)
        self.sizeProgress = tool.widthProgress
        self.color = tool.color
        
        self.updateColor()
        self.updateTipSize()
    }
    
    private func updateColor() {
        let img = self.tipImageView.image!
        self.tipImageView.image = img.withTintColor(color)
        self.tipSizeView.backgroundColor = color
    }
    
    private func updateTipSize() {
        var height = tipFrame.height * self.sizeProgress * 0.5
        height = max(height, 2)
        
        self.tipSizeView.frame = self.tipFrame
        self.tipSizeView.frame.size.height = height
        
        CATransaction.begin()
        CATransaction.setValue(true, forKey: kCATransactionDisableActions)
        self.tipSizeViewGradient.frame = self.tipSizeView.bounds
        CATransaction.commit()
    }
    
    private func addClassicGradientToTip() {
        let gradient = CAGradientLayer()
        gradient.cornerRadius = 0.5
        let cornerColor = UIColor.black.withAlphaComponent(0.2).cgColor
        let innerColor = UIColor.black.withAlphaComponent(0).cgColor
//        let cornerColor = UIColor.red.cgColor
//        let innerColor = UIColor.red.withAlphaComponent(0).cgColor
        gradient.colors = [cornerColor, innerColor, innerColor, cornerColor]
        gradient.locations = [0, 0.15, 0.85, 1]
        gradient.startPoint = .init(x: 0, y: 0.5)
        gradient.endPoint = .init(x: 1, y: 0.5)
        
        self.tipSizeView.layer.insertSublayer(gradient, at: 0)
        self.tipSizeViewGradient = gradient
    }
    
    private func addMiddleGradientToTip() {
        let gradient = CAGradientLayer()
        let cornerColor = UIColor.white.withAlphaComponent(0).cgColor
        let innerColor = UIColor.white.withAlphaComponent(0.2).cgColor
//        let cornerColor = UIColor.red.withAlphaComponent(0).cgColor
//        let innerColor = UIColor.red.withAlphaComponent(1).cgColor
        gradient.colors = [UIColor.white.withAlphaComponent(0), cornerColor, innerColor, innerColor, cornerColor, UIColor.white.withAlphaComponent(0)]
        gradient.locations = [0, 0.245, 0.265, 0.735, 0.755, 1]
        gradient.startPoint = .init(x: 0, y: 0.5)
        gradient.endPoint = .init(x: 1, y: 0.5)
        
        self.tipSizeView.layer.insertSublayer(gradient, at: 0)
        self.tipSizeViewGradient = gradient
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
