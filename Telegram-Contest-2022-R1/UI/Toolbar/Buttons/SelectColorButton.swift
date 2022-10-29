//
//  SelectColorButton.swift
//  Telegram-Contest-2022-R1
//
//  Created by Alexander Zimin on 11/10/2022.
//

import UIKit

class SelectColorButton: Button {
    typealias Action = (_ from: SelectColorButton, _ gesture: UILongPressGestureRecognizer) -> Void
    var presetQuickColorSelect: Action?
    
    var colorPickerResult: ColorPickerResult = .white {
        didSet {
            self.color = self.colorPickerResult.color
        }
    }
    
    private(set) var color: UIColor = .white {
        didSet {
            self.updateColor()
        }
    }
    
    private let colorView = UIView()
    
    override var isEnabled: Bool {
        didSet {
            self.longGesture.isEnabled = isEnabled
        }
    }
    
    private var longGesture: UILongPressGestureRecognizer!
    
    override func setUp() {
        self.addSubview(self.colorView)
        self.colorView.isUserInteractionEnabled = false
        self.colorView.layer.cornerRadius = 9.5
        self.colorView.autolayout {
            self.colorView.constraintSize(width: 19, height: 19)
            self.colorView.topAnchor.constraint(equalTo: self.topAnchor, constant: 9.5).activate()
            self.colorView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8.5).activate()
        }
        
        self.setImage(UIImage(named: "colorPicker"), for: .normal)
        self.updateColor()
        
        let panGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.panGesture(_:)))
        panGesture.minimumPressDuration = 0.5
        self.addGestureRecognizer(panGesture)
        self.longGesture = panGesture
    }
    
    @objc func panGesture(_ gesture: UILongPressGestureRecognizer) {
        self.presetQuickColorSelect?(self, gesture)
    }
    
    private func updateColor() {
        self.colorView.backgroundColor = color
    }
}
