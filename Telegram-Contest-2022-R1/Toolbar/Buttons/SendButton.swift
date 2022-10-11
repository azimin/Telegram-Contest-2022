//
//  SendButton.swift
//  Telegram-Contest-2022-R1
//
//  Created by Alexander Zimin on 11/10/2022.
//

import UIKit

class SendButton: Button {
    override func setUp() {
        self.setImage(UIImage(named: "download"), for: .normal)
    }
}
