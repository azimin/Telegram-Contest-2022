//
//  ImageContainer.swift
//  Telegram-Contest-2022-R1
//
//  Created by Alexander Zimin on 10/10/2022.
//

import UIKit

class ContentContainer {
    enum Content {
        case image(image: UIImage)
        case video(url: URL)
    }
    
    enum AdditionalInfo {
        case videoSize(size: CGSize)
    }
    
    var content: Content
    var additionalInfo: [AdditionalInfo] = []
    
    var getVideoSize: CGSize? {
        for info in self.additionalInfo {
            switch info {
            case .videoSize(let size):
                return size
            }
        }
        return nil
    }
    
    init(image: UIImage) {
        self.content = .image(image: image)
    }
    
    init(videoURL: URL) {
        self.content = .video(url: videoURL)
    }
}
