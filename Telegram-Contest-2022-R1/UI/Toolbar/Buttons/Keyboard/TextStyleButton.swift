//
//  TextStyleButton.swift
//  Telegram-Contest-2022-R1
//
//  Created by Alexander Zimin on 28/10/2022.
//

import UIKit

class TextStyleButton: Button {
    typealias Style = TextLabelView.BackgroundStyle
    var style: Style = .none
    
    let contentImageView = UIImageView()
    
    override func setUp() {
        self.addSubview(self.contentImageView)
    }
    
    override func layoutSubviewsOnChangeBounds() {
        self.updateStyle(style: self.style, animated: false)
        self.contentImageView.frame = CGRect(
            x: (self.frame.width - 30) / 2,
            y: (self.frame.height - 30) / 2,
            width: 30,
            height: 30
        )
    }
    
    func updateStyle(style: Style, animated: Bool) {
        self.style = style
        
        if animated == false {
            self.contentImageView.image = style.iconImage
            return
        }
        
        UIView.transition(with: self.contentImageView, duration: 0.2, options: .transitionCrossDissolve) {
            self.contentImageView.image = style.iconImage
        }
    }
}

