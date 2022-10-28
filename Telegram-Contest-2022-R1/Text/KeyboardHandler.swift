//
//  KeyboardHandler.swift
//  TextExperiment
//
//  Created by Alexander Zimin on 20/10/2022.
//


import UIKit
import ObjectiveC

private var associationKey = "private_storedkbDelegate"

// MARK: - keyboardDelegate
extension UIView {
    weak var keyboardDelegate: KeyboardHandlerDelegate? {
        get {
            if let handler = objc_getAssociatedObject(self, &associationKey) as? KeyboardHandler {
                return handler.delegate
            }
            return nil
        }
        set {
            let handler = KeyboardHandler(delegate: newValue)
            objc_setAssociatedObject(self, &associationKey, handler, .OBJC_ASSOCIATION_RETAIN)
        }
    }
}

var activeInputView: UIView?
var prevInputView: UIView?

protocol KeyboardHandlerDelegate: AnyObject {
    /// This function handles keyboard state changing
    ///
    /// - parameter input: Active input component - `UITextField` or `UITextView`
    /// - parameter state: Keyboard state -  .opened, .frameChanged, .hidden
    /// - parameter info: Keyboard appearance and size information
    ///
    func keyboardStateChanged(input: UIView?, state: KeyboardState, info: KeyboardInfo)
    func keyboardActiveInputViewChanged(input: UIView?, info: KeyboardInfo)
}

extension KeyboardHandlerDelegate {
    /// This function informs about changed input view without changing keyboard state
    /// - parameter input: Active input component - `UITextField` or `UITextView`
    /// - parameter info: Keyboard appearance and size information
    func keyboardActiveInputViewChanged(input: UIView?, info: KeyboardInfo) {}
}

enum KeyboardState: String { // String for rawValue while testing
    case opened, hidden, frameChanged
}

struct KeyboardInfo {
    let beginFrame: CGRect
    let endFrame: CGRect
    let duration: TimeInterval
    let curve: UIView.AnimationCurve
    
    func animate(_ animations: @escaping () -> Void, completion: ((Bool) -> Void)? = nil) {
        let curveOption = UIView.AnimationOptions(rawValue: UInt(curve.rawValue) << 16)
        
        UIView.animate(withDuration: duration,
                       delay: 0,
                       options: [curveOption],
                       animations: animations,
                       completion: completion)
    }
}

/// Receives system notifications about keyboard appearance
///
/// How to use:
///   1) Subclass your controller from **KeyboardHandlerDelegate**
///   2) Set `keyboardDelegate` to self
///
class KeyboardHandler {
    
    weak var delegate: KeyboardHandlerDelegate?
    
    private enum VisibilityState {
        case hidden, visible, rotating
    }
    
    private var currentState: VisibilityState = .hidden {
        didSet {
            switch currentState {
            case .visible:
                wasVisible = false
            case .hidden:
                wasVisible = true
            case .rotating:
                break
            }
        }
    }
    
    init(delegate: KeyboardHandlerDelegate?) {
        self.delegate = delegate
        
        [
            UIResponder.keyboardWillShowNotification: #selector(willShown(notification:)),
            UIResponder.keyboardWillHideNotification: #selector(willHidden(notification:)),
            UIResponder.keyboardWillChangeFrameNotification: #selector(willChangeFrame(notification:)),
        ].forEach {
            NotificationCenter.default.addObserver(self, selector: $0.value, name: $0.key, object: nil)
        }
    }
    
    private var wasVisible = false // aka previousValue
    
    @objc func statusDidRotate(notification: Notification) {
        currentState = wasVisible ? .hidden : .visible
    }
    
    @objc func willShown(notification: Notification) {
        guard let delegate = delegate else {
            return
        }
        if prevInputView != nil && activeInputView != nil && currentState == .visible {
            if prevInputView != activeInputView {
                getInfo(from: notification) { info in
                    delegate.keyboardActiveInputViewChanged(input: activeInputView, info: info)
                    prevInputView = activeInputView
                    return
                }
            }
        }
        switch currentState {
        case .visible:
            return
        case .rotating:
            currentState = .visible
            return
        case .hidden:
            break
        }
        currentState = .visible
        getInfo(from: notification) { info in
            delegate.keyboardStateChanged(input: activeInputView, state: .opened, info: info)
        }
    }
    
    @objc func willHidden(notification: Notification) {
        if currentState == .rotating {
            return
        }
        currentState = .hidden
        prevInputView = nil
        getInfo(from: notification) { info in
            delegate?.keyboardStateChanged(input: activeInputView, state: .hidden, info: info)
        }
    }
    
    @objc func willChangeFrame(notification: Notification) {
        getInfo(from: notification) { info in
            if info.beginFrame.height != info.endFrame.height {
                delegate?.keyboardStateChanged(input: activeInputView, state: .frameChanged, info: info)
            }
        }
    }
    
    // ----- Private -----
    private func extractValues(from: [AnyHashable: Any]?) -> KeyboardInfo? {
        if let beginFrame = from?[UIResponder.keyboardFrameBeginUserInfoKey] as? CGRect,
           let endFrame = from?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
           let duration = from?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
           let curveRaw = from?[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int,
           let curve = UIView.AnimationCurve(rawValue: curveRaw) {
            return KeyboardInfo(beginFrame: beginFrame, endFrame: endFrame, duration: duration, curve: curve)
        }
        return nil
    }
    
    private func getInfo(from notification: Notification, completion: (KeyboardInfo) -> Void) {
        if let info = extractValues(from: notification.userInfo) {
            completion(info)
        }
    }
}
