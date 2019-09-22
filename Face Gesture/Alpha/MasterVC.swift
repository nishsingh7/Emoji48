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
        DispatchQueue.main.async {
            for i in 0 ... self.expressions.count - 1 {
                if let cell = self.tableView.cellForRow(at: IndexPath(item: i, section: 0)) {
                    cell.backgroundColor = expressions.contains(self.expressions[i].expression) ? #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1) : #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                }
            }
        }
    }
}
