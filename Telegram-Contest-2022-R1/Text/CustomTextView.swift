//
//  CustomTextView.swift
//  TextExperiment
//
//  Created by Alexander Zimin on 22/10/2022.
//

import UIKit

class CustomTextView: UITextView, UIGestureRecognizerDelegate {
    weak var rootView: TextLabelView?
    
    var shouldReduceAlpha: Bool = false {
        didSet {
            self.updateTextColor(color: self.capturedColor)
        }
    }
    var capturedColor: UIColor = .black
    
    func updateTextColor(color: UIColor) {
        self.capturedColor = color
        if self.shouldReduceAlpha {
            self.textColor = color.withAlphaComponent(0.01)
        } else {
            self.textColor = color
        }
    }
    
    lazy var recommendedFont: UIFont = self.font ?? .systemFont(ofSize: 10) {
        didSet {
            self.adjustContentSize()
        }
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        let textStorage = NSTextStorage()
        let textContainer = NSTextContainer(size: frame.size)
        
        self.customLayoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(self.customLayoutManager)
    
        super.init(frame: frame, textContainer: textContainer)
        
        self.customLayoutManager.textView = self
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var tapGesture: UITapGestureRecognizer!
    
    let customLayoutManager = TextLayoutManager()
    let customTextStorage = NSTextStorage()
    
    private func setup() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.tapGesture(_:)))
        gesture.numberOfTapsRequired = 1
        gesture.delegate = self
        self.addGestureRecognizer(gesture)
        self.tapGesture = gesture
        self.isScrollEnabled = false
    }
    
    var contentHeight: CGFloat {
        let height = self.sizeThatFits(self.bounds.size).height
        return height - self.textContainerInset.top - self.textContainerInset.bottom
    }
    
    func adjustContentSize() {
        let height = self.sizeThatFits(self.bounds.size).height
        
        let deadSpace = self.bounds.size.height - height + self.textContainerInset.top
        let inset = max(0, deadSpace / 2.0)
        
        self.textContainerInset = UIEdgeInsets(top: inset, left: self.textContainerInset.left, bottom: 0, right: self.textContainerInset.right)
        
        self.updateFont()
    }
    
    var forceWidth: CGFloat? = nil
    
    func updateFont() {
        var newFont = self.recommendedFont
        while true {
            let width = (self.forceWidth ?? self.bounds.width) - self.textContainerInset.left - self.textContainerInset.right - 16
            
            let height = self.text.height(
                constrainedBy: width,
                with: newFont
            )
            
            if height > self.bounds.size.height {
                newFont = UIFont(name: newFont.fontName, size: newFont.pointSize - 0.5)!
            } else {
                break
            }
        }
        
        if newFont.pointSize != self.font?.pointSize {
            self.font = newFont
            self.adjustContentSize()
        }
    }
    
    var handleTap = false
    
    func startHandleDiscardTapAfterDelay() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
            self.handleTap = true
        })
    }
    
    func startHandleGesturesAfterDelay() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
            self.needToResignView = false
        })
    }
    
    @objc
    func tapGesture(_ gesture: UITapGestureRecognizer) { }
    
    private func shouldResignView(gesture: UITapGestureRecognizer) -> Bool {
        guard self.handleTap else {
            return false
        }
        
        guard self.text.isEmpty == false else {
            return true
        }
        
        let point = gesture.location(in: self)
        
        let offset = (self.bounds.size.height - self.contentHeight) / 2
        
        if point.y < offset - 16 || point.y > self.contentHeight + offset + 16 {
            return true
        }
        
        if point.x < 20 || point.x > self.frame.width - 20 {
            return true
        }
        
        return false
    }
    
    private func resignView() {
        self.selectedTextRange = nil
        self.resignFirstResponder()
    }
    
    var needToResignView = false
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if self.needToResignView {
            return false
        }
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == self.tapGesture || otherGestureRecognizer == self.tapGesture {
            if self.shouldResignView(gesture: self.tapGesture) {
                self.resignAction()
                return false
            }
            return true
        }
        return false
    }
    
    func minimalWidth() -> CGFloat {
//        var width: CGFloat = 0
//        let str = (self.text ?? "") as NSString
//        self.layoutManager.enumerateLineFragments(forGlyphRange: NSMakeRange(0, str.length)) { rect, usedRect, textContainer, glyphRange, stop in
//            if width < usedRect.width {
//                width = usedRect.width
//            }
//        }
//
        let width = self.sizeThatFits(self.bounds.size).width
        
//        if self.recommendedFont.pointSize != self.font?.pointSize {
//            return self.bounds.width
//        }
        
        return width
    }
    
    func resignAction() {
        self.needToResignView = true
        self.resignView()
        self.startHandleGesturesAfterDelay()
        self.rootView?.goToPresentState()
    }
    
    func selectCharAtPoint(point: CGPoint) {
        let index = self.layoutManager.glyphIndex(for: point, in: self.textContainer)
        self.selectedRange = NSMakeRange(index, 0)
    }
}

extension UIView {
    func applyScaleFactor(scale: CGFloat) {
        self.contentScaleFactor = scale
        self.layer.contentsScale = scale
        for subview in self.subviews {
            subview.applyScaleFactor(scale: scale)
        }
    }
}

extension String {
    func height(constrainedBy width: CGFloat, with font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)

        return boundingBox.height
    }

    func width(constrainedBy height: CGFloat, with font: UIFont) -> CGFloat {
        let constrainedRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constrainedRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return boundingBox.width
    }
}

