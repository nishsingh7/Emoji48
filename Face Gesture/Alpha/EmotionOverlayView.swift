//
//  EmojiFeedbackOverlay.swift
//  Face Gesture
//
//  Created by Nish Singh on 22/09/2019.
//  Copyright © 2019 Nish Singh. All rights reserved.
//

import UIKit

class EmotionOverlayView: UIView {

    init(frame: CGRect, emotion: Emotion) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

enum Emotion {
    case thumbsUp
    case thumbsDown
    case heart
}
