//
//  YiAddLayerCommand.swift
//  YiVideoEditor
//
//  Created by coderyi on 2021/10/4.
//

import Foundation
import AVFoundation

final class YiAddLayerCommand: YiVideoEditorCommandProtocol {
    weak var videoData: YiVideoEditorData?
    var layers: [(CGRect) -> CALayer] = []
    init(videoData: YiVideoEditorData) {
        self.videoData = videoData
    }
    func appendOverlay(_ layer: @escaping (CGRect) -> CALayer) {
        layers.append(layer)
    }
    func execute() {
        guard let videoData = videoData else {
            return
        }
        let videoSize = videoData.videoSize
        let parentLayer = CALayer()
        let videoLayer = CALayer()
        let bounds = CGRect(origin: .zero, size: videoSize)
        parentLayer.frame = bounds
        videoLayer.frame = bounds
        parentLayer.addSublayer(videoLayer)
        for l in layers {
            parentLayer.addSublayer(l(bounds))
        } 
        
        let duration = videoData.composition?.duration
        if videoData.videoComposition?.instructions.count == 0 {
            let instruction = AVMutableVideoCompositionInstruction()
            instruction.timeRange = CMTimeRange(start: .zero, duration: duration ?? .zero)
            if let videoCompositionTrack = videoData.videoCompositionTrack {
                let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoCompositionTrack)
                instruction.layerInstructions = [layerInstruction]
                videoData.videoComposition?.instructions = [instruction]
            }
        }
        videoData.videoComposition?.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, in: parentLayer)
    }

}
