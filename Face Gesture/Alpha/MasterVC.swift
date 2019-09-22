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
    let expressions: [Expression] = [.sleepy, .eyeroll, .happy, .surprised]
    let song: Song = .knightrider
    let difficult: Difficulty = .easy

    // Components
    @IBOutlet weak var sceneView: SCNView!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var percentageLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    var emotionOverlayView: UIView? = nil
    
    var gameScene: GameScene?
    
    // In-Play Score tracking
    var activeClassifications: [[CoinScoreClassification]] = []
    var streakCount = 0
    var points = 0
    
    private lazy var classifier: Classifier = {
        let object = Classifier(parent: self)
        object.detectedExpressionsHandler = { [weak self] expressions in self?.detectedExpression(expressions) }
        return object
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpUI()
        classifier.huntForExpression(expressions)
    }
    
    private func setUpUI() {
        // Scene View
        let script: SongScript = Butler.generateSongScript(forSong: .knightrider, difficulty: .easy)!
        self.gameScene = GameScene(expressions: expressions, script: script, delegate: self)
        activeClassifications = Array(repeating: [], count: script.laneScripts.count)
        sceneView.scene = gameScene
        sceneView.backgroundColor = UIColor.clear
        sceneView.allowsCameraControl = false
        
        // Score Label
        scoreLabel.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        scoreLabel.backgroundColor = #colorLiteral(red: 0, green: 0.6714670062, blue: 0.6813778281, alpha: 0.5781525088)
        scoreLabel.clipsToBounds = true
        scoreLabel.layer.borderWidth = 3.0
        scoreLabel.layer.borderColor = #colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1)
        scoreLabel.layer.cornerRadius = 20
        scoreLabel.text = String(self.points)
    }
    
    private func detectedExpression(_ expressions: [Expression]) {
        gameScene?.updatedExpression(expressions)
    }
}

extension MasterVC : GameSceneDelegate {
    func didClassifyCoin(laneIndex: Int, classification: CoinScoreClassification) {
        switch classification {
            case .missed:
                self.activeClassifications[laneIndex] = []
                self.streakCount = 0
                self.points -= 5
                self.updateScoreLabel()
                return
            case .hit:
                self.activeClassifications[laneIndex].append(classification)
                self.streakCount += 1
                self.points += 5
                self.updateScoreLabel()
                break;
            case .perfect:
                self.activeClassifications[laneIndex].append(classification)
                self.streakCount += 1
                self.points += 10
                self.updateScoreLabel()
                break;
        }
        
        self.classifyCoinAction(laneIndex: laneIndex, classification: classification)
    }
    
    func classifyCoinAction(laneIndex: Int, classification: CoinScoreClassification) {
        // Action
        if classification == .perfect {
            self.gameScene?.exciteEmoji(atIndex: laneIndex)
        }
        
        // Streak Actions
        if streakCount == 20 {
            self.gameScene?.blowConfetti()
        }
        
        if streakCount == 10 {
            self.showPopup(emotion: .thumbsUp)
        }
        
        if streakCount == 6 {
            self.showPopup(emotion: .confetti)
        }
        
        if self.activeClassifications[laneIndex].count == 3 {
            self.showPopup(emotion: .fire)
        }
    }
    
    func updateScoreLabel() {
        DispatchQueue.main.async {
            self.scoreLabel.text = String(self.points)
        }
    }
    
    func showPopup(emotion: Emotion) {
        if emotionOverlayView == nil {
            self.emotionOverlayView = EmotionOverlayView(emotion: emotion)
            self.emotionOverlayView?.center = self.view.center
            self.emotionOverlayView!.alpha = 0
            self.view.addSubview(self.emotionOverlayView!)
            UIView.animate(withDuration: 0.5, delay: 0.5, options: .curveEaseOut, animations: {
                self.emotionOverlayView!.alpha = 1.0
            })
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                UIView.animate(withDuration: 0.5, delay: 0.5, options: .curveEaseOut, animations: {
                    self.emotionOverlayView!.alpha = 0.0
                },completion: { (finished: Bool) in
                    self.emotionOverlayView!.removeFromSuperview()
                    self.emotionOverlayView = nil
                })
            }
        }
    }
    
}

