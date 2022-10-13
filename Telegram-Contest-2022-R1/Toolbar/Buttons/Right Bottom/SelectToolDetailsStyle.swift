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
        return .round
        
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
        default:
            return ""
        }
    }
    
    var outAnimation: String? {
        switch self {
        case .blurEraiser:
            return "send_to_blur_reverse"
        case .arrow:
            return "send_to_arrow_reverse"
        default:
            return nil
        }
    }
}
