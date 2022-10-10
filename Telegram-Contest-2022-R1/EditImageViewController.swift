//
//  EditImageViewController.swift
//  Telegram-Contest-2022-R1
//
//  Created by Alexander Zimin on 10/10/2022.
//

import UIKit

class EditImageViewController: UIViewController {
    let imageContainer: ImageContainer
    
    init(imageContainer: ImageContainer) {
        self.imageContainer = imageContainer
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
