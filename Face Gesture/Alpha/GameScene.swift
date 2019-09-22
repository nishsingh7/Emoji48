//
//  GameScene.swift
//  Face Gesture
//
//  Created by Nish Singh on 22/09/2019.
//  Copyright © 2019 Nish Singh. All rights reserved.
//

import UIKit
import SceneKit

let coinTravelTime: Double = 4.0

class GameScene: SCNScene {
    
    let expressions: [Expression]
    let script: SongScript
    private weak var delegate: GameSceneDelegate?
    
    var lanes: [Lane] = []
    var emojis: [EmojiBuilder] = []

    init(expressions: [Expression], script: SongScript, delegate: GameSceneDelegate) {
        self.expressions = expressions
        self.script = script
        self.delegate = delegate
        super.init()
        
        setupScene()
        
        for lane in lanes {
            lane.play()
        }
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
        setupObjects()
        setupCamera()
    }
    
    private func setupLighting() {
        let light = SCNLight()
        light.type = .omni
        light.intensity = 1000
        let lightNode = SCNNode()
        lightNode.light = light
        lightNode.position = SCNVector3(-2, 1, 0)
        rootNode.addChildNode(lightNode)
    }
    
    private func setupCamera() {
        let camera = SCNCamera()
        let cameraNode = SCNNode()
        cameraNode.camera = camera
        camera.zNear = 0.0
        cameraNode.eulerAngles.y = -.pi / 2
        
        let sphere = SCNSphere(radius: 0.03)
        sphere.firstMaterial?.diffuse.contents = UIColor.yellow
        let targetNode1 = SCNNode()
        let targetNode2 = SCNNode()
        
        let laneMidPoint = 0.5 * (lanes.first!.position.z + lanes.last!.position.z)
        targetNode1.position = SCNVector3(0, 0, laneMidPoint)
        
        targetNode2.position = SCNVector3(-0.5, 0, laneMidPoint)
        
        rootNode.addChildNode(targetNode1)
        rootNode.addChildNode(targetNode2)
        
        cameraNode.constraints = [SCNLookAtConstraint(target: targetNode1)]
        
        cameraNode.position = SCNVector3(-0.6, 0.5, 0)
        rootNode.addChildNode(cameraNode)
    }
    
    private func setupObjects() {
        setupFloor()
        setupLanes(forScript: script)
        setupEmojis(fromExpressions: expressions)
        setupConfettiCannons()
    }
    
    private func setupFloor() {
//        let floor = SCNFloor()
//        floor.firstMaterial?.diffuse.contents = UIColor.yellow
//        floor.reflectivity = 0.0
//        let floorNode = SCNNode(geometry: floor)
//        rootNode.addChildNode(floorNode)
    }
    
    private func setupLanes(forScript script: SongScript) {
        let fullWidth = CGFloat(script.laneScripts.count) * SceneGeometry.laneWidth + CGFloat(script.laneScripts.count - 1) * SceneGeometry.laneSpacing
        for i in 0 ... script.laneScripts.count - 1 {
            let lane = Lane(laneIndex: i, laneScript: script.laneScripts[i], delegate: self)
            let zPosition = -fullWidth / 2 + 0.5 * SceneGeometry.laneWidth + (SceneGeometry.laneSpacing + SceneGeometry.laneWidth) * CGFloat(i)
            lane.position = SCNVector3(0, SceneGeometry.laneWidth / 2, zPosition)
            lane.eulerAngles.y = .pi / 2
            lanes.append(lane)
            rootNode.addChildNode(lane)
        }
    }
    
    private func setupEmojis(fromExpressions expressions: [Expression]) {
        for i in 0 ... expressions.count - 1 {
            let emoji = EmojiBuilder(type: expressions[i])
            emojis.append(emoji)
            emoji.position = SCNVector3(SceneGeometry.laneLength / 2, SceneGeometry.laneWidth + 0.1, CGFloat(lanes[i].position.z))
            emoji.eulerAngles.y = -.pi / 2
            rootNode.addChildNode(emoji)
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

struct SceneGeometry {
    static let laneWidth: CGFloat = 0.05
    static let laneLength: CGFloat = 1.0
    static let laneSpacing: CGFloat = 0.03
}
