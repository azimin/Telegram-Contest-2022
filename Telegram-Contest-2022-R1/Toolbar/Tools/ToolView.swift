//
//  SpecifiToolView.swift
//  Telegram-Contest-2022-R1
//
//  Created by Alexander Zimin on 11/10/2022.
//

import UIKit

class ToolView: View {
    enum Style {
        case pen
        case brush
        case neon
        case pencil
        case lasso
    }
    
    var baseImageView = UIImageView()
    var tipImageView = UIImageView()
    var secondTipImageView = UIImageView()
    var tipShadowImageView = UIImageView()
    
    var color: UIColor = .red {
        didSet {
            self.updateColor()
        }
    }
    
    init(style: Style) {
        let size: CGSize
        super.init(frame: .zero)
        
        self.addSubview(baseImageView)
        self.addSubview(tipImageView)
        self.addSubview(secondTipImageView)
        self.addSubview(tipShadowImageView)
        
        switch style {
        case .pen:
            baseImageView.image = UIImage(named: "pen")
            size = .init(width: 20, height: 88)
            let tipFrame = CGRect(x: 1.5, y: 6.75, width: 17, height: 35.25)
            tipImageView.image = UIImage(named: "pen_tip")
            tipImageView.frame = tipFrame
            tipShadowImageView.image = UIImage(named: "pen_shadow")
            tipShadowImageView.frame = tipFrame
        case .neon:
            baseImageView.image = UIImage(named: "neon")
            size = .init(width: 20, height: 72)
            let tipFrame = CGRect(x: 1.5, y: 6.4, width: 17, height: 43.59)
            tipImageView.image = UIImage(named: "neon_tip_2")
            tipImageView.frame = tipFrame
            tipShadowImageView.image = UIImage(named: "neon_shadow")
            tipShadowImageView.frame = tipFrame
            secondTipImageView.image = UIImage(named: "neon_tip")
            secondTipImageView.frame = CGRect(x: 0, y: 0, width: 20, height: 88)
        default:
            size = .zero
            break
        }
        
        self.baseImageView.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        self.frame.size = size
        
        self.updateColor()
    }
    
    private func updateColor() {
        let img = self.tipImageView.image!
        self.tipImageView.image = img.withTintColor(color)
        
        if let img = self.secondTipImageView.image {
            self.secondTipImageView.image = img.withTintColor(color)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
