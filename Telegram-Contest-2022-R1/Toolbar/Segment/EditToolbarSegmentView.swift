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
    }
    
    var itemSelected: ((Int) -> Void)?
    
    var selectedItem: Int = 0 {
        didSet {
            self.updateSelectedView(animated: true)
            self.itemSelected?(selectedItem)
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
    
    func changeItemsVisible(isVisible: Bool) {
        self.selectedView.isHidden = !isVisible
        self.backgroundView.isHidden = !isVisible
    }
    
    func switchAnimatedComponentsVisibility(isVisible: Bool, duration: TimeInterval) {
        
        if isVisible {
            self.alpha = 1
            self.layer.animateAlpha(from: 0, to: 1, duration: duration * 0.6, delay: duration * 0.4)
        } else {
            self.changeItemsVisible(isVisible: false)
            
            self.alpha = 0
            self.layer.animateAlpha(from: 1, to: 0, duration: duration * 0.6)
        }
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
        
        self.touchReportsIndex = .init(
            itemsCount: items.count,
            canSelectMultiple: false,
            highlited: { index in
                self.mutatedLabel?.alpha = 1.0
                self.mutatedLabel = nil
                if let index = index {
                    self.labels[index].alpha = 0.7
                    self.mutatedLabel = self.labels[index]
                }
            },
            selected: { index in
                self.selectedItem = index
            }
        )
    }
    
    var mutatedLabel: UILabel?
    
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
}
