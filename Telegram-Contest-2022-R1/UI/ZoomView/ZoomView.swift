//
//  ZoomView.swift
//  Telegram-Contest-2022-R1
//
//  Created by Alexander Zimin on 26/10/2022.
//

import UIKit

protocol ZoomViewDelegate: NSObjectProtocol {
    func lineSavingCompleted()
}

class ZoomView: View, LinesViewDelegate {
    weak var delegate: ZoomViewDelegate?
    
    struct Offset {
        // TODO: - Play with values
        var topOffset: CGFloat = 20
        var bottomOffset: CGFloat = 144
    }
    
    let contentView = UIView()
    let imageView = UIImageView()
    let linesView = LinesView()
    
    override func setUp() {
        self.addSubview(contentView)
        contentView.addSubview(imageView)
        contentView.addSubview(linesView)
        
        self.linesView.delegate = self
    }
    
    override func layoutSubviews() {
        self.contentView.frame = self.bounds
        self.linesView.frame = self.bounds
        
        let offset = Offset()
        self.imageView.center = self.contentView.center
        self.imageView.center.y += (offset.topOffset - offset.bottomOffset) / 2
    }
    
    func updateWith(image: UIImage) {
        let offset = Offset()
        
        let expectedSize = CGSize(
            width: self.bounds.width,
            height: self.bounds.height - offset.topOffset - offset.bottomOffset
        )
        
        let imageSize = image.size
        var expectedSizeFinal = expectedSize
        
        let mW = expectedSize.width / imageSize.width
        let mH = expectedSize.height / imageSize.height
        
        if (mH < mW) {
            expectedSizeFinal.width = mH * imageSize.width
        } else if (mW < mH) {
            expectedSizeFinal.height = mW * imageSize.height
        }
        
        self.imageView.image = image
        self.imageView.frame.size = expectedSizeFinal
    }
    
    func lineSavingCompleted() {
        self.delegate?.lineSavingCompleted()
    }
}
