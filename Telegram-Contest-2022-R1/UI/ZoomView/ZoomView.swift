//
//  ZoomView.swift
//  Telegram-Contest-2022-R1
//
//  Created by Alexander Zimin on 26/10/2022.
//

import UIKit
import AVKit

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
    private let imageView = UIImageView()
    private let videoView = AVPlayerView()
    let linesView = LinesView()
    let maskTopView = UIView()
    
    var currentContentView: UIView!
    
    let shadowTopOverlay = CAGradientLayer()
    let shadowBottomOverlay = CAGradientLayer()
    
    private var contentContainer: ContentContainer?
    
    override func setUp() {
        self.maskTopView.backgroundColor = .black
        
        self.currentContentView = imageView
        
        self.addSubview(contentView)
        contentView.addSubview(imageView)
        contentView.addSubview(videoView)
        contentView.addSubview(linesView)
        
        self.linesView.delegate = self
        
        self.layer.addSublayer(self.shadowTopOverlay)
        self.layer.addSublayer(self.shadowBottomOverlay)
    }
    
    override func layoutSubviewsOnChangeBounds() {
        self.linesView.frame = self.bounds
        self.updateCenter()
    }
    
    func updateWith(videoURL: URL, contentContainer: ContentContainer) {
        self.contentContainer = contentContainer
        
        self.currentContentView = self.videoView
        self.imageView.isHidden = true
        self.videoView.isHidden = false
        
        let videoSize = self.videoView.play(url: videoURL)
        self.contentContainer?.additionalInfo.append(.videoSize(size: videoSize))
        let offset = Offset()
        
        let expectedSize = CGSize(
            width: self.bounds.width,
            height: self.bounds.height - offset.topOffset - offset.bottomOffset
        )
        
        var expectedSizeFinal = expectedSize
        
        let mW = expectedSize.width / videoSize.width
        let mH = expectedSize.height / videoSize.height
        
        if (mH < mW) {
            expectedSizeFinal.width = mH * videoSize.width
        } else if (mW < mH) {
            expectedSizeFinal.height = mW * videoSize.height
        }
        
        self.videoView.frame.size = expectedSizeFinal
        self.updateCenter()
    }
    
    func updateWith(image: UIImage, contentContainer: ContentContainer) {
        self.contentContainer = contentContainer
        
        self.currentContentView = self.imageView
        self.videoView.stop()
        self.imageView.isHidden = false
        self.videoView.isHidden = true
        
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
        var centerPoint = self.center
        centerPoint.y += (offset.topOffset - offset.bottomOffset) / 2
        self.imageView.center = centerPoint
        self.videoView.center = centerPoint
        self.updateMask()
    }
    
    private func updateMask() {
        self.maskTopView.frame = self.currentContentView.frame
        self.linesView.mask = self.maskTopView
        self.delegate?.shouldUpdateMask(frame: self.currentContentView.frame)
        
        NotificationSystem.shared.fireEvent(.maskUpdated(view: self.contentView, frame: self.currentContentView.frame))
    }
    
    func lineSavingCompleted() {
        self.delegate?.lineSavingCompleted()
    }
}
