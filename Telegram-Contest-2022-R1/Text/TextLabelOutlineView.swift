//
//  TextLabelOutlineView.swift
//  TextExperiment
//
//  Created by Alexander Zimin on 27/10/2022.
//

import UIKit

class TextLabelOutlineView: UIView {
    let strokeLabel = OutlineTextView()
    
    weak var textLabelView: TextLabelView?
    
    var strokeColor: UIColor = .black
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    enum State {
        case hidden
        case editing
        case presenting
    }
    
    private var state: State = .hidden
    
    func setup() {
        self.addSubview(self.strokeLabel)
        
        self.strokeLabel.backgroundColor = UIColor.clear
        self.strokeLabel.isSelectable = false
        self.strokeLabel.isScrollEnabled = false
        self.strokeLabel.textContainerInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        self.strokeLabel.frame = self.bounds
        self.strokeLabel.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.strokeLabel.frame = self.bounds
    }
    
    func updateWithVisual(textView: CustomTextView) {
        self.strokeLabel.textColor = textView.capturedColor
        self.strokeLabel.textAlignment = textView.textAlignment
    }
    
    var text: String = ""
    var font: UIFont = UIFont.systemFont(ofSize: 10)
    
    func updateWith(text: String, font: UIFont?) {
        self.text = text
        self.font = font ?? self.font
        
        guard self.state != .hidden else {
            return
        }
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = self.strokeLabel.textAlignment
        
        let attributedString = NSAttributedString(string: text, attributes: [.strokeColor: self.strokeColor, .foregroundColor: self.strokeLabel.textColor ?? .white, .strokeWidth: -3.5, .paragraphStyle: paragraph])
        self.strokeLabel.attributedText = attributedString
        self.strokeLabel.font = font
        self.strokeLabel.adjustContentSize()
        
//        self.strokeLabel.layer.shadowColor = UIColor.black.cgColor
//        self.strokeLabel.layer.shadowOffset = .zero
//        self.strokeLabel.layer.shadowOpacity = 1
//        self.strokeLabel.layer.shadowRadius = 3
    }
    
    func changeState(state: State) {
        guard self.state != state else {
            return
        }
        
        self.state = state
        
        switch state {
        case .hidden:
            self.strokeLabel.attributedText = NSAttributedString()
            self.textLabelView?.textView.isHidden = false
            self.textLabelView?.textView.shouldReduceAlpha = false
            self.isHidden = true
        case .editing:
            self.isHidden = false
            self.updateWith(text: self.text, font: self.font)
            self.textLabelView?.textView.shouldReduceAlpha = true
            self.textLabelView?.textView.isHidden = false
        case .presenting:
            self.isHidden = false
            self.updateWith(text: self.text, font: self.font)
            self.textLabelView?.textView.shouldReduceAlpha = true
            self.textLabelView?.textView.isHidden = true
        }
    }
}

class OutlineTextView: UITextView {
    func adjustContentSize() {
        let height = self.sizeThatFits(self.bounds.size).height
        
        let deadSpace = self.bounds.size.height - height + self.textContainerInset.top
        let inset = max(0, deadSpace / 2.0)
        
        self.textContainerInset = UIEdgeInsets(top: inset, left: self.textContainerInset.left, bottom: 0, right: self.textContainerInset.right)
    }
}
