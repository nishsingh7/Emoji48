//
//  PromptScript.swift
//  Face Gesture
//
//  Created by Nish Singh on 21/09/2019.
//  Copyright © 2019 Nish Singh. All rights reserved.
//

import Foundation

struct MusicSheet: Decodable {
    let startOffset: Float
    let bpm: Float
    let beats: [Prompt]
    
    struct Prompt: Decodable {
        let lane: Int
        let offset: Float
    }
}

struct SongScript {
    let laneScripts: [LaneScript]
}

struct LaneScript {
    let offsets: [Int]
}
