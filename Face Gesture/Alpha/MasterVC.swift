//
//  GameVC.swift
//  Face Gesture
//
//  Created by Nish Singh on 21/09/2019.
//  Copyright © 2019 Nish Singh. All rights reserved.
//

import UIKit

class MasterVC: UIViewController {
    
    // Injection parameters
    let expressions: [Expression] = [.crazy, .money, .wink]
    let song: Song = .knightrider
    let difficult: Difficulty = .easy
    
    private lazy var classifier: Classifier = {
        let object = Classifier(parent: self)
        object.detectedExpressionsHandler = { [weak self] expressions in self?.detectedExpression(expressions) }
        return object
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        classifier.huntForExpression(expressions)
    }
    
    private func detectedExpression(_ expressions: [Expression]) {
        
    }
}
