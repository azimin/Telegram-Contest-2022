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
    
    var content: Content
    
    init(image: UIImage) {
        self.content = .image(image: image)
    }
    
    init(videoURL: URL) {
        self.content = .video(url: videoURL)
    }
}
