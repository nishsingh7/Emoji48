//
//  RPScreenWriter.swift
//  ScreenRecord
//
//  Created by Ben Allen on 21/09/2019.
//  Copyright © 2019 Ben Allen. All rights reserved.
//

import Foundation
import AVFoundation
import ReplayKit

class AppRecorder {
    private var videoOutputURL: URL
    private var videoWriter: AVAssetWriter?
    private var videoInput: AVAssetWriterInput?
    
    private var audioOutputURL: URL
    private var audioWriter: AVAssetWriter?
    private var micAudioInput: AVAssetWriterInput?
    private var appAudioInput: AVAssetWriterInput?
    
    init() {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
        self.videoOutputURL = URL(fileURLWithPath: documentsPath.appendingPathComponent("AppRecorderVideo.mp4"))
        self.audioOutputURL = URL(fileURLWithPath: documentsPath.appendingPathComponent("AppRecorderAudio.mp4"))
        reset()
    }
    
    public func start() {
        print("Start App Recorder")
        RPScreenRecorder.shared().startCapture(handler: { cmSampleBuffer, rpSampleBufferType, error in
            self.appendBuffer(cmSampleBuffer, rpSampleType: rpSampleBufferType)
            
        }) { error in
            if let errorEsc = error {
                print(errorEsc)
            }
        }
    }
    
    public func stop(completionHandler handler: @escaping (URL?) -> Void) {
        self.finishWriting(completionHandler: { url, error in
            handler(url)
        })
        
        RPScreenRecorder.shared().stopRecording { (preview, error) in
            
        }
    }
    
    private func reset() {
        do {
            try FileManager.default.removeItem(at: self.videoOutputURL)
            try FileManager.default.removeItem(at: self.audioOutputURL)
        } catch {}
    }
    
    private func setup() {
        do {
            try videoWriter = AVAssetWriter(outputURL: self.videoOutputURL, fileType: .mp4)
        } catch let writerError as NSError {
            print("Error opening video file \(writerError)")
        }
        
        let videoSettings = [
            AVVideoCodecKey : AVVideoCodecType.h264,
            AVVideoScalingModeKey : AVVideoScalingModeResizeAspect,
            AVVideoWidthKey  : 1920,
            AVVideoHeightKey : 1080,
        
            ] as [String : Any]
        
        videoInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
        videoInput?.transform.translatedBy(x: 300, y: 400)
        
        if let videoInput = self.videoInput,
            let canAddInput = videoWriter?.canAdd(videoInput),
            canAddInput {
            videoWriter?.add(videoInput)
        } else {
            print("Couldn't add video input")
        }
        
        do {
            try audioWriter = AVAssetWriter(outputURL: self.audioOutputURL, fileType: .mp4)
        } catch let writerError as NSError {
            print("Error opening video file \(writerError)")
        }
        
        var channelLayout = AudioChannelLayout()
        channelLayout.mChannelLayoutTag = kAudioChannelLayoutTag_MPEG_5_1_D
        let audioOutputSettings = [
            AVNumberOfChannelsKey : 6,
            AVFormatIDKey : kAudioFormatMPEG4AAC_HE,
            AVSampleRateKey : 44100,
            AVChannelLayoutKey : NSData(bytes: &channelLayout, length: MemoryLayout.size(ofValue: channelLayout))
            ] as [String : Any]
        
        appAudioInput = AVAssetWriterInput(mediaType: .audio, outputSettings: audioOutputSettings)
        if let appAudioInput = self.appAudioInput,
            let canAddInput = audioWriter?.canAdd(appAudioInput),
            canAddInput {
            audioWriter?.add(appAudioInput)
        } else {
            print("Couldn't add app audio input")
        }
        micAudioInput = AVAssetWriterInput(mediaType: .audio, outputSettings: audioOutputSettings)
        if let micAudioInput = self.micAudioInput,
            let canAddInput = audioWriter?.canAdd(micAudioInput),
            canAddInput {
            audioWriter?.add(micAudioInput)
        } else {
            print("Couldn't add mic audio input")
        }
    }
    
