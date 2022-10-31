//
//  ViewController.swift
//  Telegram-Contest-2022-R1
//
//  Created by Alexander Zimin on 10/10/2022.
//

import UIKit


class ViewController: UIViewController {
    
    let button = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(button)
        button.setTitle("Create VC", for: .normal)
        button.autolayout {
            button.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).activate()
            button.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).activate()
        }
        
        button.addAction {
            let imageContrainer = ImageContainer(image: UIImage(named: "img_template")!)
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

