//
//  ColorView.swift
//  ColorExperiment
//
//  Created by Alexander Zimin on 29/10/2022.
//

import UIKit

class ColorPickerResult {
    var color: UIColor
    var position: CGPoint
    
    init(color: UIColor, position: CGPoint) {
        self.color = color
        self.position = position
    }
    
    init(color: UIColor) {
        self.color = color
        self.position = .zero
    }
    
    static var white: ColorPickerResult {
        return ColorPickerResult(color: .white, position: .init(x: 0, y: 1))
    }
    
    static var black: ColorPickerResult {
        return ColorPickerResult(color: .black, position: .init(x: 0.999, y: 0.999))
    }
    
    static var yellow: ColorPickerResult {
        return ColorPickerResult(color: .init(hex: "F8D851"), position: .init(x: 0.4238, y: 0.1256))
    }
    
    static var green: ColorPickerResult {
        return ColorPickerResult(color: .init(hex: "70F2CE"), position: .init(x: 0.5478, y: 0.4609))
    }
    
    static var blue: ColorPickerResult {
        return ColorPickerResult(color: .init(hex: "469EF8"), position: .init(x: 0.4848, y: 0.5621))
    }
}

class ColorView: View {
    typealias ColorAction = (_ color: ColorPickerResult) -> Void
    
    let image = UIImage(named: "gadient")!
    lazy var imageView = UIImageView(image: image)
    
    fileprivate let colorCircleView = ColorCircleView()
    
    var colorUpdated: ColorAction?
    
    var canBeMoved: Bool = true
    var shouldDisableGestures: Bool
    var cachedOpacity: CGFloat? = nil
    
    var currentColor: ColorPickerResult = .black {
        didSet {
            if currentColor.color == oldValue.color {
                return
            }
            self.colorUpdated?(currentColor)
            self.updateCircle()
        }
    }
    
    private var isMoved: Bool = false
    
    private func updateCircle(moved: Bool = false) {
        self.colorCircleView.color = currentColor.color
        
        let delta: CGFloat = (moved && self.canBeMoved) ? -56 : 0
        
        self.colorCircleView.center = CGPoint(
            x: currentColor.position.x * self.bounds.width,
            y: currentColor.position.y * self.bounds.height + delta
        )
        
        self.isMoved = moved
    }
    
    init(frame: CGRect, shouldDisableGestures: Bool) {
        self.shouldDisableGestures = shouldDisableGestures
        super.init(frame: frame)
        self.setup()
        self.maskLayer.frame = self.bounds
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        self.addSubview(imageView)
        self.addSubview(self.colorCircleView)
        
        self.imageView.layer.cornerRadius = 8
        self.imageView.layer.masksToBounds = true

    }
    
    override func layoutSubviewsOnChangeBounds() {
        self.imageView.frame = self.bounds
        self.maskLayer.frame = self.bounds
        
        self.updateCircle(moved: self.isMoved)
    }
    
    func gestureUpdated(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began || gesture.state == .changed {
            let point = gesture.location(in: self)
            self.setColorFromPoint(point: point, moved: true)
        }
        
        if gesture.state == .ended || gesture.state == .cancelled || gesture.state == .failed {
            let point = gesture.location(in: self)
            self.setColorFromPoint(point: point, moved: false)
        }
    }
    
    func setColorFromPoint(point: CGPoint, moved: Bool) {
        var point = point
        var forceColor: UIColor? = nil
        
        if point.x >= self.bounds.width {
            point.x = self.bounds.width - 0.01
            forceColor = .black
        } else if point.x < 0 {
            point.x = 0
        }
        
        if point.y >= self.bounds.height {
            point.y = self.bounds.height - 0.01
        } else if point.y < 0 {
            point.y = 0
        }
        
        let pixelPoint = CGPoint(
            x: point.x / self.bounds.width * self.image.size.width,
            y: point.y / self.bounds.height * self.image.size.height
        )
        
        let color = forceColor ?? self.image.getPixelColor(pos: pixelPoint)
        
        let position = CGPoint(
            x: point.x / self.bounds.width,
            y: point.y / self.bounds.height
        )
        
        self.currentColor = .init(
            color: color,
            position: position
        )
        
        if moved {
            self.updateCircle(moved: moved)
        }
    }
    
