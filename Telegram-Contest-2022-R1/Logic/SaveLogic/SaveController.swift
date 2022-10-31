//
//  SaveController.swift
//  Telegram-Contest-2022-R1
//
//  Created by Alexander Zimin on 30/10/2022.
//

import UIKit

class SaveController {
    static func prepareAnsSavePhoto(originalImage: UIImage, drawImage: UIImage?, textLayer: UIView, maskContent: UIView, maskFrame: CGRect) -> UIImage {
        TextSelectionController.shared.deselectText()
        
        let scale = UIScreen.main.scale
        let scaledMask = maskFrame.mult(value: scale)
        
        var newImage: UIImage = originalImage
        
        if let image = drawImage, let cropped = image.crop(rect: scaledMask) {
            newImage = newImage.mergeWith(topImage: cropped)
        }
        
        let renderer = UIGraphicsImageRenderer(size: textLayer.bounds.size)
        let textImage = renderer.image { ctx in
            textLayer.drawHierarchy(in: textLayer.bounds, afterScreenUpdates: true)
        }
        
        if let cropped = textImage.crop(rect: maskFrame) {
            newImage = newImage.mergeWith(topImage: cropped)
        }
        
        UIImageWriteToSavedPhotosAlbum(newImage, nil, nil, nil)
        return newImage
    }
    
}

fileprivate extension UIImage {
    func crop(rect: CGRect) -> UIImage? {
        var scaledRect = rect
        scaledRect.origin.x *= scale
        scaledRect.origin.y *= scale
        scaledRect.size.width *= scale
        scaledRect.size.height *= scale
        guard let imageRef: CGImage = cgImage?.cropping(to: scaledRect) else {
            return nil
        }
        return UIImage(cgImage: imageRef, scale: scale, orientation: imageOrientation)
    }
}

extension CGRect {
    func mult(value: CGFloat) -> CGRect {
        return CGRect(
            x: self.origin.x * value,
            y: self.origin.y * value,
            width: self.size.width * value,
            height: self.size.height * value
        )
    }
}
