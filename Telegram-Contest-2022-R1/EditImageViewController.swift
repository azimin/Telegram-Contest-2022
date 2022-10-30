//
//  EditImageViewController.swift
//  Telegram-Contest-2022-R1
//
//  Created by Alexander Zimin on 10/10/2022.
//

import UIKit
import PencilKit
import Lottie

class GlobalConfig {
    static var textRecommendedFrame: CGRect = .zero
    static var textScreenFrame: CGRect = .zero
    static var cachedKeyboardSize: CGSize = .zero
}

class CaptureView: UIView {
    var stopCapture: Bool = false
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if self.stopCapture {
            return false
        }
        return super.point(inside: point, with: event)
    }
}

class EditImageViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, EditToolbarViewDelegate, DrawMetalViewDelegate, ZoomViewDelegate {
    
    let underDevelopmentView = FeatureUnderDevelopmentView()
    let rootTextView = RootTextView()
    
    let topControlls = TopControlsView()
    let zoomView = ZoomView()
    
    let imageContainer: ImageContainer
    let bottomView = UIView()
    let toolbarView = EditToolbarView()
    
    var drawMetalView: DrawMetalView!
    
    var colorPickerView: ColorView?
    
    // Text
    
    override func loadView() {
        self.view = CaptureView(
            frame: UIScreen.main.bounds
        )
    }
    
