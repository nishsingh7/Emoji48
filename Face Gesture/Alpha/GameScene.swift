//
//  GameScene.swift
//  Face Gesture
//
//  Created by Nish Singh on 22/09/2019.
//  Copyright © 2019 Nish Singh. All rights reserved.
//

import UIKit
import SceneKit

class GameScene: SCNScene {
    
    let expressions: [Expression]
    let script: SongScript
    private weak var delegate: GameSceneDelegate?
    
    var lanes: [Lane] = []
    var emojis: [Emoji] = []

    init(expressions: [Expression], script: SongScript, delegate: GameSceneDelegate) {
        self.expressions = expressions
        self.script = script
        self.delegate = delegate
        super.init()
        
        setupScene()
    }
    
    public func updatedExpression(_ currentExpressions: [Expression]) {
        for i in 0 ... lanes.count - 1 {
            lanes[i].isCurrentlySatisfied = currentExpressions.contains(self.expressions[i])
        }
    }
    
    public func exciteEmoji(atIndex index: Int) {
        // called by MasterVC when X happens in a certain lane (perhaps when two or three are hit in quick succession for a given lane, or when a 'perfect' is hit?)
    }
    
    public func blowConfetti() {
        // called by MasterVC when a streak is hit
    }
    
    private func setupScene() {
        setupLighting()
        setupCamera()
        setupObjects()
    }
    
    private func setupLighting() {
        
    }
    
    private func setupCamera() {
        
    }
    
    private func setupObjects() {
        setupLanes(forScript: script)
        setupEmojis(fromExpressions: expressions)
        setupConfettiCannons()
    }
    
    private func setupLanes(forScript script: SongScript) {
        for i in 0 ... script.laneScripts.count - 1 {
            lanes.append(Lane(laneIndex: i, laneScript: script.laneScripts[i], delegate: self))
        }
    }
    
    private func setupEmojis(fromExpressions expressions: [Expression]) {
        for expression in expressions {
            let emoji = Emoji()
            emojis.append(emoji)
            // Configure with correct expression
        }
    }
    
    private func setupConfettiCannons() {
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension GameScene: LaneDelegate {
    func laneDidClassifyCoin(laneIndex: Int, classification: CoinScoreClassification) {
        delegate?.didClassifyCoin(laneIndex: laneIndex, classification: classification)
    }
}

protocol GameSceneDelegate: class {
    func didClassifyCoin(laneIndex: Int, classification: CoinScoreClassification)
}

class Emoji: SCNNode { }
