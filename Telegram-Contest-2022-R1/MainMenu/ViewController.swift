//
//  ViewController.swift
//  Telegram-Contest-2022-R1
//
//  Created by Alexander Zimin on 10/10/2022.
//

import UIKit
import Lottie

class ViewController: UIViewController {
    
    let contentView = UIView()
    let lottieAnimation = LottieAnimationView(animation:  LottieAnimation.named(
        "duck",
        bundle: .main,
        animationCache: LRUAnimationCache.sharedCache
    ))
    let label = UILabel()
    let button = AllowAccessButton()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.lottieAnimation.play()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
            let imageContrainer = ContentContainer(image: UIImage(named: "img_template")!)
            let viewController = EditImageViewController(imageContainer: imageContrainer)
            viewController.modalPresentationStyle = .fullScreen
            self.present(viewController, animated: true)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 10, execute: {
                viewController.clean()
                self.dismiss(animated: true)
            })
        }
        
//        for i in 0..<1 {
//            let imageContrainer = ImageContainer(image: UIImage(named: "img_template")!)
//            let viewController = EditImageViewController(imageContainer: imageContrainer)
//
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1 + CGFloat(i) * 5 + 10, execute: {
//                viewController.modalPresentationStyle = .fullScreen
//                self.present(viewController, animated: true)
//            })
//
//            DispatchQueue.main.asyncAfter(deadline: .now() + CGFloat(i) * 5 + 10, execute: {
//                viewController.clean()
//                self.dismiss(animated: true)
//            })
//        }
        
       
        // Do any additional setup after loading the view.
    }
    

}

