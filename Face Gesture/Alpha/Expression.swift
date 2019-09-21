//
//  Expression.swift
//  Face Gesture
//
//  Created by Nish Singh on 21/09/2019.
//  Copyright © 2019 Nish Singh. All rights reserved.
//

import UIKit

enum Expression: String, CaseIterable {
    
    case crazy      // mouthFunnel
    case scream     // mouthOpen / mouthFunnel + eyesRolled
    case money      // tongue
    case zip        // mouthClosed
    case eyeroll    // eyesRolled
    case silly      // tongue
    case smirk      // sideLook
    case wink       // wink
    case winkAndTongue  // wink + tongue
    case kiss       // pout (+ wink)
    case happy      // smiling
    
    var image: UIImage? { return UIImage(named: rawValue) }
}
