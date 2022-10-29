//
//  TextKeybaordControllsView.swift
//  Telegram-Contest-2022-R1
//
//  Created by Alexander Zimin on 28/10/2022.
//

import UIKit

class TextKeybaordControllsView: View {
    let selectColorButton = SelectColorButton()
    let textStyleButton = TextStyleButton()
    let textAligmentButton = TextAligmentButton()
    
    init(textAligment: NSTextAlignment, style: TextLabelView.BackgroundStyle, color: ColorPickerResult) {
        super.init(frame: .zero)
        selectColorButton.colorPickerResult = color
        textStyleButton.updateStyle(style: style, animated: false)
        textAligmentButton.updateStyle(alignState: textAligment, animated: false)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setUp() {
        self.frame.size.height = 48
        
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.systemChromeMaterial)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(blurEffectView)
        
        self.addSubview(self.selectColorButton)
        self.addSubview(self.textStyleButton)
        self.addSubview(self.textAligmentButton)
        
        self.selectColorButton.addAction(action: { [weak self] in
            guard let self else { return }
            NotificationSystem.shared.fireEvent(.presentColorPicker(color: self.selectColorButton.colorPickerResult))
        })
        
        self.textAligmentButton.addAction { [weak self] in
            guard let self else { return }
            let nextValue = self.textAligmentButton.alignState.next()
            self.textAligmentButton.updateStyle(alignState: nextValue, animated: true)
            NotificationSystem.shared.fireEvent(.changeTextAligment(aligment: nextValue))
        }
        
        self.textStyleButton.addAction(action: {
            [weak self] in
            guard let self else { return }
            let nextValue = self.textStyleButton.style.next()
            self.textStyleButton.updateStyle(style: nextValue, animated: true)
            NotificationSystem.shared.fireEvent(.changeTextStyle(style: nextValue))
        })
        
        ColorSelectSystem.shared.subscribeOnEvent(self) { [weak self] color in
            self?.selectColorButton.colorPickerResult = color
        }
    }
    
    override func layoutSubviewsOnChangeBounds() {
        self.selectColorButton.frame = CGRect(x: 10, y: 6, width: 36, height: 36)
        self.textStyleButton.frame = CGRect(x: 54, y: 0, width: 46, height: self.bounds.height)
        self.textAligmentButton.frame = CGRect(x: 100, y: 0, width: 46, height: self.bounds.height)
    }
}
