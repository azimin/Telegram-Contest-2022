//
//  NotificationSystem.swift
//  Telegram-Contest-2022-R1
//
//  Created by Alexander Zimin on 28/10/2022.
//

import UIKit

typealias EventAction = (_ event: NotificationSystem.Event) -> Void

final class WeakBox{
    weak var unbox: AnyObject?
    var action: EventAction?
    
    init(_ value: AnyObject, _ action: EventAction?) {
        self.unbox = value
        self.action = action
    }
}

class NotificationSystem {
    static var shared = NotificationSystem()
    
    private var subscribers: [WeakBox] = []
    
    enum Event {
        case none
        case textPresentationStateChanged(isPresenting: Bool)
        case textSelectionStateChanged(isSelected: Bool)
        case segmentTabChanged(index: Int)
        case maskUpdated(view: UIView, frame: CGRect)
        case createText
        case changeTextAligment(aligment: NSTextAlignment)
        case changeTextStyle(style: TextLabelView.BackgroundStyle)
    }
    
    func fireEvent(_ event: Event) {
        self.refreshBoxes()
        self.subscribers.forEach({ $0.action?(event) })
    }
    
    func subscribeOnEvent(_ object: AnyObject, subscribe: EventAction?) {
        self.refreshBoxes()
        self.subscribers.append(.init(object, subscribe))
    }
    
    private func refreshBoxes() {
        self.subscribers = self.subscribers.filter({ $0.unbox != nil })
    }
}
