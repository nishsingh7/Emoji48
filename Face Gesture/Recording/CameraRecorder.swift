//
//  CameraRecorder.swift
//  ScreenRecord
//
//  Created by Ben Allen on 21/09/2019.
//  Copyright © 2019 Ben Allen. All rights reserved.
//

import Foundation
import AVFoundation

class CameraRecorder {
    private var videoOutputURL: URL
    private var videoWriter: AVAssetWriter?
    private var videoInput: AVAssetWriterInput?
    
    var isRecording = false
    
    
    init() {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
        self.videoOutputURL = URL(fileURLWithPath: documentsPath.appendingPathComponent("RawCameraRecorder.mp4"))
        reset()
    }
    
    public func start() {
        print("Start Camera Recorder")
        self.setup()
        self.isRecording = true
    }
    
    public func stop(completionHandler handler: @escaping (URL?) -> Void) {
        print("Stop Camera Recorder")
        self.isRecording = false
        self.finishWriting(completionHandler: { url, error in
            handler(url)
            if let url = url {
                print("Finished Camera Recorder Render")
                print("\(url)")
            }
        })
    }
    
    private func reset() {
        do {
            try FileManager.default.removeItem(at: self.videoOutputURL)
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
            AVVideoWidthKey  : 1080,
            AVVideoHeightKey : 1920,
            
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
        
    }
    
    func appendBuffer(_ cmPixelBuffer: CVPixelBuffer, atTime time: TimeInterval) {
    
        guard let videoWriter = self.videoWriter else {
            return
        }
        
        
        guard let cmSampleBuffer = cmPixelBuffer.toSampleBuffer(time: time) else {
            print("Fucked")
            return
        }
    
        let presentationTimeStamp = CMSampleBufferGetPresentationTimeStamp(cmSampleBuffer)

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
                }
            }
        }
    }
    
    private func finishWriting(completionHandler handler: @escaping (URL?, Error?) -> Void) {
        self.videoInput?.markAsFinished()
        print("Finish writing?")
        self.videoWriter?.finishWriting {
            print("Finished writing")
            self.videoInput = nil
            self.videoWriter = nil
            merge()
        }
        
        func merge() {
            print("Merg")
            let mergeComposition = AVMutableComposition()
            
            let videoAsset = AVAsset(url: self.videoOutputURL)
            let videoTracks = videoAsset.tracks(withMediaType: .video)
            let videoCompositionTrack = mergeComposition.addMutableTrack(withMediaType: .video,
                                                                         preferredTrackID: kCMPersistentTrackID_Invalid)
            do {
                try videoCompositionTrack?.insertTimeRange(CMTimeRange(start: CMTime.zero, end: videoAsset.duration),
                                                           of: videoTracks.first!,
                                                           at: CMTime.zero)
            } catch let error {
                print(error)
                reset()
                handler(nil, error)
            }
            videoCompositionTrack?.preferredTransform = videoTracks.first!.preferredTransform
            
            
            let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
            let outputURL = URL(fileURLWithPath: documentsPath.appendingPathComponent("MrgCamera.mp4"))
            do { try FileManager.default.removeItem(at: outputURL) } catch {}
        
            let exportSession = AVAssetExportSession(asset: mergeComposition,
                                                     presetName: AVAssetExportPresetHighestQuality)
            exportSession?.outputFileType = .mp4
            exportSession?.shouldOptimizeForNetworkUse = true
            exportSession?.outputURL = outputURL
            exportSession?.exportAsynchronously {
                if let error = exportSession?.error {
                    self.reset()
                    print(error)
                    handler(nil, error)
                } else {
                    self.reset()
                    handler(exportSession?.outputURL, nil)
                }
            }
        }
        
    }
}

extension CVPixelBuffer {
    func toSampleBuffer(time: TimeInterval) -> CMSampleBuffer? {
        var newSampleBuffer: CMSampleBuffer? = nil
        let scale = CMTimeScale(NSEC_PER_SEC)
        let pts = CMTime(value: CMTimeValue(time * Double(scale)),
                         timescale: scale)
        var timingInfo = CMSampleTimingInfo(duration: CMTime.invalid,
                                            presentationTimeStamp: pts,
                                            decodeTimeStamp: CMTime.invalid)
        var videoInfo: CMVideoFormatDescription? = nil
        CMVideoFormatDescriptionCreateForImageBuffer(allocator: kCFAllocatorDefault, imageBuffer: self, formatDescriptionOut: &videoInfo)
        CMSampleBufferCreateForImageBuffer(allocator: kCFAllocatorDefault, imageBuffer: self, dataReady: true, makeDataReadyCallback: nil, refcon: nil, formatDescription: videoInfo!, sampleTiming: &timingInfo, sampleBufferOut: &newSampleBuffer)
        return newSampleBuffer
    }
}
