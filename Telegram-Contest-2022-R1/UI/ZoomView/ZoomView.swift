//
//  ZoomView.swift
//  Telegram-Contest-2022-R1
//
//  Created by Alexander Zimin on 26/10/2022.
//

import UIKit

protocol ZoomViewDelegate: NSObjectProtocol {
    func lineSavingCompleted()
    func shouldUpdateMask(frame: CGRect)
}

class ZoomView: View, LinesViewDelegate {
    weak var delegate: ZoomViewDelegate?
    
    struct Offset {
        var topOffset: CGFloat = {
            let window = UIApplication.shared.windows.first
            return (window?.safeAreaInsets.top ?? 0) + 44
        }()
        var bottomOffset: CGFloat = {
            let window = UIApplication.shared.windows.first
            return (window?.safeAreaInsets.bottom ?? 0) + 40 + 136
        }()
    }
    
    let contentView = UIView()
    let imageView = UIImageView()
    let linesView = LinesView()
    let maskTopView = UIView()
    
    let shadowTopOverlay = CAGradientLayer()
    let shadowBottomOverlay = CAGradientLayer()
    
    override func setUp() {
        self.maskTopView.backgroundColor = .black
        
        self.addSubview(contentView)
        contentView.addSubview(imageView)
        contentView.addSubview(linesView)
        
        self.linesView.delegate = self
        
        self.layer.addSublayer(self.shadowTopOverlay)
        self.layer.addSublayer(self.shadowBottomOverlay)
    }
    
    override func layoutSubviewsOnChangeBounds() {
        self.contentView.frame = self.bounds
        self.linesView.frame = self.bounds
        
        self.updateCenter()
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
        self.updateCenter()
    }
    
    private func updateCenter() {
        let offset = Offset()
        self.imageView.center = self.contentView.center
        self.imageView.center.y += (offset.topOffset - offset.bottomOffset) / 2
        self.updateMask()
    }
    
    private func updateMask() {
        self.maskTopView.frame = self.imageView.frame
        self.linesView.mask = self.maskTopView
        self.delegate?.shouldUpdateMask(frame: self.imageView.frame)
        
        NotificationSystem.shared.fireEvent(.maskUpdated(view: self.contentView, frame: self.imageView.frame))
    }
    
    func lineSavingCompleted() {
        self.delegate?.lineSavingCompleted()
    }
}
