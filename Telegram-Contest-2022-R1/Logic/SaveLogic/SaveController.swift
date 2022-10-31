//
//  SaveController.swift
//  Telegram-Contest-2022-R1
//
//  Created by Alexander Zimin on 30/10/2022.
//

import UIKit
import AVKit
import Photos

class SaveController {
    static func prepareAnsSaveVideo(url: URL, contentContainer: ContentContainer, drawImage: UIImage?, textLayer: UIView, maskContent: UIView, maskFrame: CGRect, completion: CompletionBlock?) {
        TextSelectionController.shared.deselectText()
        
        let scale = UIScreen.main.scale
        let scaledMask = maskFrame.mult(value: scale)
        
        var newImage: UIImage?
        
        if let image = drawImage, let cropped = image.crop(rect: scaledMask) {
            newImage = cropped
        }
        
        let renderer = UIGraphicsImageRenderer(size: textLayer.bounds.size)
        let textImage = renderer.image { ctx in
            textLayer.drawHierarchy(in: textLayer.bounds, afterScreenUpdates: true)
        }
        
        if let cropped = textImage.crop(rect: maskFrame) {
            newImage = newImage?.mergeWith(topImage: cropped) ?? cropped
        }

        guard let size = contentContainer.getVideoSize, var newImage = newImage else {
            completion?(false)
            return
        }
        
        let myLayer = CALayer()
        myLayer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        myLayer.contents = newImage.cgImage
        
        let image = UIGraphicsImageRenderer(size: size.mult(1 / scale)).image { _ in
            newImage.draw(in: CGRect(origin: .zero, size: size.mult(1 / scale)))
        }
        newImage = image.withRenderingMode(.alwaysOriginal)
        
        self.addWatermark(inputURL: url, topLayer: newImage) { exportSession, outputURL in
            if exportSession != nil {
                PHPhotoLibrary.shared().performChanges {
                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputURL)
                } completionHandler: { success, error in
                    if success {
                        OperationQueue.main.addOperation {
                            completion?(true)
                        }
                    } else {
                        if let error = error {
                            print(error)
                        }
                        OperationQueue.main.addOperation {
                            completion?(false)
                        }
                    }
                }
            } else {
                OperationQueue.main.addOperation {
                    completion?(false)
                }
            }
        }
    }

    static func prepareAnsSavePhoto(originalImage: UIImage, drawImage: UIImage?, textLayer: UIView, maskContent: UIView, maskFrame: CGRect) {
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
    }
    
    
    static func addWatermark(inputURL: URL, topLayer: UIImage, handler: @escaping (_ exportSession: AVAssetExportSession?, _ outputURL: URL) -> Void) {
        let outputURL = URL(fileURLWithPath: NSTemporaryDirectory() + "/exported.mp4")
        try? FileManager().removeItem(at: outputURL)
        
        let mixComposition = AVMutableComposition()
        let asset = AVAsset(url: inputURL)
        let videoTrack = asset.tracks(withMediaType: AVMediaType.video)[0]
        let timerange = CMTimeRangeMake(start: CMTime.zero, duration: asset.duration)

            let compositionVideoTrack:AVMutableCompositionTrack = mixComposition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: CMPersistentTrackID(kCMPersistentTrackID_Invalid))!

        do {
            try compositionVideoTrack.insertTimeRange(timerange, of: videoTrack, at: CMTime.zero)
            compositionVideoTrack.preferredTransform = videoTrack.preferredTransform
        } catch {
            print(error)
        }

        let watermarkFilter = CIFilter(name: "CISourceOverCompositing")!
        let watermarkImage = CIImage(image: topLayer)
        let videoComposition = AVVideoComposition(asset: asset) { (filteringRequest) in
            let source = filteringRequest.sourceImage.clampedToExtent()
            watermarkFilter.setValue(source, forKey: "inputBackgroundImage")
            watermarkFilter.setValue(watermarkImage, forKey: "inputImage")
            filteringRequest.finish(with: watermarkFilter.outputImage!, context: nil)
        }

        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) else {
            handler(nil, outputURL)

            return
        }

        exportSession.outputURL = outputURL
        exportSession.outputFileType = AVFileType.mp4
        exportSession.shouldOptimizeForNetworkUse = true
        exportSession.videoComposition = videoComposition
        exportSession.exportAsynchronously { () -> Void in
            handler(exportSession, outputURL)
        }
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

extension CGSize {
    func mult(_ value: CGFloat) -> CGSize {
        return CGSize(
            width: self.width * value,
            height: self.height * value
        )
    }
}
