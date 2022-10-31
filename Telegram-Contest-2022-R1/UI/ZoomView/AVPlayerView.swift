//
//  AVPlayerView.swift
//  Telegram-Contest-2022-R1
//
//  Created by Alexander Zimin on 31/10/2022.
//

import UIKit
import AVKit

class AVPlayerView: View {
    let playerLayer = AVPlayerLayer()
    
    override func setUp() {
        
        self.layer.addSublayer(playerLayer)
        
        NotificationCenter.default.addObserver(forName: Notification.Name.AVPlayerItemDidPlayToEndTime, object: nil, queue: .main) { [weak self] _ in
            self?.playerLayer.player?.seek(to: CMTime.zero)
            self?.playerLayer.player?.play()
        }
        
        NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main) { [weak self] _ in
            self?.playerLayer.player?.play()
        }
    }
    
    override func layoutSubviews() {
        self.playerLayer.frame = self.bounds
    }
    
    func play(url: URL) -> CGSize {
        let player = AVPlayer(url: url)
//        player.volume = 0 // TODO: - FIX
        playerLayer.player = player
        player.play()
        
        return AVAsset(url: url).videoSize()
    }
    
    func stop() {
        self.playerLayer.player = nil
    }
}

public extension AVAsset {
    func videoSize() -> CGSize {
        guard let videoAssetTrack = self.tracks(withMediaType: .video).first else {
            return .zero
        }
        var videoSize = videoAssetTrack.naturalSize
        videoSize = __CGSizeApplyAffineTransform(videoSize, videoAssetTrack.preferredTransform)
        return CGSize(width: abs(videoSize.width), height: abs(videoSize.height))
    }
}
