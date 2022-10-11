//
//  ToolsView.swift
//  Telegram-Contest-2022-R1
//
//  Created by Alexander Zimin on 11/10/2022.
//

import UIKit

class ToolsView: View {
    enum State {
        case allComponents
        case componentPresented
    }
    
    let shadowImageView = UIImageView()
    private let contentMaskView = UIView()
    
    override func setUp() {
        let pen = ToolView(style: .pen)
        pen.color = UIColor(hex: "32FEBA")
        self.addSubview(pen)
        pen.frame.origin.y += 45
        
        self.contentMaskView.backgroundColor = .black
        self.mask = self.contentMaskView
        
        self.addSubview(self.shadowImageView)
        self.shadowImageView.image = UIImage(named: "toolsShadow")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let superviewFrame = self.superview?.frame ?? .zero
        let delta = (superviewFrame.width - self.frame.width) / 2
        
        self.contentMaskView.frame = CGRect(x: -delta, y: 0, width: superviewFrame.width, height: self.frame.height)
        self.shadowImageView.frame = CGRect(x: -delta, y: self.frame.height - 16, width: superviewFrame.width, height: 32)
    }
}
