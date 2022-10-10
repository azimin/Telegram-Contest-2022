//
//  AutolayoutEngine.swift
//  Telegram-Contest-2022-R1
//
//  Created by Alexander Zimin on 10/10/2022.
//

import UIKit

class LayoutBuilder {
    enum Side {
        case top
        case topValue(_ value: CGFloat)
        case bottom
        case bottomValue(_ value: CGFloat)
        case leading
        case leadingValue(_ value: CGFloat)
        case trailing
        case trailingValue(_ value: CGFloat)
        case centerX
        case centerY
        case center
    }
    
    enum Equal {
        case none
        case superview
        case view(view: UIView)
    }
    
    var engine: Engine
    var sides: [Side] = []
    var equal: Equal = .none
    var insets: UIEdgeInsets? = nil
    var offset: CGFloat? = nil
    
    init(engine: Engine) {
        self.engine = engine
    }
    
    var top: LayoutBuilder {
        self.sides.append(.top)
        return self
    }
    
    var bottom: LayoutBuilder {
        self.sides.append(.bottom)
        return self
    }
    
    var leading: LayoutBuilder {
        self.sides.append(.bottom)
        return self
    }
    
    var center: LayoutBuilder {
        self.sides.append(.center)
        return self
    }
    
    var centerY: LayoutBuilder {
        self.sides.append(.centerY)
        return self
    }
    
    var centerX: LayoutBuilder {
        self.sides.append(.centerX)
        return self
    }
    
    var trailing: LayoutBuilder {
        self.sides.append(.bottom)
        return self
    }
    
    func offset(_ value: CGFloat) -> LayoutBuilder {
        self.offset = value
        return self
    }
    
    func top(_ value: CGFloat) -> LayoutBuilder {
        self.sides.append(.topValue(value))
        return self
    }
    
    func bottom(_ value: CGFloat) -> LayoutBuilder {
        self.sides.append(.bottomValue(value))
        return self
    }
    
    func leading(_ value: CGFloat) -> LayoutBuilder {
        self.sides.append(.leadingValue(value))
        return self
    }
    
    func trailing(_ value: CGFloat) -> LayoutBuilder {
        self.sides.append(.trailingValue(value))
        return self
    }
    
    func inset(_ insets: UIEdgeInsets) -> LayoutBuilder {
        self.insets = insets
        return self
    }
    
    @discardableResult
    func equalToSuperview() -> LayoutBuilder {
        self.equal = .superview
        return self
    }
    
    @discardableResult
    func equalTo(view: UIView) -> LayoutBuilder {
        self.equal = .view(view: view)
        return self
    }
    
    fileprivate func applyLayout(view: UIView, superview: UIView) {
        
    }
}

class Engine {
    typealias Execution = () -> LayoutBuilder
    
    let view: UIView
    
    init(view: UIView) {
        self.view = view
    }
    
    func build(execition: (_ builder: Execution) -> Void) {
        self.view.translatesAutoresizingMaskIntoConstraints = false
        
        var layouts: [LayoutBuilder] = []
        let builder = {
            let layout = LayoutBuilder(engine: self)
            layouts.append(layout)
            return layout
        }
        execition(builder)
        
        for layout in layouts {
            switch layout.equal {
            case .none:
                assertionFailure("No eqaul")
            case .superview:
                if let superview = self.view.superview {
                    superview.addSubview(self.view)
                    layout.applyLayout(view: self.view, superview: superview)
                } else {
                    assertionFailure("No superview")
                    continue
                }
            case .view(view: let superview):
                superview.addSubview(self.view)
                layout.applyLayout(view: self.view, superview: superview)
            }
        }
    }
}

extension UIView {
//    var layoutEngine: Engine {
//        let engine = Engine(view: self)
//        return engine
//    }
    
    func autolayout(block: () -> Void) {
        self.translatesAutoresizingMaskIntoConstraints = false
        block()
    }
}

extension NSLayoutConstraint {
    @discardableResult
    func activate() -> NSLayoutConstraint {
        self.isActive = true
        return self
    }
}
