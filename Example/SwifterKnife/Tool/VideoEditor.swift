//
//  VideoEditor.swift
//  SwifterKnife
//
//  Created by liyang on 2023/8/11.
//

import Foundation
import AVFoundation

/*
 https://github.com/evekeen/watermark/blob/main/Shared/Composer.swift
 https://github.com/coderyi/YiVideoEditor
 */

enum VideoEditor {
    
    @discardableResult
    static func addOverlay(_ layer: CALayer,
                           to sourcePath: String,
                           exportAt outputPath: String,
                           outputFileType: AVFileType = .mp4,
                           presetName: String = AVAssetExportPreset1280x720,
                           completion: @escaping (Error?) -> Void) -> Bool {
        addOverlay({ _ in
            return [layer]
        }, to: sourcePath, exportAt: outputPath, outputFileType: outputFileType, presetName: presetName, completion: completion)
    }
    
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
        
        let asset = AVURLAsset(url: videoUrl, options: [AVURLAssetPreferPreciseDurationAndTimingKey: true])
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
        guard let videoCompositionTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid) else {
            print("[AddOverlay] cannot create track")
            return false
        }
        let assetTimeRange = CMTimeRange(start: .zero, duration: asset.duration)
        do {
            try videoCompositionTrack.insertTimeRange(assetTimeRange, of: videoTrack, at: .zero)
        } catch {
            print("[AddOverlay] insertTimeRange Error", error)
            return false
        }
        videoCompositionTrack.preferredTransform = videoTrack.preferredTransform
        
        // Add audio track
        if
            let audioTrack = asset.tracks(withMediaType: .audio).first,
            let compositionAudioTrack = composition.addMutableTrack(
                withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid
            ) {
            try? compositionAudioTrack.insertTimeRange(assetTimeRange, of: audioTrack, at: .zero)
        }
        
        let videoLayer = CALayer().then {
            $0.frame = bounds
        }
        let parentLayer = CALayer().then {
            $0.isGeometryFlipped = true
            $0.frame = bounds
            $0.addSublayer(videoLayer)
            for l in overlayLayers {
                $0.addSublayer(l)
            }
        }
        
        let videoComposition = AVMutableVideoComposition().then {
            $0.frameDuration = CMTime(value: 1, timescale: 30)
            $0.renderSize = videoSize
        }
        videoComposition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, in: parentLayer)
        
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRange(start: .zero, duration: composition.duration)
        instruction.enablePostProcessing = true
        let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoCompositionTrack).then {
            $0.setTransform(.identity, at: .zero)
        }
        instruction.layerInstructions = [layerInstruction]
        videoComposition.instructions = [instruction]
        
        guard let session = AVAssetExportSession(asset: composition, presetName: presetName) else {
            print("[AddOverlay] cannot export session")
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
