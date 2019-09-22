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
    let expressions: [Expression] = [.crazy, .money, .wink, .scream]
    let song: Song = .knightrider
    let difficult: Difficulty = .easy

    // Components
    @IBOutlet weak var sceneView: SCNView!
    var gameScene: GameScene?
    
    private lazy var classifier: Classifier = {
        let object = Classifier(parent: self)
        object.detectedExpressionsHandler = { [weak self] expressions in self?.detectedExpression(expressions) }
        return object
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.allowsCameraControl = true
        
        let script: SongScript = Butler.generateSongScript(forSong: .knightrider, difficulty: .easy)!
        self.gameScene = GameScene(expressions: expressions, script: script, delegate: self)
        
        sceneView.scene = self.gameScene
        
        classifier.huntForExpression(expressions)
    }
    
    private func detectedExpression(_ expressions: [Expression]) {
        gameScene?.updatedExpression(expressions)
    }
}

extension MasterVC : GameSceneDelegate {
    func didClassifyCoin(laneIndex: Int, classification: CoinScoreClassification) {
        print("Coin Classified")
    }
}