    private func appendBuffer(_ cmSampleBuffer: CMSampleBuffer, rpSampleType: RPSampleBufferType) {
        if self.videoWriter == nil {
            self.setup()
        }
        guard let videoWriter = self.videoWriter,
            let audioWriter = self.audioWriter else {
                return
        }
        let presentationTimeStamp = CMSampleBufferGetPresentationTimeStamp(cmSampleBuffer)
        switch rpSampleType {
        case .video:
            if videoWriter.status == .unknown {
                if videoWriter.startWriting() {
                    print("Video writing started")
                    videoWriter.startSession(atSourceTime: presentationTimeStamp)
                }
            } else if videoWriter.status == .writing {
                if let isReadyForMoreMediaData = videoInput?.isReadyForMoreMediaData,
                    isReadyForMoreMediaData {
                    if let appendInput = videoInput?.append(cmSampleBuffer),
                        !appendInput {
                        print("Couldn't write video buffer")
                        print(cmSampleBuffer)
                    }
                }
            }
            break
        case .audioApp:
            if audioWriter.status == .unknown {
                if audioWriter.startWriting() {
                    print("Audio writing started")
                    audioWriter.startSession(atSourceTime: presentationTimeStamp)
                }
            } else if audioWriter.status == .writing {
                if let isReadyForMoreMediaData = appAudioInput?.isReadyForMoreMediaData,
                    isReadyForMoreMediaData {
                    if let appendInput = appAudioInput?.append(cmSampleBuffer),
                        !appendInput {
                        print("Couldn't write app audio buffer")
                    }
                }
            }
            break
        case .audioMic:
            if audioWriter.status == .unknown {
                if audioWriter.startWriting() {
                    print("Audio writing started")
                    audioWriter.startSession(atSourceTime: presentationTimeStamp)
                }
            } else if audioWriter.status == .writing {
                if let isReadyForMoreMediaData = micAudioInput?.isReadyForMoreMediaData,
                    isReadyForMoreMediaData {
                    if let appendInput = micAudioInput?.append(cmSampleBuffer),
                        !appendInput {
                        print("Couldn't write mic audio buffer")
                    }
                }
            }
            break
        default:
            print("Unknown type")
        }
    }
    
    private func finishWriting(completionHandler handler: @escaping (URL?, Error?) -> Void) {
        self.videoInput?.markAsFinished()
        self.videoWriter?.finishWriting {
            completion()
        }
        
        self.appAudioInput?.markAsFinished()
        self.micAudioInput?.markAsFinished()
        self.audioWriter?.finishWriting {
            completion()
        }
        
        func completion() {
            self.videoInput = nil
            self.videoWriter = nil
            self.appAudioInput = nil
            self.micAudioInput = nil
            self.audioWriter = nil
            merge()
        }
        
        func merge() {
            let mergeComposition = AVMutableComposition()
            
            let videoAsset = AVAsset(url: self.videoOutputURL)
            let videoTracks = videoAsset.tracks(withMediaType: .video)
            let videoCompositionTrack = mergeComposition.addMutableTrack(withMediaType: .video,
                                                                         preferredTrackID: kCMPersistentTrackID_Invalid)
            
            guard let firstTrack = videoTracks.first else {
                print("No first track?")
                return
            }
            do {
                try videoCompositionTrack?.insertTimeRange(CMTimeRange(start: CMTime.zero, end: videoAsset.duration),
                                                           of: firstTrack,
                                                           at: CMTime.zero)
            } catch let error {
                reset()
                handler(nil, error)
            }
            videoCompositionTrack?.preferredTransform = videoTracks.first!.preferredTransform
            
            let audioAsset = AVAsset(url: self.audioOutputURL)
            let audioTracks = audioAsset.tracks(withMediaType: .audio)
            for audioTrack in audioTracks {
                let audioCompositionTrack = mergeComposition.addMutableTrack(withMediaType: .audio,
                                                                             preferredTrackID: kCMPersistentTrackID_Invalid)
                do {
                    try audioCompositionTrack?.insertTimeRange(CMTimeRange(start: CMTime.zero, end: audioAsset.duration),
                                                               of: audioTrack,
                                                               at: CMTime.zero)
                } catch let error {
                    print(error)
                }
            }
            let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
            let outputURL = URL(fileURLWithPath: documentsPath.appendingPathComponent("RPScreenWriterMergeVideo3.mp4"))
            do { try FileManager.default.removeItem(at: outputURL)  } catch {}
            
            let exportSession = AVAssetExportSession(asset: mergeComposition,
                                                     presetName: AVAssetExportPresetHighestQuality)
            exportSession?.outputFileType = .mp4
            exportSession?.shouldOptimizeForNetworkUse = true
            exportSession?.outputURL = outputURL
            exportSession?.exportAsynchronously {
                if let error = exportSession?.error {
                    self.reset()
                    handler(nil, error)
                } else {
                    self.reset()
                    handler(exportSession?.outputURL, nil)
                }
            }
        }
    }
}
