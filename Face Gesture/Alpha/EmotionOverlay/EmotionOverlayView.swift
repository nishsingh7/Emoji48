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
        super.init(frame: CGRect(x: 0, y: 0, width: 130, height: 130))
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 130, height: 130))
        imageView.image = UIImage.animatedImage(with: GifHelper.toImages(gifNamed: emotion.rawValue)!, duration: 1.0)
        self.addSubview(imageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

enum Emotion: String {
    case thumbsUp
    case confetti
    case fire
}
