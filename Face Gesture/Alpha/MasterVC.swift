//
//  GameVC.swift
//  Face Gesture
//
//  Created by Nish Singh on 21/09/2019.
//  Copyright © 2019 Nish Singh. All rights reserved.
//

import UIKit
import SceneKit


class MasterVC: UIViewController {

    // Injection parameters
    let expressions: [Expression] = [.crazy, .money, .wink, .kiss]
    let song: Song = .knightrider
    let difficult: Difficulty = .easy

    // Components
    @IBOutlet weak var sceneView: SCNView!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var percentageLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    
    var gameScene: GameScene?
    
//    var coinClassification: [CoinScoreClassification]
    
    
    private lazy var classifier: Classifier = {
        let object = Classifier(parent: self)
        object.detectedExpressionsHandler = { [weak self] expressions in self?.detectedExpression(expressions) }
        return object
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpUI()
        let script: SongScript = Butler.generateSongScript(forSong: .knightrider, difficulty: .easy)!
        self.gameScene = GameScene(expressions: expressions, script: script, delegate: self)
        sceneView.scene = gameScene
        sceneView.allowsCameraControl = true
        classifier.huntForExpression(expressions)
    }
    
    private func setUpUI() {
        scoreLabel.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        scoreLabel.backgroundColor = #colorLiteral(red: 0, green: 0.6714670062, blue: 0.6813778281, alpha: 0.5781525088)
        scoreLabel.clipsToBounds = true
        scoreLabel.layer.borderWidth = 3.0
        scoreLabel.layer.borderColor = #colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1)
        scoreLabel.layer.cornerRadius = 20
    }
    
    private func detectedExpression(_ expressions: [Expression]) {
        gameScene?.updatedExpression(expressions)
    }
}

extension MasterVC : GameSceneDelegate {
    func didClassifyCoin(laneIndex: Int, classification: CoinScoreClassification) {
        print("Coin Classified")
//        coinClassificationp[laneIndex]
    }
}

