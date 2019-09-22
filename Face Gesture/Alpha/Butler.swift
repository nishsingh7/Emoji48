//
//  Butler.swift
//  Face Gesture
//
//  Created by Nish Singh on 21/09/2019.
//  Copyright © 2019 Nish Singh. All rights reserved.
//

import UIKit

class Butler {
    
    class func getMusicSheet(forSong song: Song, difficulty: Difficulty) -> MusicSheet? {
        if let path = Bundle.main.path(forResource: "\(song.rawValue)-\(difficulty.rawValue)", ofType: "json"), let data = try? Data(contentsOf: URL(fileURLWithPath: path)), let sheet = try? JSONDecoder().decode(MusicSheet.self, from: data) {
            return sheet
        } else {
            return nil
        }
    }
    
    class func generateSongScript(forSong song: Song, difficulty: Difficulty) -> SongScript? {
        guard let sheet = getMusicSheet(forSong: song, difficulty: difficulty) else { return nil }
        var laneOffsets: [[Int]] = Array(repeating: [], count: difficulty.numberOfLanes)
        for prompt in sheet.beats {
            laneOffsets[prompt.lane].append(Int(prompt.offset / 100))
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
    case sleepy     // eyesClosed
    case surprised  // surprised
    
    var image: UIImage? { return UIImage(named: rawValue) }
}

enum Song: String, CaseIterable {
    case knightrider
    case easySong
}

enum Difficulty: String, CaseIterable {
    case easy
    case medium
    case hard
    
    var numberOfLanes: Int {
        switch self {
        case .easy: return 2
        case .medium: return 3
        case .hard: return 4
        }
    }
}

struct StyleSheet {
    static let positiveLaneColour = #colorLiteral(red: 0, green: 1, blue: 0, alpha: 1)
    static let defaultLaneColour = #colorLiteral(red: 1, green: 0, blue: 0.4578366876, alpha: 1)
    static let coinColour = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
}
