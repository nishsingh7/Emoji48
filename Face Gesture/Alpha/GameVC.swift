//
//  GameVC.swift
//  Face Gesture
//
//  Created by Nish Singh on 21/09/2019.
//  Copyright © 2019 Nish Singh. All rights reserved.
//

import UIKit

class GameVC: UIViewController {
    
    var expressions: [ExpressionTestObject] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    private lazy var classifier: Classifier = {
        let object = Classifier(parent: self)
        object.detectedExpressionsHandler = { [weak self] expressions in self?.detectedExpression(expressions) }
        return object
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        classifier.huntForExpression([])
        
        for expression in Expression.allCases {
            expressions.append(ExpressionTestObject(expression: expression, isEnabled: false))
        }
        
        tableView.reloadData()
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

extension GameVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return expressions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! ExpressionCell
        cell.icon.image = expressions[indexPath.item].expression.image
        cell.selectionStyle = .none
        cell.icon.alpha = expressions[indexPath.item].isEnabled ? 1 : 0.2
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        expressions[indexPath.item].isEnabled.toggle()
        classifier.huntForExpression(expressions.filter { $0.isEnabled }.map { $0.expression })
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

struct ExpressionTestObject {
    let expression: Expression
    var isEnabled = false
}
