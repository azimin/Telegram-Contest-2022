//
//  ViewController.swift
//  Telegram-Contest-2022-R1
//
//  Created by Alexander Zimin on 10/10/2022.
//

import UIKit


class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            let imageContrainer = ImageContainer(image: UIImage(named: "img_template")!)
            let viewController = EditImageViewController(imageContainer: imageContrainer)
            viewController.modalPresentationStyle = .fullScreen
            self.present(viewController, animated: true)
        })
        
       
        // Do any additional setup after loading the view.
    }


}

