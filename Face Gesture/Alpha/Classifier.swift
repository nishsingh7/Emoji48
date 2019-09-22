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
        let device = MTLCreateSystemDefaultDevice()
        let faceMesh = ARSCNFaceGeometry(device: device!)
        let node = SCNNode(geometry: faceMesh)
        node.geometry?.firstMaterial?.fillMode = .lines
        return node
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        if let faceAnchor = anchor as? ARFaceAnchor, let faceGeometry = node.geometry as? ARSCNFaceGeometry {
            faceGeometry.update(from: faceAnchor.geometry)
            detectedExpressionsHandler?(extractExpressions(fromAnchor: faceAnchor))
        }
    }
    
    func extractExpressions(fromAnchor anchor: ARFaceAnchor) -> [Expression]  {
        
        // Mesh properties
        let eyeLookUpLeft = anchor.blendShapes[.eyeLookUpLeft]?.floatValue ?? 0.0
        let eyeLookUpRight = anchor.blendShapes[.eyeLookUpRight]?.floatValue ?? 0.0
        let eyeLookInLeft = anchor.blendShapes[.eyeLookInLeft]?.floatValue ?? 0.0
        let eyeLookOutLeft = anchor.blendShapes[.eyeLookOutLeft]?.floatValue ?? 0.0
        let eyeLookInRight = anchor.blendShapes[.eyeLookInRight]?.floatValue ?? 0.0
        let eyeLookOutRight = anchor.blendShapes[.eyeLookOutRight]?.floatValue ?? 0.0
        let eyeWideLeft = anchor.blendShapes[.eyeWideLeft]?.floatValue ?? 0.0
        let eyeWideRight = anchor.blendShapes[.eyeWideRight]?.floatValue ?? 0.0
        let eyeSquintLeft = anchor.blendShapes[.eyeSquintLeft]?.floatValue ?? 0.0
        let eyeSquintRight = anchor.blendShapes[.eyeSquintRight]?.floatValue ?? 0.0
        let eyeBlinkLeft = anchor.blendShapes[.eyeBlinkLeft]?.floatValue ?? 0.0
        let eyeBlinkRight = anchor.blendShapes[.eyeBlinkRight]?.floatValue ?? 0.0
        let mouthSmileLeft = anchor.blendShapes[.mouthSmileLeft]?.floatValue ?? 0.0
        let mouthSmileRight = anchor.blendShapes[.mouthSmileRight]?.floatValue ?? 0.0
        let mouthFunnel = anchor.blendShapes[.mouthFunnel]?.floatValue ?? 0.0
        let mouthPucker = anchor.blendShapes[.mouthPucker]?.floatValue ?? 0.0
        let mouthClose = anchor.blendShapes[.mouthClose]?.floatValue ?? 0.0
        let tongueOut = anchor.blendShapes[.tongueOut]?.floatValue ?? 0.0
        let browInnerUp = anchor.blendShapes[.browInnerUp]?.floatValue ?? 0.0
        
        // Classifier functions
        func mouthIsOpen() -> Bool { return mouthFunnel > 0.2 } // (0.3)
        
        func eyesAreRolled() -> Bool { return eyeLookUpLeft > 0.30 && eyeLookUpRight > 0.30 }
        
        func eyesAreClosed() -> Bool { return eyeBlinkLeft > 0.4 && eyeBlinkRight > 0.4 }
        
        func tongueIsOut() -> Bool { return tongueOut > 0.5 }
        
        func isSideGlancing() -> Bool { return (eyeLookInLeft > 0.5 && eyeLookOutRight > 0.5) || (eyeLookInRight > 0.5 && eyeLookOutLeft > 0.5) }
        
        func isWinking() -> Bool { return ( (eyeBlinkLeft - eyeBlinkRight).magnitude > 0.1) }
        
        func isPouting() -> Bool { return mouthPucker > 0.40 }
        
        func isSmiling() -> Bool { return mouthSmileLeft > 0.4 && mouthSmileRight > 0.4 }
        
        func eyebrowsAreRaised() -> Bool { return browInnerUp > 0.6 }
        
        func expressionIsSatisfied(_ expression: Expression) -> Bool {
            switch expression {
            case .crazy: return (mouthIsOpen())
            case .scream: return (mouthIsOpen() && eyesAreRolled())
            case .money: return (tongueIsOut())
            case .eyeroll: return (eyesAreRolled())
            case .silly: return (tongueIsOut())
            case .smirk: return (isSideGlancing())
            case .wink: return (isWinking())
            case .winkAndTongue: return ((isWinking() || eyesAreClosed()) && tongueIsOut())
            case .kiss: return ((isPouting() || mouthIsOpen()) && (isWinking() || eyesAreClosed()))
            case .happy: return (isSmiling())
            case .sleepy: return (eyesAreClosed())
            case .surprised: return (eyebrowsAreRaised())
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
