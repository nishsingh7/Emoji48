//
//  Expression.swift
//  Face Gesture
//
//  Created by Nish Singh on 21/09/2019.
//  Copyright © 2019 Nish Singh. All rights reserved.
//

import UIKit

enum Expression: String, CaseIterable {
    case tongueOut
    case smiling
    case puffedCheeks
    case eyeRoll
    case mouthOpen
    case crossedEyed
    case leftWink
    case rightWink
    case noseSneer
    case mouthKiss
    
    var image: UIImage? {
        switch self {
        case .tongueOut: return UIImage(named: "tongue-money")
        case .smiling: return UIImage(named: "eye-closed-smile-blush")
        case .puffedCheeks: return UIImage(named: "devil")
        case .eyeRoll: return UIImage(named: "eyeroll")
        case .mouthOpen: return UIImage(named: "mouth-funnel")
        case .crossedEyed: return UIImage(named: "dog")
        case .leftWink: return UIImage(named: "left-wink")
        case .rightWink: return UIImage(named: "mouth-funnel-eyeroll")
        case .noseSneer: return UIImage(named: "ghost")
        case .mouthKiss: return UIImage(named: "left-wink-pout")
        }
    }
}
