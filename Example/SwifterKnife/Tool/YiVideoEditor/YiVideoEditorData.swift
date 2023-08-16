//
//  YiVideoEditorData.swift
//  YiVideoEditor
//
//  Created by coderyi on 2021/10/4.
//

import Foundation
import AVFoundation

final class YiVideoEditorData {
    var asset: AVAsset
    var composition: AVMutableComposition?
    var assetVideoTrack: AVAssetTrack?
    var assetAudioTrack: AVAssetTrack?
    var videoComposition: AVMutableVideoComposition?
    var videoCompositionTrack: AVMutableCompositionTrack?
    var audioCompositionTrack: AVMutableCompositionTrack?
    var videoSize: CGSize = .zero
    init(asset: AVAsset) {
        self.asset = asset
        self.loadAsset(asset: asset)
    }
    
    func loadAsset(asset: AVAsset) -> Void {
        assetVideoTrack = asset.tracks(withMediaType: .video).first
        assetAudioTrack = asset.tracks(withMediaType: .audio).first
        videoSize = assetVideoTrack?.naturalSize ?? .zero
        
        let composition = AVMutableComposition()
        self.composition = composition
        
        let videoComposition = AVMutableVideoComposition().then {
            $0.frameDuration = CMTime(value: 1, timescale: 30)
            $0.renderSize = videoSize
        }
        self.videoComposition = videoComposition
        
        let insertionPoint: CMTime = .zero
        if let assetVideoTrack = assetVideoTrack {
            videoCompositionTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
            try? videoCompositionTrack?.insertTimeRange(CMTimeRange(start: .zero, duration: asset.duration), of: assetVideoTrack, at: insertionPoint)
        }
        if let assetAudioTrack = assetAudioTrack {
            audioCompositionTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
            try? audioCompositionTrack?.insertTimeRange(CMTimeRange(start: .zero, duration: asset.duration), of: assetAudioTrack, at: insertionPoint)
        }

    }
}
