//
//  CALayerExtensions.swift
//  Telegram-Contest-2022-R1
//
//  Created by Alexander Zimin on 13/10/2022.
//

import UIKit

extension CALayer {
    static func currentSpeed() -> Double {
        return 0.2
    }
}

extension CALayer {
    var translateX: CGFloat {
        return self.transform.m41
    }
    
    var translateY: CGFloat {
        return self.transform.m42
    }
    
    var translateScale: CGFloat {
        return self.transform.m22
    }
    
    var translateXExact: CGFloat {
        if let transform = self.presentation()?.value(forKey: "transform") as? CATransform3D {
            return transform.m41
        }
        return self.translateX
    }
    
    var translateYExact: CGFloat {
        if let transform = self.presentation()?.value(forKey: "transform") as? CATransform3D {
            return transform.m42
        }
        return self.translateY
    }
    
    var translateScaleExact: CGFloat {
        if let transform = self.presentation()?.value(forKey: "transform") as? CATransform3D {
            return transform.m22
        }
        return self.translateScale
    }
}
