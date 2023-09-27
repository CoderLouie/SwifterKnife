//
//  YiVideoEditor.swift
//  YiVideoEditor
//
//  Created by coderyi on 2021/10/4.
//

import Foundation
import AVFoundation

public enum YiVideoEditorRotateDegree: Int {
    case rotateDegree90 = 0
    case rotateDegree180 = 1
    case rotateDegree270 = 2
}

protocol YiVideoEditorCommandProtocol: AnyObject {
    func execute()
}

final class YiVideoEditor {
    var videoData: YiVideoEditorData
    var commands: [YiVideoEditorCommandProtocol]
    private var _addLayerCmd: YiAddLayerCommand? = nil
    private var addLayerCmd: YiAddLayerCommand {
        _addLayerCmd ?<< .init(videoData: videoData)
    }
    public init(videoURL: URL) {
        let asset = AVURLAsset(url: videoURL)
        self.videoData = YiVideoEditorData(asset: asset)
        self.commands = []
    }
    
    public func rotate(rotateDegree: YiVideoEditorRotateDegree) -> Void {
        var commandCount = 0
        switch rotateDegree {
        case .rotateDegree90:
            commandCount = 1
        case .rotateDegree180:
            commandCount = 2
        case .rotateDegree270:
            commandCount = 3
        }
        for _ in 0..<commandCount {
            let command = YiRotateCommand(videoData: videoData)
            commands.append(command)
        }
    }
    
    public func crop(cropFrame: CGRect) {
        let command = YiCropCommand(videoData: videoData, cropFrame: cropFrame)
        commands.append(command)
    }
    
    public func addOverlay(_ layer: @escaping (CGRect) -> CALayer) {
        addLayerCmd.appendOverlay(layer)
    }

    public func addAudio(asset: AVAsset, startingAt: CGFloat, trackDuration: CGFloat) {
        let command = YiAddAudioCommand(videoData: videoData, audioAsset: asset, startingAt: startingAt, trackDuration: trackDuration)
        commands.append(command)
    }
    
    public func addAudio(asset: AVAsset, startingAt: CGFloat) {
        let command = YiAddAudioCommand(videoData: videoData, audioAsset: asset, startingAt: startingAt, trackDuration: nil)
        commands.append(command)
    }

    public func addAudio(asset: AVAsset) {
        let command = YiAddAudioCommand(videoData: videoData, audioAsset: asset, startingAt: nil, trackDuration: nil)
        commands.append(command)
    }

    func applyCommands() {
        for item in commands {
            item.execute()
        }
        _addLayerCmd?.execute()
    }
    
    @discardableResult
    public func export(at exportURL: URL, completion: @escaping (AVAssetExportSession) -> Void) -> Bool {
        export(at: exportURL, presetName: AVAssetExportPreset1280x720, optimizeForNetworkUse: true, outputFileType: AVFileType.mp4, completion: completion)
    }
    
    @discardableResult
    public func export(at exportURL: URL, presetName: String, optimizeForNetworkUse: Bool, outputFileType: AVFileType, completion: @escaping (AVAssetExportSession) -> Void) -> Bool {
        applyCommands()
        guard let videoDataComposition = videoData.composition?.copy() as? AVAsset,
              let exportSession = AVAssetExportSession(asset: videoDataComposition, presetName: presetName) else {
            return false
        }
        
        if let videoComposition = videoData.videoComposition {
            exportSession.videoComposition = videoComposition
        }
        let mgr = FileManager.default
        if mgr.fileExists(atPath: exportURL.path) {
            try? mgr.removeItem(at: exportURL)
        } else {
            try? mgr.createDirectory(at: exportURL.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
        }
        
        exportSession.outputFileType = outputFileType
        exportSession.outputURL = exportURL
        exportSession.shouldOptimizeForNetworkUse = optimizeForNetworkUse
        exportSession.exportAsynchronously {
            DispatchQueue.main.async {
                let asset = AVURLAsset(url: exportURL)
                self.videoData = YiVideoEditorData(asset: asset)
                self._addLayerCmd = nil
                self.commands = []
                completion(exportSession)
            }
        }
        return true
    }
}
