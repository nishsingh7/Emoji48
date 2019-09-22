//
//  Butler.swift
//  Face Gesture
//
//  Created by Nish Singh on 21/09/2019.
//  Copyright © 2019 Nish Singh. All rights reserved.
//

import UIKit

class Butler {
    
    class func getPrompts(forSong song: Song, difficulty: Difficulty) -> [Prompt]? {
        if let path = Bundle.main.path(forResource: "knightrider-\(difficulty.rawValue)", ofType: "json"), let data = try? Data(contentsOf: URL(fileURLWithPath: path)), let prompts = try? JSONDecoder().decode([Prompt].self, from: data) {
            return prompts
        } else {
            return nil
        }
    }
    
    class func generateSongScript(forSong song: Song, difficulty: Difficulty) -> SongScript? {
        guard let prompts = getPrompts(forSong: song, difficulty: difficulty) else { return nil }
        var laneOffsets: [[Float]] = Array(repeating: [], count: difficulty.numberOfLanes)
        for prompt in prompts {
            laneOffsets[prompt.lane].append(Float(Int(prompt.offset / 100)) / 10)
        }
        
        for i in 0 ... laneOffsets.count - 1 {
            laneOffsets[i].sort { (a, b) -> Bool in
                return b > a
            }
        }
        
        return SongScript(laneScripts: laneOffsets.map { LaneScript(offsets: $0) })
    }
}

enum Expression: String, CaseIterable {
    
    case crazy      // mouthFunnel
    case scream     // mouthOpen / mouthFunnel + eyesRolled
    case money      // tongue
    case eyeroll    // eyesRolled
    case silly      // tongue
    case smirk      // sideLook
    case wink       // wink
    case winkAndTongue  // wink + tongue
    case kiss       // pout (+ wink)
    case happy      // smiling
    
    var image: UIImage? { return UIImage(named: rawValue) }
}

enum Song: String, CaseIterable {
    case knightrider
}

enum Difficulty: String, CaseIterable {
    case easy
    case medium
    case hard
    
    var numberOfLanes: Int {
        switch self {
        case .easy: return 4
        case .medium: return 3
        case .hard: return 4
        }
    }
}
