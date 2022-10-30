//
//  BitchColorViewController.swift
//  Telegram-Contest-2022-R1
//
//  Created by Alexander Zimin on 30/10/2022.
//

import UIKit

class PoorColorViewController: UIViewController, UIGestureRecognizerDelegate, UIAdaptivePresentationControllerDelegate {
    let colorView = ColorView()
    var color: ColorPickerResult
    
    let currentColorBackgroundView = UIImageView(image: UIImage(named: "opacity_bg_alpha"))
    let currentColorView = UIView()
    
    let opacotyTitleLabel = UILabel()
    let opacitySelectView = OpacitySelectView()
    
    let opacityValueLabel = UILabel()
    
    var selectedAlpha: CGFloat = 1
    
    init(color: ColorPickerResult) {
        if color.color == UIColor.white {
            self.color = .init(color: color.color, position: CGPoint(x: 0, y: 0))
        } else {
            self.color = color
        }
        
        self.selectedAlpha = color.color.alpha
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var tapGesture: UITapGestureRecognizer!
    private var panGesture: UIPanGestureRecognizer!
    private var opacityPanGesture: UIPanGestureRecognizer!
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ColorSelectSystem.shared.fireColor(self.color)
    }
    
    override func viewDidLoad() {
        let titleLabel = UILabel()
        titleLabel.text = "Color"
        titleLabel.font = .sfProTextSemibold(17)
        self.view.addSubview(titleLabel)
        
        titleLabel.autolayout {
            titleLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).activate()
            titleLabel.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 18).activate()
        }
        
        let button = UIButton()
        button.setImage(UIImage(named: "close_button_color"), for: .normal)
        button.addAction { [weak self] in
            self?.dismiss(animated: true)
        }
        self.view.addSubview(button)
        
        button.autolayout {
            button.constraintSize(width: 30, height: 30)
            button.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16).activate()
            button.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 14).activate()
        }
        
        self.view.backgroundColor = UIColor(hex: "35393C")
        
        self.view.addSubview(self.colorView)
        self.colorView.currentColor = self.color
        self.colorView.canBeMoved = false
        
        let width = self.view.frame.width - 48
        self.colorView.frame = CGRect(
            x: 24,
            y: 64,
            width: width,
            height: width * 0.8335
        )
        
        self.view.addSubview(self.opacotyTitleLabel)
        self.opacotyTitleLabel.text = "OPACITY"
        self.opacotyTitleLabel.textColor = UIColor.white.withAlphaComponent(0.6)
        self.opacotyTitleLabel.font = UIFont.sfProTextSemibold(13)
        self.opacotyTitleLabel.frame = CGRect(x: 24, y: self.colorView.frame.maxY + 16, width: 100, height: 20)
        
        self.view.addSubview(self.opacitySelectView)
        self.opacitySelectView.setProgress(value: self.selectedAlpha)
        self.opacitySelectView.frame = CGRect(x: 24, y: self.colorView.frame.maxY + 38, width: self.view.bounds.width - 112 - 24, height: 36)
        self.opacitySelectView.setColor(color: color.color.withAlphaComponent(1))
        
        self.view.addSubview(self.opacityValueLabel)
        self.opacityValueLabel.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        self.opacityValueLabel.font = .sfProTextSemibold(17)
        self.opacityValueLabel.text = "100%"
        self.opacityValueLabel.textAlignment = .center
        self.opacityValueLabel.textColor = .white
        self.opacityValueLabel.layer.cornerRadius = 8
        self.opacityValueLabel.layer.masksToBounds = true
        self.opacityValueLabel.frame = CGRect(
            x: self.opacitySelectView.frame.maxX + 12,
            y: self.opacitySelectView.frame.origin.y,
            width: 77,
            height: 36
        )
        
        self.view.addSubview(self.currentColorBackgroundView)
        self.currentColorBackgroundView.frame = CGRect(x: 24, y: self.colorView.frame.maxY + 100, width: 82, height: 82)
        self.currentColorBackgroundView.layer.cornerRadius = 10
        self.currentColorBackgroundView.layer.masksToBounds = true
        
        self.view.addSubview(self.currentColorView)
        self.currentColorView.backgroundColor = color.color
        self.currentColorView.frame = self.currentColorBackgroundView.frame
        self.currentColorView.layer.cornerRadius = 10
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.panGesture(_:)))
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)
        self.tapGesture = tapGesture
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.panGesture(_:)))
        panGesture.delegate = self
        self.view.addGestureRecognizer(panGesture)
        self.panGesture = panGesture
        
        let opacityPanGesture = UIPanGestureRecognizer(target: self, action: #selector(self.panGesture2(_:)))
        opacityPanGesture.delegate = self
        self.view.addGestureRecognizer(opacityPanGesture)
        self.opacityPanGesture = opacityPanGesture
        
        colorView.colorUpdated = { [weak self] color in
            guard let self else { return }
            self.updateColor(color: color)
        }
        
        self.opacitySelectView.progressUpdated = { [weak self] value in
            guard let self else { return }
            self.updateProgress(value: value)
        }
        
        self.updateProgress(value: self.selectedAlpha)
    }
    
    func updateProgress(value: CGFloat) {
        let percent = Int(value * 100)
        self.opacityValueLabel.text = "\(percent)%"
        self.selectedAlpha = value
        self.updateColor(color: self.color)
    }
    
    func updateColor(color: ColorPickerResult) {
        let colorValue = ColorPickerResult(
            color: color.color.withAlphaComponent(self.selectedAlpha),
            position: color.position
        )
        self.color = colorValue
        self.currentColorView.backgroundColor = colorValue.color
        self.opacitySelectView.setColor(color: colorValue.color.withAlphaComponent(1))
        self.opacitySelectView.setProgress(value: self.selectedAlpha)
    }
    
    @objc func panGesture(_ gesture: UILongPressGestureRecognizer) {
        self.colorView.gestureUpdated(gesture: gesture)
    }
    
    @objc func panGesture2(_ gesture: UIPanGestureRecognizer) {
        self.opacitySelectView.gestureUpdated(gesture: gesture)
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == self.panGesture || gestureRecognizer == self.tapGesture {
            let point = gestureRecognizer.location(in: self.view)
            if self.colorView.frame.contains(point) {
                return true
            } else {
                return false
            }
        }
        
        if gestureRecognizer == self.opacityPanGesture {
            let point = gestureRecognizer.location(in: self.view)
            if self.opacitySelectView.frame.contains(point) {
                return true
            } else {
                return false
            }
        }
        
        return true
    }
}
