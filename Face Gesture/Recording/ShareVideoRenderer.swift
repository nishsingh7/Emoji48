//
//  ShareVideoRenderer.swift
//  ScreenRecord
//
//  Created by Ben Allen on 21/09/2019.
//  Copyright © 2019 Ben Allen. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

class ShareVideoRenderer {
    func generateOverlay() {
        
        let imglogo = UIImage(named: "video_button")
        let watermarkLayer = CALayer()
        watermarkLayer.contents = imglogo?.cgImage
        watermarkLayer.frame = CGRect(x: 5, y: 25, width: 57, height: 57)
        watermarkLayer.opacity = 0.85
        
        
        let layercomposition = AVMutableVideoComposition()
        layercomposition.frameDuration = CMTimeMake(value: 1, timescale: 30)
        layercomposition.renderScale = 1.0
        layercomposition.renderSize = CGSize(width: 1920, height: 1080)
        
//        layercomposition.animationTool = AVVideoCompositionCoreAnimationTool(
//            postProcessingAsVideoLayers: [videolayer], in: parentlayer)

        
    }
    
    static func merge(appVideoURL: URL, cameraVideoURL: URL, completionHandler handler: @escaping (URL?, Error?) -> Void) {
        let appVideo = AVAsset(url: appVideoURL)
        let cameraVideo = AVAsset(url: appVideoURL)
        
        
        
        let mainComposition = AVMutableComposition()
        mainComposition.naturalSize = CGSize.init(width: 1920, height: 1080)
        let appVideoTrack = mainComposition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
        let cameraVideoTrack = mainComposition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
        let soundtrackTrack = mainComposition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
        
        
        let appVideoAssetTrack = appVideo.tracks(withMediaType: .video)[0]
        let cameraVideoAssetTrack = cameraVideo.tracks(withMediaType: .video)[0]
        let appSoundAssetTrack = appVideo.tracks(withMediaType: .audio)[0]
        
        do {
            try appVideoTrack?.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: appVideo.duration), of: appVideoAssetTrack, at: CMTime.zero)
            try cameraVideoTrack?.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: cameraVideo.duration), of: cameraVideoAssetTrack, at: CMTime.zero)
            try soundtrackTrack?.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: appVideo.duration), of: appSoundAssetTrack, at: CMTime.zero)
        } catch {
            print("Couldn't add tracks")
        }
        
        let duration = appVideo.duration
        
        
        let mainInstruction = AVMutableVideoCompositionInstruction()
        mainInstruction.timeRange = CMTimeRangeMake(start: CMTime.zero, duration: duration)
        
        
        let instructOne = AVMutableVideoCompositionLayerInstruction(assetTrack: appVideoAssetTrack)
        let instructOneScale = CGAffineTransform.init(scaleX: 0.4, y:0.4)
        let instructOneMove = CGAffineTransform.init(translationX: 0, y: 0)
        instructOne.setTransform(instructOneScale.concatenating(instructOneMove), at: CMTime.zero)
        
        let instructTwo = AVMutableVideoCompositionLayerInstruction(assetTrack: cameraVideoAssetTrack)
        let instructTwoScale = CGAffineTransform.init(scaleX:1, y:1)
        let instructTwoMove = CGAffineTransform.init(translationX: 300, y: 0)
        instructTwo.setTransform(instructTwoScale.concatenating(instructTwoMove), at: CMTime.zero)
        
        
        mainInstruction.layerInstructions = [instructTwo, instructOne]
        
        
        
        //        let imglogo = UIImage(named: "frame")
        
        let watermarkLayer = CALayer()
        //        watermarkLayer.contents = imglogo?.cgImage
        watermarkLayer.backgroundColor = UIColor.brown.cgColor
        watermarkLayer.anchorPoint = CGPoint(x: 0, y: 0)
        watermarkLayer.position = CGPoint(x: 0, y: 0)
        watermarkLayer.frame = CGRect(x: 0, y: 0, width: 1920, height: 1080)
        //        watermarkLayer.opacity = 1
        //        watermarkLayer.masksToBounds = true
        
        let parentLayer = CALayer()
        parentLayer.frame = CGRect(x: 0, y: 0, width: 1920, height: 1080)
        parentLayer.anchorPoint = CGPoint(x: 0, y: 0)
        parentLayer.position = CGPoint(x: 0, y: 0)
        
        parentLayer.addSublayer(watermarkLayer)
        
        let animTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: watermarkLayer, in: parentLayer)
        
        let videoComp = AVMutableVideoComposition(propertiesOf: cameraVideo)
        videoComp.animationTool = animTool
        videoComp.instructions = [mainInstruction]
        videoComp.frameDuration = CMTimeMake(value: 1, timescale: 30)
        videoComp.renderSize = CGSize.init(width: 1920, height: 1080)
        
        
        
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
        let outputURL = URL(fileURLWithPath: documentsPath.appendingPathComponent("ShareVideo.mp4"))
        print(outputURL)
        do { try FileManager.default.removeItem(at: outputURL) } catch {}
        
        let exportSession = AVAssetExportSession(asset: mainComposition,
                                                 presetName: AVAssetExportPresetHighestQuality)
        exportSession?.videoComposition = videoComp
        exportSession?.outputFileType = .mp4
        exportSession?.shouldOptimizeForNetworkUse = false
        exportSession?.outputURL = outputURL
        exportSession?.exportAsynchronously {
            
            if let error = exportSession?.error {
                handler(nil, error)
            } else {
                handler(exportSession?.outputURL, nil)
            }
        }
        
    }
}
