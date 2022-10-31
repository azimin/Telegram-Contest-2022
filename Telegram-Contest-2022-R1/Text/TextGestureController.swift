//
//  TextGestureControllers.swift
//  TextExperiment
//
//  Created by Alexander Zimin on 21/10/2022.
//

import UIKit

import ObjectiveC

// Declare a global var to produce a unique address as the assoc object handle
private var AssociatedObjectHandle: UInt8 = 0

extension UIGestureRecognizer {
    var isFromDrawer: Bool {
        get {
            return (objc_getAssociatedObject(self, &AssociatedObjectHandle) as? Bool) ?? false
        }
        set {
            objc_setAssociatedObject(self, &AssociatedObjectHandle, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

class TextGestureController {
    static var shared = TextGestureController()
    
    weak var gesture: UIPanGestureRecognizer?
    weak var tapGesture: UITapGestureRecognizer?
    weak var rootView: UIView?
    
    weak var labelsContentView: UIView?
    var labels: [TextLabelView] {
        let array = labelsContentView?.subviews.compactMap({ $0 as? TextLabelView }) ?? []
        return array.reversed()
    }
    
    private var startPoint = GesturePoint(point1: .zero, point2: .zero)
    private var preveousPoint = GesturePoint(point1: .zero, point2: .zero)
    private var oneFingerStartingCenter: CGPoint = .zero
    private var rotationProgress: CGFloat = 0
    private var translationProgress: CGPoint = .zero
    private var initialMutate: TextLabelView.MutateValues = .zero
    
    private var startOneTouchPoint: CGPoint = .zero
    private var translationOneTouchProgress: CGPoint = .zero
    private var preveousOneTouchPoint: CGPoint = .zero
    
    private var currentState: CurrentState = .none
    private weak var activeLabel: TextLabelView?
    
    private var isCircleScrollCaptured: Bool = false
    
    enum CurrentState {
        case none
        case oneFingersStarted
        case twoFingersStarted
    }
    
    var isEnable: Bool = true {
        didSet {
            self.gesture?.isEnabled = isEnable
            self.tapGesture?.isEnabled = isEnable
        }
    }
    
    @objc func tapGesture(_ gesture: UITapGestureRecognizer) {
        self.detectTapLabel(gesture, includingFrame: true)
    }
    
    @objc func drawTapGesture(_ gesture: UITapGestureRecognizer) {
        self.detectTapLabel(gesture, includingFrame: false)
    }
    
    @objc func fingerGesture(_ gesture: UIPanGestureRecognizer) {
        switch self.currentState {
        case .none:
            self.activeLabel = nil
            
            self.detectLabel(gesture)
            if gesture.numberOfTouches == 1 {
                self.startOneFingerGesute(gesture)
                self.currentState = .oneFingersStarted
            } else if gesture.numberOfTouches == 2 {
                self.startTwoFingersGesture(gesture)
                self.currentState = .twoFingersStarted
            }
        case .oneFingersStarted:
            if gesture.numberOfTouches == 1 {
                self.moveOneFingerGesture(gesture)
            } else if gesture.numberOfTouches == 2 {
                self.startTwoFingersGesture(gesture)
                self.currentState = .twoFingersStarted
            }
        case .twoFingersStarted:
            if gesture.numberOfTouches == 2 {
                self.moveTwoFingersGesture(gesture)
            } else if gesture.numberOfTouches == 1 {
                self.startOneFingerGesute(gesture)
                self.currentState = .oneFingersStarted
            }
        }
        
        if gesture.state == .ended || gesture.state == .cancelled || gesture.state == .failed {
            self.currentState = .none
            self.rotationCache = 0
            self.isCircleScrollCaptured = false
            self.isInMagniteState = false
        }
    }
    
    var isMenuVisible: Bool = false
    
    func detectTapLabel(_ gesture: UITapGestureRecognizer, includingFrame: Bool) {
        if let textView = self.textViewByTap(gesture: gesture, includingFrame: includingFrame) {
            textView.isMenuVisible = self.isMenuVisible
            textView.tapAction()
            isMenuVisible = false
        } else {
            isMenuVisible = false
            TextSelectionController.shared.deselectText()
        }
    }
    
    func textViewByTap(gesture: UITapGestureRecognizer, includingFrame: Bool) -> TextLabelView? {
        for textView in self.labels {
            let point = gesture.location(in: textView)
            if textView.isTouchedFromDrawer(point: point) {
                return textView
            }
        }
        
        if includingFrame {
            for textView in self.labels {
                let point = gesture.location(in: textView)
                if textView.touchStyle(point: point, supportsResize: true) != .none {
                    return textView
                }
            }
        }
        
        return nil
    }
    
    private func detectLabel(_ gesture: UIPanGestureRecognizer) {
        UIMenuController.shared.hideMenu()
        
        if gesture.numberOfTouches == 1 {
//            self.isCircleScrollCaptured = true
            for textView in self.labels {
                if textView.isSelected {
                    let point = gesture.location(in: textView)
                    switch textView.touchStyle(point: point, supportsResize: true) {
                    case .view:
                        self.activeLabel = textView
                        TextSelectionController.shared.selectText(selectedText: textView)
                        return
                    case .viewResize:
                        self.isCircleScrollCaptured = true
                        self.activeLabel = textView
                        TextSelectionController.shared.selectText(selectedText: textView)
                        return
                    case .none:
                        break
                    }
                } else {
                    let point = gesture.location(in: textView)
                    if textView.isTouchedFromDrawer(point: point) {
                        self.activeLabel = textView
                        TextSelectionController.shared.selectText(selectedText: textView)
                        return
                    }
                }
            }
        } else if gesture.numberOfTouches == 2 {
            for textView in self.labels {
                let point1 = gesture.location(in: textView)
                let point2 = gesture.location(in: textView)
                let point = point1.midPoint(point2)
                if textView.bounds.contains(point) {
                    self.activeLabel = textView
                    TextSelectionController.shared.selectText(selectedText: textView)
                    return
                }
            }
        }
        
        if self.activeLabel == nil {
            TextSelectionController.shared.deselectText()
        }
    }
    
    private func startOneFingerGesute(_ gesture: UIPanGestureRecognizer) {
        guard let view = self.rootView, let activeLabel = self.activeLabel else {
            return
        }
        
        let point = gesture.location(in: view)
        
        self.startOneTouchPoint = point
        self.preveousOneTouchPoint = point
        self.initialMutate = activeLabel.mutateValues
        self.translationOneTouchProgress = self.initialMutate.translation
        self.rotationProgress = self.initialMutate.rotation
        self.oneFingerStartingCenter = CGPoint(
            x: activeLabel.center.x + self.initialMutate.translation.x,
            y: activeLabel.center.y + self.initialMutate.translation.y
        )
        activeLabel.layer.removeAllAnimations()
    }
    
    private func moveOneFingerGesture(_ gesture: UIPanGestureRecognizer) {
        guard let view = self.rootView, let activeLabel = self.activeLabel else {
            return
        }
        
        let point = gesture.location(in: view)
        
        if self.isCircleScrollCaptured {
            let gesturePoint1 = GesturePoint(point1: self.startOneTouchPoint, point2: self.oneFingerStartingCenter)
            let gesturePoint2 = GesturePoint(point1: point, point2: self.oneFingerStartingCenter)
            let scale = self.initialMutate.scale * gesturePoint1.scale(point: gesturePoint2)
            let angel = GesturePoint(point1: self.preveousOneTouchPoint, point2: self.oneFingerStartingCenter).rotation(point: gesturePoint2)
            
            self.applyTransform(scale: scale, rotation: angel, translation: self.initialMutate.translation, activeLabel: activeLabel)
        } else {
            let translation = self.translationOneTouchProgress.subtract(self.preveousOneTouchPoint.subtract(point))
            var transform = activeLabel.layer.transform
            transform.m41 = translation.x
            transform.m42 = translation.y
            activeLabel.layer.transform = transform
            self.translationOneTouchProgress = translation
        }
        
        self.preveousOneTouchPoint = point
    }
    
    private func startTwoFingersGesture(_ gesture: UIPanGestureRecognizer) {
        guard let view = self.rootView, let activeLabel = self.activeLabel else {
            return
        }
        
        guard gesture.numberOfTouches == 2 else {
            return
        }
        
        let point1 = gesture.location(ofTouch: 0, in: view)
        let point2 = gesture.location(ofTouch: 1, in: view)
        
        let point = GesturePoint(point1: point1, point2: point2)
        self.startPoint = point
        self.preveousPoint = point
        self.initialMutate = activeLabel.mutateValues
        self.translationProgress = self.initialMutate.translation
        self.rotationProgress = self.initialMutate.rotation
        activeLabel.layer.removeAllAnimations()
    }
    
    private var rotationCache: CGFloat = 0
    
    private func moveTwoFingersGesture(_ gesture: UIPanGestureRecognizer) {
        guard let view = self.rootView, let activeLabel = self.activeLabel else {
            return
        }
        
        guard gesture.numberOfTouches == 2 else {
            return
        }
        
        let point1 = gesture.location(ofTouch: 0, in: view)
        let point2 = gesture.location(ofTouch: 1, in: view)
        
        let point = GesturePoint(point1: point1, point2: point2)
        
        if gesture.state == .changed {
            let angel = self.preveousPoint.rotation(point: point)
            let scale = self.initialMutate.scale * self.startPoint.scale(point: point)
            let translation = self.preveousPoint.translation(point: point).add(self.translationProgress)
            
            self.preveousPoint = point
            
            self.applyTransform(scale: scale, rotation: angel, translation: translation, activeLabel: activeLabel)
            
            self.translationProgress = translation
        }
    }
    
    var isInMagniteState: Bool = false {
        didSet {
            TextLineAligmentView.shared?.updateVisibility(shouldShow: isInMagniteState)
        }
    }
    
    private func applyTransform(scale: CGFloat, rotation: CGFloat, translation: CGPoint, activeLabel: TextLabelView) {
        var scale = scale
        let oldRotation = self.rotationProgress
        
        self.rotationProgress -= rotation
        
        scale = min(scale, 6)
        
        if self.havePassedCircle(old: oldRotation, new: self.rotationProgress) {
            self.isInMagniteState = true
        }
        
        if self.isInMagniteState {
            TextLineAligmentView.shared?.updatePositionY(activeLabel.center.y + translation.y)
            
            self.rotationCache -= rotation
            
            if abs(self.rotationCache) > 0.15 {
                self.isInMagniteState = false
                activeLabel.alingGestureState.toggle()
                self.rotationProgress -= rotation
                self.rotationCache = 0
            } else {
                self.rotationProgress = 0
                if activeLabel.alingGestureState == .freeform {
                    activeLabel.alingGestureState.toggle()
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }
            }
        }
        
        let rotationTransform = CATransform3DMakeRotation(self.rotationProgress, 0, 0, 1)
        let scaleTranform = CATransform3DMakeScale(scale, scale, 1)
        let translationTransform = CATransform3DMakeTranslation(translation.x, translation.y, 1)
        let finalTransform = CATransform3DConcat(CATransform3DConcat(rotationTransform, scaleTranform), translationTransform)
        activeLabel.layer.transform = finalTransform
        activeLabel.applyScaleFactor(scale: scale * UIScreen.main.scale)
        activeLabel.lastScaleValue = scale
    }
    
    func havePassedCircle(old: CGFloat, new: CGFloat) -> Bool {
        let oldDeg = rad2deg(old)
        let newDeg = rad2deg(new)
        let min = min(oldDeg, newDeg)
        let max = max(oldDeg, newDeg)
        if min < 0 && max > 0 {
            return true
        }
        
        if Int(abs(min)) / 360 != Int(abs(max)) / 360 {
            return true
        }
        
        if abs(max - min) > 359 {
            return true
        }
        
        return false
    }
    
    func rad2deg(_ number: CGFloat) -> CGFloat {
        return number * 180 / .pi
    }
}

class GesturePoint {
    var point1: CGPoint
    var point2: CGPoint
    
    init(point1: CGPoint, point2: CGPoint) {
        self.point1 = point1
        self.point2 = point2
    }
    
    func scale(point: GesturePoint) -> CGFloat {
        let distance1 = self.point1.distance(self.point2)
        let distance2 = point.point1.distance(point.point2)
        let scale = distance2 / distance1
        return scale
    }
    
    func rotation(point: GesturePoint) -> CGFloat {
        let vec1 = CGVector(dx: point1.x - point2.x, dy: point1.y - point2.y)
        let vec2 = CGVector(dx: point.point1.x - point.point2.x, dy: point.point1.y - point.point2.y)
        
        let theta1 = atan2(vec1.dy, vec1.dx)
        let theta2 = atan2(vec2.dy, vec2.dx)
        
        let angle = theta1 - theta2
        return angle
    }
    
    func translation(point: GesturePoint) -> CGPoint {
        let mid1 = self.point1.midPoint(self.point2)
        let mid2 = point.point1.midPoint(point.point2)
        return mid2.subtract(mid1)
    }
}
