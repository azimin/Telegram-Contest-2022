//
//  LinesView.swift
//  MetalExperiments
//
//  Created by Alexander Zimin on 19/10/2022.
//

import UIKit
import MetalKit

protocol LinesViewDelegate: NSObjectProtocol {
    func lineSavingCompleted()
}

class LinesView: UIView {
    let imageView = UIImageView()
    weak var delegate: LinesViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(self.imageView)
        self.isUserInteractionEnabled = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.imageView.frame = self.bounds
    }
    
    var images: [Data] = []
    var preveousImage: UIImage?
    
    func undo() {
        if self.images.isEmpty {
            return
        }
        
        images.removeLast()
        if self.images.count == 0 {
            self.preveousImage = nil
            self.imageView.image = nil
            return
        }
        
        let preveous = images.last!
        self.imageView.image = UIImage(data: preveous)
        self.preveousImage = UIImage(data: preveous)
    }
    
    func addTexture(texture: MTLTexture?, color: UIColor) {
        guard let texture = texture else {
            print("No texture")
            return
        }
        
        let ciImage = CIImage(mtlTexture: texture)!.oriented(.downMirrored)
        let context = CIContext(options: nil)
        let cgImage = context.createCGImage(ciImage, from: ciImage.extent)
        var image = UIImage(cgImage: cgImage!).withTintColor(color)
        
        if let preveousImage = self.preveousImage {
            image = preveousImage.mergeWith(topImage: image)
        }
        self.preveousImage = image
         
        images.append(image.pngData()!)
        self.imageView.image = image
        self.delegate?.lineSavingCompleted()
        
        UndoManager.shared.addAction(.drawMetalLine)
    }
}

extension UIImage {
    func imageWithAlpha(alpha: CGFloat) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(at: CGPointZero, blendMode: .normal, alpha: alpha)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}

extension UIImage {
    func mergeWith(topImage: UIImage) -> UIImage {
        let bottomImage = self
        
        UIGraphicsBeginImageContext(size)
        
        let areaSize = CGRect(x: 0, y: 0, width: bottomImage.size.width, height: bottomImage.size.height)
        bottomImage.draw(in: areaSize)
        
        topImage.draw(in: areaSize, blendMode: .normal, alpha: 1.0)
        
        let mergedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return mergedImage
    }
}

extension MTLTexture {
    
    func bytes() -> UnsafeMutableRawPointer {
        let width = self.width
        let height = self.height
        let rowBytes = self.width * 4
        let p = malloc(width * height * 4)
        
        self.getBytes(p!, bytesPerRow: rowBytes, from: MTLRegionMake2D(0, 0, width, height), mipmapLevel: 0)
        
        return p!
    }
    
    func toImage() -> CGImage? {
        let p = bytes()
        
        let pColorSpace = CGColorSpaceCreateDeviceRGB()
        
        let rawBitmapInfo = CGImageAlphaInfo.noneSkipFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue
        let bitmapInfo = CGBitmapInfo(rawValue: rawBitmapInfo)
        
        let selftureSize = self.width * self.height * 4
        let rowBytes = self.width * 4
        let releaseMaskImagePixelData: CGDataProviderReleaseDataCallback = { (info: UnsafeMutableRawPointer?, data: UnsafeRawPointer, size: Int) -> () in
            return
        }
        let provider = CGDataProvider(dataInfo: nil, data: p, size: selftureSize, releaseData: releaseMaskImagePixelData)
        let cgImageRef = CGImage(width: self.width, height: self.height, bitsPerComponent: 8, bitsPerPixel: 32, bytesPerRow: rowBytes, space: pColorSpace, bitmapInfo: bitmapInfo, provider: provider!, decode: nil, shouldInterpolate: true, intent: CGColorRenderingIntent.defaultIntent)!
        
        return cgImageRef
    }
}
