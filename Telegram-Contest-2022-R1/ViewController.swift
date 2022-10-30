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
        
        for i in 0..<6 {
            let imageContrainer = ImageContainer(image: UIImage(named: "img_template")!)
            let viewController = EditImageViewController(imageContainer: imageContrainer)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1 + CGFloat(i) * 5, execute: {
                viewController.modalPresentationStyle = .fullScreen
                self.present(viewController, animated: true)
            })
            
            DispatchQueue.main.asyncAfter(deadline: .now() + CGFloat(i) * 5 + 4, execute: {
                viewController.clean()
                self.dismiss(animated: true)
            })
        }
        
       
        // Do any additional setup after loading the view.
    }


}

