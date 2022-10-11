//
//  ToolEraserView.swift
//  Telegram-Contest-2022-R1
//
//  Created by Alexander Zimin on 11/10/2022.
//

import UIKit

class ToolEraserView: View {
    enum State {
        case basic
        case object
        case blur
    }
    
    var imageView = UIImageView()
    var stateImageView: UIImageView?
    
    private var state: State = .basic

    func setState(state: State, animated: Bool) {
        if self.state != state {
            self.state = state
            self.updateState(animated: animated)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if state == .basic {
            self.setState(state: .object, animated: true)
        } else if state == .object {
            self.setState(state: .blur, animated: true)
        } else {
            self.setState(state: .basic, animated: true)
        }
    }
    
    override func setUp() {
        self.addSubview(self.imageView)
        self.imageView.image = UIImage(named: "eraser")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.imageView.frame = self.bounds
    }
    
    private func updateState(animated: Bool) {
        switch self.state {
        case .basic:
            self.animateView(toImage: nil, size: .zero, animated: animated)
        case .object:
            self.animateView(toImage: UIImage(named: "eraser_object_icon"), size: .init(width: 7, height: 7), animated: animated)
        case .blur:
            self.animateView(toImage: UIImage(named: "blurTip_small"), size: .init(width: 9.5, height: 9.5), animated: animated)
        }
    }
    
    private func animateView(toImage: UIImage?, size: CGSize, animated: Bool) {
        if let toImage {
            self.scaleDownCurrent(animated: animated)
            self.createImageView(image: toImage, size: size, animated: animated)
        } else {
            self.scaleDownCurrent(animated: animated)
            self.stateImageView = nil
        }
    }
    
    private func createImageView(image: UIImage, size: CGSize, animated: Bool) {
        let imageView = UIImageView()
        imageView.image = image
        imageView.frame = CGRect(x: 10 - size.width / 2, y: 27.5 - size.height / 2, width: size.width, height: size.height)
        imageView.layer.animateScale(from: 0, to: 1, duration: animated ? 0.1 : 0, timingFunction: CAMediaTimingFunctionName.easeOut.rawValue)
        self.stateImageView = imageView
        self.addSubview(imageView)
    }
    
    private func scaleDownCurrent(animated: Bool) {
        let imageView = self.stateImageView
        imageView?.layer.animateScale(from: 1, to: 0, duration: animated ? 0.1 : 0, timingFunction: CAMediaTimingFunctionName.easeOut.rawValue, completion: {
            (success) in
            imageView?.removeFromSuperview()
        })
    }
}
