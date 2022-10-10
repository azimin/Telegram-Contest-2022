//
//  EditToolbarSegmentView.swift
//  Telegram-Contest-2022-R1
//
//  Created by Alexander Zimin on 10/10/2022.
//

import UIKit

class EditToolbarSegmentView: View {
    struct Item {
        var text: String
        var action: VoidBlock
    }
    
    var selectedItem: Int = 0 {
        didSet {
            self.updateSelectedView(animated: true)
        }
    }
    
    let items: [Item]
    var labels: [UILabel] = []
    
    let backgroundView = UIView()
    let selectedView = UIView()
    
    init(items: [Item]) {
        self.items = items
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setUp() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.heightAnchor.constraint(equalToConstant: 32).activate()
        
        self.backgroundView.layer.cornerRadius = 16
        self.backgroundView.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        self.addSubview(self.backgroundView)
        
        self.selectedView.layer.cornerRadius = 14
        self.selectedView.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        self.addSubview(self.selectedView)
        
        for item in self.items {
            let label = UILabel()
            label.font = UIFont.sfProTextMedium(13)
            label.text = item.text
            label.textColor = .white
            label.textAlignment = .center
            self.labels.append(label)
            self.addSubview(label)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.backgroundView.frame = self.bounds
        
        let step = (self.frame.width - 4) / CGFloat(self.labels.count)
        for (index, label) in self.labels.enumerated() {
            label.frame = CGRect(
                x: 2 + step * CGFloat(index) + 8,
                y: 8,
                width: step - 16,
                height: 16
            )
        }
        
        self.updateSelectedView(animated: false)
    }
    
    func updateSelectedView(animated: Bool) {
        var selectedFrame = CGRect.zero
        
        for (index, label) in self.labels.enumerated() {
            if index == self.selectedItem {
                label.font = .sfProTextSemibold(13)
                selectedFrame = label.frame
            } else {
                label.font = .sfProTextMedium(13)
            }
        }
        
        UIView.animate(withDuration: animated ? 0.25 : 0, delay: 0, options: [.allowUserInteraction, .curveEaseOut]) {
            self.selectedView.frame = CGRect(
                x: selectedFrame.origin.x - 8,
                y: selectedFrame.origin.y - 6,
                width: selectedFrame.width + 16,
                height: selectedFrame.height + 12
            )
        }
        
    }
    
    var preSelectedIndex: Int?
    
    private func selectedIndex(touch: UITouch) -> Int {
        let step = self.frame.width / CGFloat(self.labels.count)
        let touchPoint = touch.location(in: self)
        
        if (touchPoint.y < 0 || touchPoint.y > self.frame.height) {
            return -1
        }
        
        if (touchPoint.x < 0 || touchPoint.x > self.frame.width) {
            return -1
        }
        
        let index = Int(touchPoint.x / step)
        return index
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let touch = touches.first else {
            return
        }
        
        let index = self.selectedIndex(touch: touch)
        self.preSelectedIndex = index
        self.mutateLabel(index: index)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let touch = touches.first else {
            return
        }
        self.mutateLabel(index: self.selectedIndex(touch: touch))
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        guard let touch = touches.first else {
            return
        }
        
        let index = self.selectedIndex(touch: touch)
        if index == self.preSelectedIndex, index >= 0, index < self.labels.count {
            self.selectedItem = index
        }
        
        if let label = self.mutatedLabel {
            label.alpha = 1.0
            self.mutatedLabel = nil
        }
        
        self.preSelectedIndex = nil
    }
    
    var mutatedLabel: UILabel?
    
    func mutateLabel(index: Int) {
        if let label = self.mutatedLabel {
            label.alpha = 1.0
            self.mutatedLabel = nil
        }
        
        if index >= 0, index < self.labels.count, index == self.preSelectedIndex {
            self.labels[index].alpha = 0.7
            self.mutatedLabel = self.labels[index]
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        self.preSelectedIndex = nil
        
        if let label = self.mutatedLabel {
            label.alpha = 1.0
            self.mutatedLabel = nil
        }
    }
}
