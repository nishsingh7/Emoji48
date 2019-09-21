//
//  ViewController.swift
//  Face Gesture
//
//  Created by Nish Singh on 21/09/2019.
//  Copyright © 2019 Nish Singh. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var outputLabel: UILabel!
    
    enum Expression: String {
        case tongueOut
        case smiling
        case puffedCheeks
        case eyeRoll
        case mouthOpen
        case crossedEyed
        case leftWink
        case rightWink
        case noseSneer
        case mouthKiss
        case none
    }
    
    var currentState: Expression = .none { willSet { if newValue != self.currentState {
        DispatchQueue.main.async { self.outputLabel.text = newValue.rawValue }}}}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARFaceTrackingConfiguration()
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let faceMesh = ARSCNFaceGeometry(device: sceneView.device!)
        let node = SCNNode(geometry: faceMesh)
        node.geometry?.firstMaterial?.fillMode = .lines
        return node
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) { }
    
    func sessionWasInterrupted(_ session: ARSession) { }
    
    func sessionInterruptionEnded(_ session: ARSession) { }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        if let faceAnchor = anchor as? ARFaceAnchor, let faceGeometry = node.geometry as? ARSCNFaceGeometry {
            faceGeometry.update(from: faceAnchor.geometry)
            extractExpression(anchor: faceAnchor)
        }
    }
    
    func extractExpression(anchor: ARFaceAnchor) {
    
        let smileLeft = anchor.blendShapes[.mouthSmileLeft]
        let smileRight = anchor.blendShapes[.mouthSmileRight]
        let cheekPuff = anchor.blendShapes[.cheekPuff]
        let tongue = anchor.blendShapes[.tongueOut]
        let leftEyeUp = anchor.blendShapes[.eyeLookUpLeft]
        let rightEyeUp = anchor.blendShapes[.eyeLookUpRight]
        let mouthOpen = anchor.blendShapes[.mouthFunnel]
        let leftEyeIn = anchor.blendShapes[.eyeLookInLeft]
        let rightEyeIn = anchor.blendShapes[.eyeLookInRight]
        let leftWink = anchor.blendShapes[.eyeBlinkLeft]
        let rightWink = anchor.blendShapes[.eyeBlinkRight]
        let noseSneerLeft = anchor.blendShapes[.noseSneerLeft]
        let noseSneerRight = anchor.blendShapes[.noseSneerRight]
        let mouthKiss = anchor.blendShapes[.mouthPucker]
        
        if ((smileLeft?.decimalValue ?? 0.0) + (smileRight?.decimalValue ?? 0.0)) > 0.9 {
            currentState = .smiling
        } else if cheekPuff?.decimalValue ?? 0.0 > 0.3 {
            currentState = .puffedCheeks
        } else if tongue?.decimalValue ?? 0.0 > 0.1 {
            currentState = .tongueOut
        } else if ((leftEyeUp?.decimalValue ?? 0.0) + (rightEyeUp?.decimalValue ?? 0.0)) > 0.9  {
            currentState = .eyeRoll
        } else if mouthOpen?.decimalValue ?? 0.0 > 0.3 {
            currentState = .mouthOpen
        } else if ((leftEyeIn?.decimalValue ?? 0.0) + (rightEyeIn?.decimalValue ?? 0.0)) > 0.9 {
            currentState = .crossedEyed
        } else if leftWink?.decimalValue ?? 0.0 > 0.1 {
            currentState = .leftWink
        } else if rightWink?.decimalValue ?? 0.0 > 0.1 {
            currentState = .rightWink
        } else if ((noseSneerLeft?.decimalValue ?? 0.0) + (noseSneerRight?.decimalValue ?? 0.0)) > 0.9 {
            currentState = .noseSneer
        } else if mouthKiss?.decimalValue ?? 0.0 > 0.1 {
            currentState = .mouthKiss
        } else {
            currentState = .none
        }
    }
}
