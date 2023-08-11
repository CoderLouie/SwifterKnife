//
//  VideoEditor.swift
//  SwifterKnife_Example
//
//  Created by 李阳 on 2023/8/11.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import Foundation
import AVFoundation

enum VideoEditor {
    
    @discardableResult
    static func addOverlay(_ overlay: (CGRect) -> [CALayer],
                           to sourcePath: String,
                           exportAt outputPath: String,
                           outputFileType: AVFileType = .mp4,
                           presetName: String = AVAssetExportPreset1280x720,
                           completion: @escaping (Error?) -> Void) -> Bool {
        addOverlay(overlay, to: sourcePath, presetName: presetName) { session in
            session.outputFileType = outputFileType
            session.outputURL = URL(fileURLWithPath: outputPath)
            session.shouldOptimizeForNetworkUse = true
        } completion: { error in
            completion(error)
        }

    }
    
    @discardableResult
    static func addOverlay(_ overlay: (CGRect) -> [CALayer],
                           to videoPath: String,
                           presetName: String = AVAssetExportPreset1280x720,
                           configExportSession: (AVAssetExportSession) -> Void,
                           completion: @escaping (Error?) -> Void) -> Bool {
        guard FileManager.default.fileExists(atPath: videoPath) else {
            return false
        }
        let videoUrl = URL(fileURLWithPath: videoPath)
        guard videoUrl.isFileURL else { return false }
        
        let asset = AVURLAsset(url: videoUrl)
        guard let videoTrack = asset.tracks(withMediaType: .video).first else {
            return false
        }
        let videoSize = videoTrack.naturalSize
        guard videoSize.width > 0, videoSize.height > 0 else {
            return false
        }
        
        let bounds = CGRect(origin: .zero, size: videoSize)
        let overlayLayers = overlay(bounds)
        guard !overlayLayers.isEmpty else {
            return false
        }
        
        let composition = AVMutableComposition()
        let videoComposition = AVMutableVideoComposition().then {
            $0.frameDuration = CMTime(value: 1, timescale: 30)
            $0.renderSize = videoSize
        }
        let videoCompositionTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
        let assetTimeRange = CMTimeRange(start: .zero, duration: asset.duration)
        try? videoCompositionTrack?.insertTimeRange(assetTimeRange, of: videoTrack, at: .zero)
        
        let audioTrack = asset.tracks(withMediaType: .audio).first
        let audioCompositionTrack: AVMutableCompositionTrack?
        if let audioTrack = audioTrack {
            audioCompositionTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
            try? audioCompositionTrack?.insertTimeRange(assetTimeRange, of: audioTrack, at: .zero)
        } else {
            audioCompositionTrack = nil
        }
        
        let videoLayer = CALayer().then {
            $0.frame = bounds
        }
        let parentLayer = CALayer().then {
            $0.frame = bounds
            $0.addSublayer(videoLayer)
            for l in overlayLayers {
                $0.addSublayer(l)
            }
        }
        if videoComposition.instructions.isEmpty {
            let instruction = AVMutableVideoCompositionInstruction()
            instruction.timeRange = CMTimeRange(start: .zero, duration: composition.duration)
            if let assetTrack = videoCompositionTrack {
                let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: assetTrack)
                instruction.layerInstructions = [layerInstruction]
                videoComposition.instructions = [instruction]
            }
        }
        videoComposition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, in: parentLayer)
        guard let compositionAsset = composition.copy() as? AVAsset else {
            return false
        }
        guard let session = AVAssetExportSession(asset: compositionAsset, presetName: presetName) else {
            return false
        }
        session.videoComposition = videoComposition
        configExportSession(session)
        guard let exportURL = session.outputURL,
                let _ = session.outputFileType else {
            return false
        }
        
        let mgr = FileManager.default
        if mgr.fileExists(atPath: exportURL.path) {
            try? mgr.removeItem(at: exportURL)
        } else {
            try? mgr.createDirectory(at: exportURL.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
        }
        session.exportAsynchronously {
            DispatchQueue.main.async {
                completion(session.error)
            }
        }
        return true
    }
}
