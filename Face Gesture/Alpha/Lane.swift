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
    public var isCurrentlySatisfied = false
    private var updateLoop: Timer?
    
    private let length: CGFloat = 1.0
    private let width: CGFloat = 0.05

    public init(laneIndex: Int, laneScript: LaneScript, delegate: LaneDelegate) {
        self.script = laneScript
        self.delegate = delegate
        self.laneIndex = laneIndex
        super.init()
        
        let laneGeom = SCNBox(width: width, height: width, length: length, chamferRadius: 0)
        laneGeom.firstMaterial?.diffuse.contents = UIColor.blue
        let lane = SCNNode(geometry: laneGeom)
        addChildNode(lane)
    }
    
    public func play() {
        // starts the 'conveyor belt' of coins from rolling, the offsets of which are described in self.script
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
            
            
            
        })
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
