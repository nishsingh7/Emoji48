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
        
        // Mesh properties
        let smileLeft = anchor.blendShapes[.mouthSmileLeft]?.decimalValue ?? 0.0
        let smileRight = anchor.blendShapes[.mouthSmileRight]?.decimalValue ?? 0.0
        let tongue = anchor.blendShapes[.tongueOut]?.decimalValue ?? 0.0
        let leftEyeUp = anchor.blendShapes[.eyeLookUpLeft]?.decimalValue ?? 0.0
        let rightEyeUp = anchor.blendShapes[.eyeLookUpRight]?.decimalValue ?? 0.0
        let mouthFunnel = anchor.blendShapes[.mouthFunnel]?.decimalValue ?? 0.0
        let leftEyeIn = anchor.blendShapes[.eyeLookInLeft]?.decimalValue ?? 0.0
        let rightEyeIn = anchor.blendShapes[.eyeLookInRight]?.decimalValue ?? 0.0
        let leftWink = anchor.blendShapes[.eyeSquintLeft]?.decimalValue ?? 0.0
        let rightWink = anchor.blendShapes[.eyeSquintRight]?.decimalValue ?? 0.0
        let mouthKiss = anchor.blendShapes[.mouthPucker]?.decimalValue ?? 0.0
        let mouthClosed = anchor.blendShapes[.mouthClose]?.decimalValue ?? 0.0
        
        // Classifier functions
        func mouthIsFunnelled() -> Bool { return mouthFunnel > 0.8 }
        
        func eyesAreRolled() -> Bool { return leftEyeUp > 0.8 && rightEyeUp > 0.8 }
        
        func eyesAreCrossed() -> Bool { return leftEyeIn > 0.7 && rightEyeIn > 0.7 }
        
        func tongueIsOut() -> Bool { return tongue > 0.8 }
        
        func mouthIsClosed() -> Bool { return mouthClosed > 0.8 }
        
        func isSideGlancing() -> Bool {
            return true
        }
        
        func isWinking() -> Bool { return (leftWink > 0.8 && rightWink < 0.3) || (rightWink > 0.8 && leftWink < 0.3) }
        
        func isPouting() -> Bool { return mouthKiss > 0.8 }
        
        func isSmiling() -> Bool { return smileLeft > 0.8 && smileRight > 0.8 }
        
        func expressionIsSatisfied(_ expression: Expression) -> Bool {
            switch expression {
            case .crazy: return (mouthIsFunnelled())
            case .scream: return (mouthIsFunnelled() && eyesAreRolled())
            case .money: return (tongueIsOut())
            case .zip: return (mouthIsClosed())
            case .eyeroll: return (eyesAreRolled())
            case .silly: return (tongueIsOut() && eyesAreCrossed())
            case .smirk: return (isSideGlancing())
            case .wink: return (isWinking())
            case .winkAndTongue: return (isWinking() && tongueIsOut())
            case .kiss: return (isPouting() && isWinking())
            case .happy: return (isSmiling())
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
