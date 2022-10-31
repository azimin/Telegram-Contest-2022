//
//  ViewController.swift
//  Telegram-Contest-2022-R1
//
//  Created by Alexander Zimin on 10/10/2022.
//

import UIKit
import Lottie

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let contentView = UIView()
    let lottieAnimation = LottieAnimationView(animation:  LottieAnimation.named(
        "duck",
        bundle: .main,
        animationCache: LRUAnimationCache.sharedCache
    ))
    let label = UILabel()
    let button = AllowAccessButton()
    
    let imagePicker = UIImagePickerController()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.lottieAnimation.play()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imagePicker.delegate = self
        self.imagePicker.mediaTypes = ["public.image", "public.movie"]
        self.imagePicker.allowsEditing = false
        
        NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main) { [weak self] _ in
            self?.lottieAnimation.play()
        }
        
        self.view.addSubview(self.contentView)
        self.contentView.autolayout {
            self.contentView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).activate()
            self.contentView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).activate()
            self.contentView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).activate()
        }
        
        self.lottieAnimation.loopMode = .loop
        self.lottieAnimation.play()
        
        self.contentView.addSubview(self.lottieAnimation)
        self.lottieAnimation.autolayout {
            self.lottieAnimation.constraintSize(width: 144, height: 144)
            self.lottieAnimation.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor).activate()
            self.lottieAnimation.topAnchor.constraint(equalTo: self.contentView.topAnchor).activate()
        }
        
        self.contentView.addSubview(self.label)
        self.label.text = "Access Your Photos and Videos"
        self.label.font = .sfProDisplaySemibold(20)
        self.label.numberOfLines = 0
        self.label.textAlignment = .center
        self.label.autolayout {
            self.label.topAnchor.constraint(equalTo: self.lottieAnimation.bottomAnchor, constant: 20).activate()
            self.label.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 16).activate()
            self.label.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -16).activate()
        }
        
        self.contentView.addSubview(button)
        button.autolayout {
            button.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 16).activate()
            button.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -16).activate()
            button.topAnchor.constraint(equalTo: self.label.bottomAnchor, constant: 28).activate()
            button.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor).activate()
        }
        
        button.addAction {
            self.presentPicker()
        }
    
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: {
//            self.presentEditVC(container: .init(image: UIImage(named: "img_template")!))
//        })
    }
    
    func presentPicker() {
        self.present(self.imagePicker, animated: true, completion: nil)
    }
    
    func presentEditVC(container: ContentContainer) {
        let viewController = EditImageViewController(imageContainer: container)
        viewController.modalPresentationStyle = .fullScreen
        self.present(viewController, animated: true)
    }

    // MARK: - Image Picker
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true)
        
        if let videoPath = info[.mediaURL] as? URL {
            let contentContainer = ContentContainer(videoURL: videoPath)
            self.presentEditVC(container: contentContainer)
            return
        }
        
        guard let image = info[.originalImage] as? UIImage else { return }
        let contentContainer = ContentContainer(image: image)
        self.presentEditVC(container: contentContainer)
    }
}