    var maskLayer: CAShapeLayer = CAShapeLayer()
    
    func showAnimation() {
        self.imageView.layer.mask = self.maskLayer
        
        let from = UIBezierPath(roundedRect: CGRect(x: 7, y: self.bounds.height - 27, width: 18, height: 18), cornerRadius: 10)
        let to = UIBezierPath(roundedRect: self.maskLayer.bounds, cornerRadius: 8)
        
        self.colorCircleView.layer.animateAlpha(from: 0, to: 1, duration: 0.15)
        
        self.maskLayer.path = to.cgPath
        self.maskLayer.animate(from: from.cgPath, to: to.cgPath, keyPath: "path", timingFunction: CAMediaTimingFunctionName.easeOut.rawValue, duration: 0.25) { success in
            if success {
                self.imageView.mask = nil
            }
        }
    }
    
    func hideAnimation(isFromKeyboard: Bool) {
        let colorView = UIView()
        colorView.frame = self.imageView.bounds
        colorView.backgroundColor = self.colorCircleView.color
        colorView.layer.opacity = 1
        self.imageView.addSubview(colorView)
        
        self.isUserInteractionEnabled = false
        self.colorCircleView.isHidden = true
        self.imageView.layer.mask = self.maskLayer
        
        let to = UIBezierPath(roundedRect: CGRect(x: isFromKeyboard ? 14 : 7, y: self.bounds.height - 27, width: 18, height: 18), cornerRadius: 10)
        let from = UIBezierPath(roundedRect: self.maskLayer.bounds, cornerRadius: 8)
        
        self.maskLayer.path = to.cgPath
        self.maskLayer.animate(from: from.cgPath, to: to.cgPath, keyPath: "path", timingFunction: CAMediaTimingFunctionName.easeIn.rawValue, duration: 0.25) { _ in
            self.removeFromSuperview()
        }
        
        colorView.layer.animate(from: 0 as NSNumber, to: 1 as NSNumber, keyPath: "opacity", timingFunction: CAMediaTimingFunctionName.easeIn.rawValue, duration: 0.25)
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if self.shouldDisableGestures {
            return true
        }
        return super.point(inside: point, with: event)
    }
}

extension UIImage {
    func getPixelColor(pos: CGPoint) -> UIColor {
        if let pixelData = self.cgImage?.dataProvider?.data {
            let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
            let pixelInfo: Int = ((Int(self.size.width) * Int(pos.y)) + Int(pos.x)) * 4
            let red = CGFloat(data[pixelInfo]) / CGFloat(255.0)
            let green = CGFloat(data[pixelInfo+1]) / CGFloat(255.0)
            let blue = CGFloat(data[pixelInfo+2]) / CGFloat(255.0)
            let alpha = CGFloat(data[pixelInfo+3]) / CGFloat(255.0)
            return UIColor(red: red, green: green, blue: blue, alpha: alpha)
        }
        return UIColor.black
    }
}

extension UIColor {
    func hexStringFromColor(color: UIColor) -> String {
        let components = color.cgColor.components
        let r: CGFloat = components?[0] ?? 0.0
        let g: CGFloat = components?[1] ?? 0.0
        let b: CGFloat = components?[2] ?? 0.0

        let hexString = String.init(format: "#%02lX%02lX%02lX", lroundf(Float(r * 255)), lroundf(Float(g * 255)), lroundf(Float(b * 255)))
        print(hexString)
        return hexString
     }

    
    func getRGB() -> (CGFloat, CGFloat, CGFloat) {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        self.getRed(&r, green: &g, blue: &b, alpha: nil)
        
        return (r, g, b)
    }
}

fileprivate class ColorCircleView: UIView {
    let backgroundView = UIImageView(image: UIImage(named: "color_picker_view"))
    let colorView = UIView()
    
    var color: UIColor = .black {
        didSet {
            self.colorView.backgroundColor = color
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        self.frame = CGRect(x: 0, y: 0, width: 48, height: 48)
        
        self.addSubview(self.backgroundView)
        self.addSubview(self.colorView)
        
        self.backgroundView.frame = self.bounds
        self.colorView.frame = CGRect(
            x: 8.25,
            y: 8.25,
            width: 31.5,
            height: 31.5
        )
        self.colorView.layer.cornerRadius = self.colorView.bounds.width / 2
    }
}
