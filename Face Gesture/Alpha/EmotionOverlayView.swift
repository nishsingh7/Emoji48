//
//  EmojiFeedbackOverlay.swift
//  Face Gesture
//
//  Created by Nish Singh on 22/09/2019.
//  Copyright © 2019 Nish Singh. All rights reserved.
//

import UIKit

class EmotionOverlayView: UIView {
    
    init(emotion: Emotion) {
        super.init(frame: CGRect(x: 100, y: 100, width: 0, height: 0))
        self.backgroundColor = UIColor.red

        UIView.animate(withDuration: 2, animations: {
            self.frame.size = CGSize(width: 100, height: 100)
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
            self.removeFromSuperview()
        }
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
