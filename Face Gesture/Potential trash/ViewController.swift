////
////  ViewController.swift
////  Face Gesture
////
////  Created by Nish Singh on 21/09/2019.
////  Copyright © 2019 Nish Singh. All rights reserved.
////
//
import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var tableView: UITableView!
    
    let metrics = ["eyeLookUpLeft", "eyeLookUpRight", "eyeLookInLeft", "eyeLookOutLeft", "eyeLookInRight", "eyeLookOutRight", "eyeWideLeft", "eyeWideRight", "eyeSquintLeft", "eyeSquintRight", "eyeBlinkLeft", "eyeBlinkRight", "mouthSmileLeft", "mouthSmileRight", "mouthFunnel", "mouthPucker", "mouthClose", "tongueOut", "browOuterUpLeft", "browOuterUpRight", "browInnerUp"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        tableView.allowsSelection = false
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return metrics.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! MetricCell
        cell.label.text = metrics[indexPath.item]
        cell.progressView.progress = 0.0
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func updatedMetrics(_ newMetrics: [Float]) {
        DispatchQueue.main.async {
            for i in 0 ... newMetrics.count {
                if let cell = self.tableView.cellForRow(at: IndexPath(item: i, section: 0)) as? MetricCell {
                    cell.progressView.progress = newMetrics[i]
                    let progress = Double(Int(newMetrics[i] * 100)) / 100
                    cell.progressLabel.text = String(progress)
                }
            }
        }
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
        let device = MTLCreateSystemDefaultDevice()
        let faceMesh = ARSCNFaceGeometry(device: device!)
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
        
        let browOuterUpLeft = anchor.blendShapes[.browOuterUpLeft]?.floatValue ?? 0.0
        let browOuterUpRight = anchor.blendShapes[.browOuterUpRight]?.floatValue ?? 0.0
        let browInnerUp = anchor.blendShapes[.browInnerUp]?.floatValue ?? 0.0
        
        
        
        let array = [eyeLookUpLeft, eyeLookUpRight, eyeLookInLeft, eyeLookOutLeft, eyeLookInRight, eyeLookOutRight, eyeWideLeft, eyeWideRight, eyeSquintLeft, eyeSquintRight, eyeBlinkLeft, eyeBlinkRight, mouthSmileLeft, mouthSmileRight, mouthFunnel, mouthPucker, mouthClose, tongueOut, browOuterUpLeft, browOuterUpRight, browInnerUp]
        
        updatedMetrics(array)
    }
}
