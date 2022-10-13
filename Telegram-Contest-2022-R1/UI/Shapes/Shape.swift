//
//  Shape.swift
//  Telegram-Contest-2022-R1
//
//  Created by Alexander Zimin on 13/10/2022.
//

import Foundation

enum Shape: CaseIterable {
    case rectangle
    case elipse
    case bubble
    case star
    case arrow
    
    var title: String {
        switch self {
        case .rectangle: return "Rectangle"
        case .elipse: return "Ellipse"
        case .bubble: return "Bubble"
        case .star: return "Star"
        case .arrow: return "Arrow"
        }
    }
    
    var iconName: String {
        switch self {
        case .rectangle: return "shapeRectangle"
        case .elipse: return "shapeEllipse"
        case .bubble: return "shapeBubble"
        case .star: return "shapeStar"
        case .arrow: return "shapeArrow"
        }
    }
}
