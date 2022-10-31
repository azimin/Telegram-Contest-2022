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
    }
    
    override func layoutSubviewsOnChangeBounds() {
        self.playerLayer.frame = self.bounds
    }
    
    func play(url: URL) -> CGSize {
        let player = AVPlayer(url: url)
        player.volume = 0 // TODO: - FIX
        playerLayer.player = player
        player.play()
        
        if let track = player.currentItem?.asset.tracks(withMediaType: .video).first {
            return track.naturalSize
        }
        
        return .zero
    }
    
    func stop() {
        self.playerLayer.player = nil
    }
}
