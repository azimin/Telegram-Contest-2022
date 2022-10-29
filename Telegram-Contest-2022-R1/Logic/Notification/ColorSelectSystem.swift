//
//  ColorSelectSystem.swift
//  Telegram-Contest-2022-R1
//
//  Created by Alexander Zimin on 29/10/2022.
//

import UIKit

typealias ColorAction = (_ color: ColorPickerResult) -> Void

final class ColorBox {
    weak var unbox: AnyObject?
    var action: ColorAction?
    
    init(_ value: AnyObject, _ action: ColorAction?) {
        self.unbox = value
        self.action = action
    }
}

class ColorSelectSystem {
    static var shared = ColorSelectSystem()
    
    private var subscribers: [ColorBox] = []
    
    func fireColor(_ color: ColorPickerResult) {
        self.refreshBoxes()
        self.subscribers.forEach({ $0.action?(color) })
    }
    
    func subscribeOnEvent(_ object: AnyObject, subscribe: ColorAction?) {
        self.refreshBoxes()
        self.subscribers.append(.init(object, subscribe))
    }
    
    private func refreshBoxes() {
        self.subscribers = self.subscribers.filter({ $0.unbox != nil })
    }
}
