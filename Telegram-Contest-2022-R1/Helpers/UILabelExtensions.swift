//
//  UILabel+Extensions.swift
//  Telegram-Contest-2022-R1
//
//  Created by Alexander Zimin on 13/10/2022.
//

import UIKit

extension UILabel {
    enum TgKern: CGFloat {
        case m041 = -0.41
        case m008 = -0.08
    }
    
    func setText(string: String, kern: CGFloat) {
        let attributedString = NSAttributedString(string: string, attributes: [.kern: kern])
        self.attributedText = attributedString
    }
    
    func setText(string: String, tgKern: TgKern) {
        self.setText(string: string, kern: tgKern.rawValue)
    }
}
