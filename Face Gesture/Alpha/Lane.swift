//
//  Lane.swift
//  Face Gesture
//
//  Created by Nish Singh on 22/09/2019.
//  Copyright © 2019 Nish Singh. All rights reserved.
//

import UIKit
import SceneKit

class Lane: SCNNode {
    
    private let script: LaneScript
    private weak var delegate: LaneDelegate?
    private let laneIndex: Int
    public var isCurrentlySatisfied = false { didSet { updatedSatisfiedState() }}
    private var updateLoop: Timer?
    
    private var currentTime: Double = 0.0
    private var coinsDisplayed: [Coin : Double] = [:]
    private var currentScriptIndex: Int = 0
    
    private var laneMaterial: SCNMaterial?

    public init(laneIndex: Int, laneScript: LaneScript, delegate: LaneDelegate) {
        self.script = laneScript
        self.delegate = delegate
        self.laneIndex = laneIndex
        super.init()
        
        let laneGeom = SCNBox(width: SceneGeometry.laneWidth, height: SceneGeometry.laneWidth, length: SceneGeometry.laneLength, chamferRadius: 0.01)
        laneMaterial = SCNMaterial()
        laneMaterial?.diffuse.contents = StyleSheet.defaultLaneColour
        laneGeom.firstMaterial = laneMaterial
        let lane = SCNNode(geometry: laneGeom)
        addChildNode(lane)
        
        print("Lane \(laneIndex) script: \(laneScript)")
    }
    
    public func play() {
        // starts the 'conveyor belt' of coins from rolling, the offsets of which are described in self.script
        currentTime = 0.0
        startUpdateLoop()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func coinHasBeenClassified(score: CoinScoreClassification) {
        // need to figure out when and how we will actually classify each coin - shit tonne of timers?
        delegate?.laneDidClassifyCoin(laneIndex: laneIndex, classification: score)
    }
    
    private func startUpdateLoop() {
        updateLoop = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { (_) in
            self.currentTime += 1
            
            // Check if any coin needs to be rewarded
            if self.isCurrentlySatisfied {
                for item in self.coinsDisplayed {
                    
                    let distanceFromTarget = item.key.position.z + Float(SceneGeometry.laneLength / 2)
                    
                    if distanceFromTarget < 0.1 {
                        item.key.removeFromParentNode()
                        self.coinsDisplayed[item.key] = nil
                        self.delegate?.laneDidClassifyCoin(laneIndex: self.laneIndex, classification: .perfect)
                    } else if distanceFromTarget < 0.25 {
                        item.key.removeFromParentNode()
                        self.coinsDisplayed[item.key] = nil
                        self.delegate?.laneDidClassifyCoin(laneIndex: self.laneIndex, classification: .hit)
                    }
                }
            }
            
            // Check if new coin needs to be generated
            if self.script.offsets.count > self.currentScriptIndex {
                if Double(self.script.offsets[self.currentScriptIndex]) == self.currentTime {
                    self.currentScriptIndex += 1
                    
                    let coin = Coin()
                    self.coinsDisplayed[coin] = self.currentTime
                    self.addChildNode(coin)
                    coin.position = SCNVector3(0, SceneGeometry.laneWidth / 2, SceneGeometry.laneLength * 0.5)
                    
                    let moveAction = SCNAction.move(to: SCNVector3(0, SceneGeometry.laneWidth / 2, -SceneGeometry.laneLength * 0.5), duration: coinTravelTime)
                    coin.runAction(moveAction, completionHandler: {
                        if let _ = self.coinsDisplayed[coin] {
                            coin.removeFromParentNode()
                            self.coinsDisplayed[coin] = nil
                            self.delegate?.laneDidClassifyCoin(laneIndex: self.laneIndex, classification: .missed)
                        }
                    })
                }
            }
        })
    }
    
    private func updatedSatisfiedState() {
        laneMaterial?.diffuse.contents = isCurrentlySatisfied ? StyleSheet.positiveLaneColour : StyleSheet.defaultLaneColour
    }
    
    private func generateDisc() {
//        let
    }
}

protocol LaneDelegate: class {
    func laneDidClassifyCoin(laneIndex: Int, classification: CoinScoreClassification)
}

enum CoinScoreClassification: String {
    case missed
    case hit
    case perfect
}

class Coin: SCNNode {
    override init() {
        super.init()
        let cylinderGeom = SCNCylinder(radius: SceneGeometry.laneWidth * 0.4, height: SceneGeometry.laneWidth * 0.4 * 0.2)
        cylinderGeom.firstMaterial?.diffuse.contents = StyleSheet.coinColour
        let mesh = SCNNode(geometry: cylinderGeom)
        addChildNode(mesh)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
