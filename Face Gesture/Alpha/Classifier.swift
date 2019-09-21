//
//  Classifier.swift
//  Face Gesture
//
//  Created by Nish Singh on 21/09/2019.
//  Copyright © 2019 Nish Singh. All rights reserved.
//

import Foundation
import ARKit
import AVFoundation

class Classifier: UIView, ARSCNViewDelegate {
    
    var sceneView: ARSCNView!
    
    private weak var parent: UIViewController?
    
    var expressionList: [Expression] = []
    
    var detectedExpressionsHandler: (([Expression]) -> Void)? = nil
    
    public func huntForExpression(_ expressions: [Expression]) {
        print("NOW HUNTING FOR \(expressions.map { $0.rawValue })")
        self.expressionList = expressions
    }
    
    public init(parent: UIViewController) {
        self.parent = parent
        super.init(frame: parent.view.bounds)
        isHidden = true
        isUserInteractionEnabled = false
        
        parent.view.addSubview(self)
        
        sceneView = ARSCNView(frame: bounds)
        sceneView.delegate = self
        
        addSubview(sceneView)
        
        let configuration = ARFaceTrackingConfiguration()
        sceneView.session.run(configuration)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let faceMesh = ARSCNFaceGeometry(device: sceneView.device!)
        let node = SCNNode(geometry: faceMesh)
        node.geometry?.firstMaterial?.fillMode = .lines
        return node
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        if let faceAnchor = anchor as? ARFaceAnchor, let faceGeometry = node.geometry as? ARSCNFaceGeometry {
            faceGeometry.update(from: faceAnchor.geometry)
            detectedExpressionsHandler?(extractExpressions(anchor: faceAnchor))
        }
    }
    
    func extractExpressions(anchor: ARFaceAnchor) -> [Expression]  {
        
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
        
        func expressionIsSatisfied(_ expression: Expression) -> Bool {
            switch expression {
            case .tongueOut: return tongue?.decimalValue ?? 0.0 > 0.1
            case .smiling: return ((smileLeft?.decimalValue ?? 0.0) + (smileRight?.decimalValue ?? 0.0)) > 0.9
            case .puffedCheeks: return cheekPuff?.decimalValue ?? 0.0 > 0.3
            case .eyeRoll: return ((leftEyeUp?.decimalValue ?? 0.0) + (rightEyeUp?.decimalValue ?? 0.0)) > 0.9
            case .mouthOpen: return mouthOpen?.decimalValue ?? 0.0 > 0.3
            case .crossedEyed: return ((leftEyeIn?.decimalValue ?? 0.0) + (rightEyeIn?.decimalValue ?? 0.0)) > 0.9
            case .leftWink: return leftWink?.decimalValue ?? 0.0 > 0.1
            case .rightWink: return rightWink?.decimalValue ?? 0.0 > 0.1
            case .noseSneer: return ((noseSneerLeft?.decimalValue ?? 0.0) + (noseSneerRight?.decimalValue ?? 0.0)) > 0.9
            case .mouthKiss: return mouthKiss?.decimalValue ?? 0.0 > 0.1
            }
        }
        
        var output: [Expression] = []
        
        for expression in expressionList {
            if expressionIsSatisfied(expression) {
                output.append(expression)
            }
        }
        
        return output
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension Classifier: ARSessionDelegate {
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        let _ = frame.capturedImage
        //TODO: DO SOMETHING WITH THIS FRAME
    }
}
