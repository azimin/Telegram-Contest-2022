//
//  SelectToolDetailsStyle.swift
//  Telegram-Contest-2022-R1
//
//  Created by Alexander Zimin on 13/10/2022.
//

import Foundation

enum SelectToolDetailsStyle {
    case round
    case arrow
    case eraiser
    case objectEraiser
    case blurEraiser
    
    func getNextSrtyle() -> SelectToolDetailsStyle {        
        switch self {
        case .round: return .arrow
        case .arrow: return .eraiser
        case .eraiser: return .objectEraiser
        case .objectEraiser: return .blurEraiser
        case .blurEraiser: return .arrow
        }
    }
    
    var shortTitle: String {
        switch self {
        case .round: return "Round"
        case .arrow: return "Arrow"
        case .eraiser: return "Eraiser"
        case .objectEraiser: return "Object"
        case .blurEraiser: return "Blur"
        }
    }
    
    var icon: String {
        switch self {
        case .round: return "roundTip"
        case .arrow: return "arrowTip"
        case .eraiser: return "roundTip"
        case .objectEraiser: return "xmarkTip"
        case .blurEraiser: return "blurTip"
        }
    }
    
    var inAnimation: String {
        switch self {
        case .blurEraiser:
            return "send_to_blur"
        case .arrow:
            return "send_to_arrow"
        case .round, .eraiser:
            return "send_to_circle"
        case .objectEraiser:
            return "send_to_mark"
        }
    }
    
    var outAnimation: String {
        switch self {
        case .blurEraiser:
            return "send_to_blur_reverse"
        case .arrow:
            return "send_to_arrow_reverse"
        case .round, .eraiser:
            return "send_to_circle_reverse"
        case .objectEraiser:
            return "send_to_mark_reverse"
        }
    }
}
