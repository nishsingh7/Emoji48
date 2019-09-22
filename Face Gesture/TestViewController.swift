//
//  TestViewController.swift
//  Face Gesture
//
//  Created by Nish Singh on 21/09/2019.
//  Copyright © 2019 Nish Singh. All rights reserved.
//

import UIKit
import SceneKit

class TestViewController: UIViewController, GameSceneDelegate {
    
    func didClassifyCoin(laneIndex: Int, classification: CoinScoreClassification) {
        print("CLASSIFIED COIN \(classification.rawValue) on lane \(laneIndex)")
    }
    
    @IBOutlet weak var sceneView: SCNView!
    
    var gameScene: GameScene!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let script = Butler.generateSongScript(forSong: .knightrider, difficulty: .easy) {
            gameScene = GameScene(expressions: [.crazy, .eyeroll, .kiss, .silly], script: script, delegate: self)
            sceneView.scene = gameScene
        }
    }
}
