//
//  ToolLassoView.swift
//  Telegram-Contest-2022-R1
//
//  Created by Alexander Zimin on 11/10/2022.
//

import UIKit

class ToolLassoView: View {
    var imageView = UIImageView()
    
    override func setUp() {
        self.imageView.image = UIImage(named: "lasso")
        self.addSubview(self.imageView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.imageView.frame = self.bounds
    }
}
