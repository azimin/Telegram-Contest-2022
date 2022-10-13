//
//  SelectColorButton.swift
//  Telegram-Contest-2022-R1
//
//  Created by Alexander Zimin on 11/10/2022.
//

import UIKit

class SelectColorButton: Button {
    var color: UIColor = .white {
        didSet {
            self.updateColor()
        }
    }
    
    private let colorView = UIView()
    
    override func setUp() {
        self.addSubview(self.colorView)
        self.colorView.isUserInteractionEnabled = false
        self.colorView.layer.cornerRadius = 9.5
        self.colorView.autolayout {
            self.colorView.constraintSize(width: 19, height: 19)
            self.colorView.topAnchor.constraint(equalTo: self.topAnchor, constant: 9).activate()
            self.colorView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8.5).activate()
        }
        
        self.setImage(UIImage(named: "colorPicker"), for: .normal)
        self.updateColor()
    }
    
    private func updateColor() {
        self.colorView.backgroundColor = color
    }
}