    init(imageContainer: ImageContainer) {
        self.imageContainer = imageContainer
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.imageContainer = .init(image: UIImage(named: "img_template")!)
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(self.zoomView)
        self.zoomView.frame = self.view.bounds
        self.zoomView.delegate = self
        
        self.bottomView.backgroundColor = UIColor.black
        self.view.addSubview(self.bottomView)
        
        self.drawMetalView = DrawMetalView(frame: self.view.bounds)
        self.drawMetalView.delegate = self
        self.view.addSubview(self.drawMetalView)
        
        self.view.addSubview(self.rootTextView)
        self.rootTextView.frame = self.view.bounds
        
        self.view.addSubview(self.topControlls)
        self.topControlls.autolayout {
            self.topControlls.constraintSize(width: nil, height: 44)
            self.topControlls.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 0).activate()
            self.topControlls.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).activate()
            self.topControlls.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).activate()
        }
        
        self.view.addSubview(self.toolbarView)
        self.toolbarView.delegate = self
        self.toolbarView.autolayout {
            self.toolbarView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0).activate()
            self.toolbarView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0).activate()
            self.toolbarView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -40).activate()
        }
        
        self.bottomView.autolayout {
            self.bottomView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0).activate()
            self.bottomView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0).activate()
            self.bottomView.topAnchor.constraint(equalTo: self.toolbarView.bottomAnchor).activate()
            self.bottomView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).activate()
        }
        
        self.view.addSubview(self.underDevelopmentView)
        self.underDevelopmentView.autolayout {
            self.underDevelopmentView.topAnchor.constraint(equalTo: self.topControlls.bottomAnchor, constant: 16).activate()
            self.underDevelopmentView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 12).activate()
            self.underDevelopmentView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -12).activate()
        }
        
        ContextMenuController.shared.attachToView(view: self.view)
        self.view.layer.speed = Float(CALayer.currentSpeed())
        
        self.zoomView.updateWith(image: self.imageContainer.image)
        self.rootTextView.isUserInteractionEnabled = false
        
        self.toolbarView.segmentItemSelected = { [weak self] index in
            guard let self else { return }
            if index == 0 {
                TextSelectionController.shared.deselectText()
                self.rootTextView.isUserInteractionEnabled = false
            }
            if index == 1 {
                TextSelectionController.shared.deselectText()
                self.rootTextView.isUserInteractionEnabled = true
                self.rootTextView.createTextView(color: .white)
                self.toolbarView.selectColorButton.colorPickerResult = .white
            }
        }
        
        NotificationSystem.shared.subscribeOnEvent(self) { [weak self] event in
            guard let self else { return }
            switch event {
            case .createText:
                TextSelectionController.shared.deselectText()
                self.rootTextView.isUserInteractionEnabled = true
                self.rootTextView.createTextView(color: .white)
                self.toolbarView.selectColorButton.colorPickerResult = .white
            case .presentColorPicker(let color):
                self.presentFullColorPicker(color: color)
            case .textInputViewCreate(let view):
                view.selectColorButton.presetQuickColorSelect = self.selectColorButtonAction(isFromKeyboard: true)
            case .showFeatureUnderDevelopment:
                self.underDevelopmentView.showView()
            case .hideFeatureUnderDevelopment:
                self.underDevelopmentView.hideView(animated: true)
            case .undoMetalLine:
                self.zoomView.linesView.undo()
            default:
                break
            }
        }
        
        self.topControlls.undoButton.addAction(action: {
            UndoManager.shared.undo()
        })
        
        self.topControlls.clearAllButton.addAction(action: { [weak self] in
            guard let self else { return }
            
            NotificationSystem.shared.fireEvent(.clearAll)
            UndoManager.shared.clearAll()
            self.zoomView.linesView.clearAll()
            self.rootTextView.clearAll()
        })
        
        UndoManager.shared.undoManagerUpdated = { [weak self] in
            self?.topControlls.hasChanges = UndoManager.shared.actions.count > 0
        }
        
        self.toolbarView.sendButton.addAction { [weak self] in
            guard let self else { return }
            _ = SaveController.prepareAnsSavePhoto(
                originalImage: self.imageContainer.image,
                drawImage: self.zoomView.linesView.preveousImage,
                textLayer: self.rootTextView.contentView,
                maskContent: self.zoomView.contentView,
                maskFrame: self.zoomView.imageView.frame
            )
        }
        
        self.topControlls.cancelButton.addAction(action: {
            if let view = TextPresentationController.shared.presentedLabel {
                TextPresentationController.shared.deleteView(view: view)
            }
        })
        
        self.topControlls.doneButton.addAction(action: {
            TextPresentationController.shared.presentedLabel?.textView.resignAction()
        })
        
        self.toolbarView.selectColorButton.addAction { [weak self] in
            guard let self else { return }
            self.presentFullColorPicker(color: self.toolbarView.selectColorButton.colorPickerResult)
        }
        
        self.toolbarView.selectColorButton.presetQuickColorSelect = self.selectColorButtonAction(isFromKeyboard: false)
        
        ColorSelectSystem.shared.subscribeOnEvent(self) { color in
            self.toolbarView.selectColorButton.colorPickerResult = color
            
            if let textView = TextPresentationController.shared.presentedLabel {
                textView.updateTextColor(colorResult: color)
            } else if let selectedText = TextSelectionController.shared.selectedText {
                self.toolbarView.selectColorButton.colorPickerResult = color
                selectedText.updateTextColor(colorResult: color)
            } else {
                ToolbarSettings.shared.getToolSetting(style: .fromTool(self.toolbarView.toolsView.selectedTool)).color = color
                self.toolbarView.toolsView.updateToolColor(color)
            }
        }
    }
    
    private func presentFullColorPicker(color: ColorPickerResult) {
        if #available(iOS 14.0, *) {
            let colorPickerViewController = CustomColorPicker()
            colorPickerViewController.selectedColor = color.color
            colorPickerViewController.delegate = self
            self.present(colorPickerViewController, animated: true)
        } else {
            let colorPickerViewController = PoorColorViewController(color: color)
            self.present(colorPickerViewController, animated: true)
        }
    }
    
    func selectColorButtonAction(isFromKeyboard: Bool) -> SelectColorButton.Action {
        return { [weak self] button, gesture in
            guard let self else { return }
            if gesture.state == .began {
                self.presentColorPicker(from: button, cachedOpacity: nil, isFromKeyboard: isFromKeyboard)
            }
            
            if gesture.state == .ended || gesture.state == .failed || gesture.state == .cancelled {
                self.hideColorPicker(isFromKeyboard: isFromKeyboard)
            }
            
            self.colorPickerView?.gestureUpdated(gesture: gesture)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        GlobalConfig.textRecommendedFrame = CGRect(
            x: 0,
            y: self.topControlls.frame.maxY,
            width: self.view.bounds.width,
            height: self.toolbarView.frame.minY - self.topControlls.frame.maxY
        )
        
        GlobalConfig.textScreenFrame = CGRect(
            x: 0,
            y: self.topControlls.frame.maxY,
            width: self.view.bounds.width,
            height: self.view.bounds.height - self.topControlls.frame.maxY
        )
    }

    // MARK: - Image Picker
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true)
        
        guard let image = info[.originalImage] as? UIImage else { return }
        self.imageContainer.image = image
        self.zoomView.updateWith(image: image)
    }
    
    // MARK: - EditToolbarViewDelegate
    
    func exitImageButtonClicked() {
        let picker = UIImagePickerController()
        picker.mediaTypes = ["public.image", "public.movie"]
        picker.delegate = self
        present(picker, animated: true)
    }
    
    // MARK: - DrawMetalViewDelegate
    
    func presentLine(texture: MTLTexture?, color: UIColor) {
        self.zoomView.linesView.addTexture(texture: texture, color: color)
    }
    
    // MARK: - ZoomViewDelegate
    
    func lineSavingCompleted() {
        self.drawMetalView.metalView.isHidden = true
        self.drawMetalView.renderer.isSaving = false
        OperationQueue.main.addOperation({
            self.drawMetalView.metalView.isHidden = false
        })
    }
    
    func shouldUpdateMask(frame: CGRect) {
        self.drawMetalView.updateMask(frame: frame)
    }
    
    // MARK: - Color Picker View
    
    var isColorPickerPresented = false
    
    func presentColorPicker(from: UIView, cachedOpacity: CGFloat?, isFromKeyboard: Bool) {
        guard !self.isColorPickerPresented else {
            return
        }
        
        let width = self.view.bounds.width - 8 - 32
        let size = CGSize(
            width: width,
            height: width * 0.8335
        )
        
        var frame: CGRect
        
        if isFromKeyboard {
            let convertFrame = from.frame
            let yPosition: CGFloat = convertFrame.maxY
            frame = CGRect(
                x: 6,
                y: yPosition - size.height,
                width: size.width,
                height: size.height
            )
        } else {
            let convertFrame = self.view.hierarhyConvertFrame(from.frame, from: from.superview ?? from, to: self.view)
            let yPosition: CGFloat = convertFrame.maxY
            frame = CGRect(
                x: 6,
                y: yPosition - size.height,
                width: size.width,
                height: size.height
            )
        }
        
        let colorPickerView = ColorView(
            frame: frame,
            shouldDisableGestures: true
        )
        colorPickerView.currentColor = .white
        colorPickerView.cachedOpacity = cachedOpacity
        
        if isFromKeyboard {
            from.superview?.addSubview(colorPickerView)
        } else {
            self.view.addSubview(colorPickerView)
        }
        
        self.colorPickerView = colorPickerView
        self.colorPickerView?.showAnimation()
        
        if isFromKeyboard {
            (self.view as? CaptureView)?.stopCapture = true
        }
//        self.topControlls.isUserInteractionEnabled = false
//        self.toolbarView.isUserInteractionEnabled = false
//        self.rootTextView.tapGesture.isEnabled = false
    }
    
    func hideColorPicker(isFromKeyboard: Bool) {
        if isFromKeyboard {
            (self.view as? CaptureView)?.stopCapture = false
        }
//        self.topControlls.isUserInteractionEnabled = true
//        self.toolbarView.isUserInteractionEnabled = true
//        self.rootTextView.tapGesture.isEnabled = true
        
        if let colorPickerView = self.colorPickerView {
            ColorSelectSystem.shared.fireColor(colorPickerView.currentColor)
        }
        self.isColorPickerPresented = false
        self.colorPickerView?.hideAnimation(isFromKeyboard: isFromKeyboard)
        self.colorPickerView = nil
    }
}

@available(iOS 14.0, *)
class CustomColorPicker: UIColorPickerViewController {
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ColorSelectSystem.shared.fireColor(.init(color: self.selectedColor))
    }
}

extension EditImageViewController: UIColorPickerViewControllerDelegate {
    @available(iOS 14.0, *)
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        ColorSelectSystem.shared.fireColor(.init(color: viewController.selectedColor))
    }
}
