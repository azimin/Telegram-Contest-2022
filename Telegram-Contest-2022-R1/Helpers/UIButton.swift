//
//  UIButton.swift
//  Telegram-Contest-2022-R1
//
//  Created by Alexander Zimin on 10/10/2022.
//

import Foundation
import UIKit

class Button: UIButton {
    override init(frame: CGRect) {
        super.init(frame: .zero)
        self.setUp()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isEnabled: Bool {
        didSet {
            self.updateState()
        }
    }
    
    func updateState() {
        if self.isEnabled == false {
            self.alpha = 0.3
        } else {
            self.alpha = 1.0
        }
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return bounds.insetBy(dx: -10, dy: -10).contains(point)
    }
    
    func setUp() { }
}
