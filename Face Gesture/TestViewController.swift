//
//  TestViewController.swift
//  Face Gesture
//
//  Created by Nish Singh on 21/09/2019.
//  Copyright © 2019 Nish Singh. All rights reserved.
//

import UIKit

class TestViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let script = Butler.generateSongScript(forSong: .knightrider, difficulty: .easy) {
            print(script)
        }
    }
}
