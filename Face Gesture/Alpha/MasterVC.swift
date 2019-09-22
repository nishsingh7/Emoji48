//
//  GameVC.swift
//  Face Gesture
//
//  Created by Nish Singh on 21/09/2019.
//  Copyright © 2019 Nish Singh. All rights reserved.
//

import UIKit
import SceneKit
import AVFoundation

class MasterVC: UIViewController {

    // Injection parameters
    let expressions: [Expression] = [.sleepy, .money, .surprised, .happy]
    let song: Song = .easySong
    let difficulty: Difficulty = .hard

    // Components
    @IBOutlet weak var sceneView: SCNView!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var percentageLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    var emotionOverlayView: UIView? = nil
    
    var gameScene: GameScene?
    
    var videoURL: URL? = nil

    
    var backgroundPlayer: AVPlayer!
    var backgroundPlayerLayer: AVPlayerLayer!
    
    // In-Play Score tracking
    var activeClassifications: [[CoinScoreClassification]] = []
    var streakCount = 0
    var points = 0
    
    var appRecorder = AppRecorder()
    var cameraRecorder = CameraRecorder()
    
    private lazy var classifier: Classifier = {
        let object = Classifier(parent: self)
        object.detectedExpressionsHandler = { [weak self] expressions in self?.detectedExpression(expressions) }
        object.newFrame = { frame in
            if (self.cameraRecorder.isRecording) {
                self.cameraRecorder.appendBuffer(frame.capturedImage, atTime: frame.timestamp)
            }
        }
        return object
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpUI()
        let script: SongScript = Butler.generateSongScript(forSong: song, difficulty: difficulty)!
        self.gameScene = GameScene(expressions: expressions, script: script, delegate: self)
        activeClassifications = Array(repeating: [], count: script.laneScripts.count)
        sceneView.scene = gameScene
        sceneView.backgroundColor = UIColor.clear
        sceneView.allowsCameraControl = false
        self.setupBackgroundVideo()
        classifier.huntForExpression(expressions)
        
        AudioPlayer.shared.playSong(song)
//        appRecorder.start()
        cameraRecorder.start()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 54) {
            self.stopRecording()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        backgroundPlayer.play()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        backgroundPlayer.pause()
    }
    
    @objc func setupBackgroundVideo() {
        let backgroundVideoURL = Bundle.main.url(forResource: "bgvid1", withExtension: "mp4")
        
        backgroundPlayer = AVPlayer(url: backgroundVideoURL!)
        backgroundPlayerLayer = AVPlayerLayer(player: backgroundPlayer)
        backgroundPlayerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        backgroundPlayer.volume = 0
        backgroundPlayer.actionAtItemEnd = AVPlayer.ActionAtItemEnd.none
        
        backgroundPlayerLayer.frame = view.layer.bounds
        self.view.backgroundColor = UIColor.clear;
        self.view.layer.insertSublayer(backgroundPlayerLayer, at: 0)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerItemDidReachEnd(notification:)),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                               object: backgroundPlayer.currentItem)
    }
    
    @objc func playerItemDidReachEnd(notification: NSNotification) {
        let p: AVPlayerItem = notification.object as! AVPlayerItem
        p.seek(to: CMTime.zero, completionHandler: nil)
    }
    
    private func setUpUI() {
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let final = segue.destination as? FinalViewController {
            final.score = String(points)
            final.url = self.videoURL!
        }
    }
    
    func stopRecording() {
//        let taskGroup = DispatchGroup()
//        var appUrlRaw: URL? = nil
//        var cameraUrlRaw: URL? = nil
//        taskGroup.enter()
//
//        self.appRecorder.stop(completionHandler: { url in
//            appUrlRaw = url
//            taskGroup.leave()
//        })
//        taskGroup.enter()
        
        self.cameraRecorder.stop(completionHandler: { (url) in
//            cameraUrlRaw = url
            self.videoURL = url
            self.performSegue(withIdentifier: "finish", sender: self)
//            taskGroup.leave()
            
            
        })
        
//        taskGroup.wait()
//
//        taskGroup.notify(queue: .main, execute: {
//            guard let appUrl = appUrlRaw, let cameraUrl = cameraUrlRaw else {
//                print("Urls aren't set")
//                return
//            }
//            ShareVideoRenderer.merge(appVideoURL: appUrl, cameraVideoURL: cameraUrl, completionHandler: { (urlRaw, error) in
//                guard let url = urlRaw else {
//                    print("No merge URL")
//                    return
//                }
//                print(url)
//
//                print("Finished")
//
//            })
//        })

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

