//
//  SelectToolDetailsButton.swift
//  Telegram-Contest-2022-R1
//
//  Created by Alexander Zimin on 12/10/2022.
//

import UIKit

class SelectToolDetailsButton: Button {
    class ContentView: View {
        let label = UILabel()
        let icon = UIImageView()
        
        override func setUp() {
            self.addSubview(self.label)
            self.addSubview(self.icon)
        }
        
        func setContent(title: String, imageName: String) {
            let attributedString = NSAttributedString(string: title, attributes: [.kern: -0.41])
            
            self.label.attributedText = attributedString
            self.label.font = UIFont.sfProTextRegular(17)
            self.label.textAlignment = .right
            self.label.textColor = .white
            self.icon.image = UIImage(named: imageName)
            
            self.icon.frame = CGRect(x: 54.5, y: -1, width: 24, height: 24)
            self.label.frame = CGRect(x: -3, y: 0, width: 54, height: 22)
        }
    }
    
    func animate(isAppear: Bool, duration: TimeInterval) {
        let valueBefore: CGFloat = isAppear ? 0 : 1
        let valueAfter: CGFloat = isAppear ? 1 : 0
        
        self.contrainerView.layer.opacity = Float(valueAfter)
        self.contrainerView.layer.transform = CATransform3DMakeScale(valueAfter, valueAfter, 1)
        
        self.contrainerView.layer.animateAlpha(from: valueBefore, to: valueAfter, duration: duration)
        self.contrainerView.layer.animateScale(from: valueBefore, to: valueAfter, duration: duration)
    }
    
    func cahngeContentIconVisiblity(isHidden: Bool) {
        self.contentView?.icon.isHidden = isHidden
    }
    
    var contentView: ContentView? = nil
    let contrainerView = UIView()
    
    override func setUp() {
        self.contrainerView.isUserInteractionEnabled = false
        self.addSubview(self.contrainerView)
    }
    
    override func layoutSubviewsOnChangeBounds() {
        self.contrainerView.frame = self.bounds
    }
    
    func setContent(style: SelectToolDetailsStyle, animated: Bool) {
        self.setContent(title: style.shortTitle, imageName: style.icon, animated: animated)
    }
    
    func setContent(title: String, imageName: String, animated: Bool) {
        let oldContent = self.contentView
        if animated {
            oldContent?.layer.animateAlpha(from: 1, to: 0, duration: 0.23, completion: { _ in
                oldContent?.removeFromSuperview()
            })
        } else {
            oldContent?.removeFromSuperview()
        }
        
        
        let newContent = ContentView()
        newContent.setContent(title: title, imageName: imageName)
        newContent.frame = self.bounds
        newContent.layer.animateAlpha(from: 0, to: 1, duration: animated ? 0.23 : 0)
        self.contrainerView.addSubview(newContent)
        self.contentView = newContent
    }
}
