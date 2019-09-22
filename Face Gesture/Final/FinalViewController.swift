//
//  FinishedViewController.swift
//  ScreenRecord
//
//  Created by Ben Allen on 22/09/2019.
//  Copyright © 2019 Ben Allen. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import AVFoundation

class LeaderboardItem {
    let name: String!
    let score: Int!
    
    init(name: String, score: Int) {
        self.name = name
        self.score = score
    }
}

class FinalViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var nameInput: UITextField!
    var backgroundPlayer: AVPlayer!
    var backgroundPlayerLayer: AVPlayerLayer!
    var userPlayer: AVPlayer!
    var userPlayerLayer: AVPlayerLayer!
    var leaderboardList: [LeaderboardItem] = []
    
    
    var score: String!
    var url: URL!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.fetchData()
        setupBackgroundVideo()
        scoreLabel.text = score
        setupUserVideo(self.url)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        backgroundPlayer.play()
        userPlayer.play()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        backgroundPlayer.pause()
    }
    func setupUserVideo(_ url: URL) {
        userPlayer = AVPlayer(url: url)
        userPlayerLayer = AVPlayerLayer(player: userPlayer)
        userPlayerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        userPlayer.actionAtItemEnd = AVPlayer.ActionAtItemEnd.none
        userPlayerLayer.frame = self.videoView.layer.bounds
        self.videoView.backgroundColor = UIColor.clear;
        self.videoView.layer.insertSublayer(userPlayerLayer, at: 0)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerItemDidReachEnd(notification:)),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                               object: userPlayer.currentItem)
    }
    
    // View Functions
    @objc func setupBackgroundVideo() {
        let backgroundVideoURL = Bundle.main.url(forResource: "bgvid1", withExtension: "mp4")

        backgroundPlayer = AVPlayer(url: backgroundVideoURL!)
        backgroundPlayerLayer = AVPlayerLayer(player: backgroundPlayer)
        backgroundPlayerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        backgroundPlayer.volume = 0
        backgroundPlayer.actionAtItemEnd = AVPlayer.ActionAtItemEnd.none
        
        backgroundPlayerLayer.frame = view.layer.bounds
        view.backgroundColor = UIColor.clear;
        view.layer.insertSublayer(backgroundPlayerLayer, at: 0)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerItemDidReachEnd(notification:)),
                                                         name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                                         object: backgroundPlayer.currentItem)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.leaderboardList.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        print(leaderboardList[indexPath.row])
        cell.textLabel?.text = leaderboardList[indexPath.row].name
        return cell
        
    }
    
    @objc func playerItemDidReachEnd(notification: NSNotification) {
        let p: AVPlayerItem = notification.object as! AVPlayerItem
        p.seek(to: CMTime.zero, completionHandler: nil)
    }
    
    // Controller Functions
    @IBAction func addScorePress(_ sender: Any) {
        guard let name = nameInput.text, name.count > 0 else {
            let alert = UIAlertController(title: "No Name", message: "No Name available", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        
        let score = 30
        
        addScore(name, score)
        
        let alert = UIAlertController(title: "Added", message: "Added your score!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func fetchData() {
        self.fetchScore()
    }
    
    
    
    // Model functions
    
    let db = Firestore.firestore()
    
    func fetchScore() {
        db.collection("leaderboard").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    let docData =  document.data()
                    let leaderboardItem = LeaderboardItem(name: docData["name"] as! String, score: docData["score"] as! Int)
                    print(leaderboardItem)
                    self.leaderboardList.append(leaderboardItem)
                }
            }
        }
    }
    
    func addScore(_ name: String, _ score: Int) {
        db.collection("leaderboard").addDocument(data: [
            "name": name,
            "score": score,
            "createdAt": Timestamp.init()
        ])
    }
}
