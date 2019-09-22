//
//  AudioPlayer.swift
//  Face Gesture
//
//  Created by Nish Singh on 22/09/2019.
//  Copyright © 2019 Nish Singh. All rights reserved.
//

import UIKit
import CoreAudio
import AVFoundation
import AudioToolbox

class AudioPlayer: NSObject {
    
    static let shared = AudioPlayer()
    
    var mainPlayer: AVAudioPlayer?
    
    func playSong(_ song: Song) {
        
        guard let url = Bundle.main.url(forResource: song.rawValue, withExtension: "mp3") else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            mainPlayer = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            mainPlayer?.play()
            mainPlayer?.numberOfLoops = 0
        } catch let error {
            print(error.localizedDescription)
        }
    }
}
