//
//  EditImageViewController.swift
//  Telegram-Contest-2022-R1
//
//  Created by Alexander Zimin on 10/10/2022.
//

import UIKit
import PencilKit
import Lottie

class EditImageViewController: UIViewController, PKToolPickerObserver {
    let imageContainer: ImageContainer
    let imageView: UIImageView = UIImageView()
    let toolbarView = EditToolbarView()
    
    private var canvasView = PKCanvasView()
    
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
        
        self.imageView.image = self.imageContainer.image
        self.view.addSubview(self.imageView)
        
        self.imageView.autolayout {
            self.imageView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0).activate()
            self.imageView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0).activate()
            self.imageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0).activate()
        }
        
        self.canvasView.allowsFingerDrawing = true
        self.canvasView.backgroundColor = .black
        self.view.addSubview(self.canvasView)
        self.canvasView.autolayout {
            self.canvasView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0).activate()
            self.canvasView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0).activate()
            self.canvasView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0).activate()
            self.canvasView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).activate()
        }
        
        self.view.addSubview(self.toolbarView)
        self.toolbarView.autolayout {
            self.toolbarView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0).activate()
            self.toolbarView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0).activate()
            self.toolbarView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -40).activate()
        }
        
//        let lottie = LottieAnimationView()
//        self.view.addSubview(lottie)
//        lottie.frame = CGRect(x: 100, y: 100, width: 50, height: 50)
//        
//        let animation = LottieAnimation.named(
//            "send_to_circle",
//            bundle: .main,
//            animationCache: LRUAnimationCache.sharedCache
//        )
//        
//        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
//            lottie.animation = animation
//            lottie.animationSpeed = 1.05 / 4
//            lottie.play(fromProgress: 1, toProgress: 0)
//        })
    }

}
