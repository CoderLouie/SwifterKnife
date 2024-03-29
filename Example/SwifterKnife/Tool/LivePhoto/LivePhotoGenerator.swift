//
//  LivePhotoGenerator.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2022/4/11.
//

import UIKit
import AVFoundation
import MobileCoreServices
import Photos


fileprivate extension AVAsset {
    
    func thumbnailImage() -> UIImage? {
        let generator = AVAssetImageGenerator(asset: self)
        generator.appliesPreferredTrackTransform = true
        generator.requestedTimeToleranceAfter = .zero
        generator.requestedTimeToleranceBefore = .zero
        let time = CMTime(seconds: 0, preferredTimescale: 1000)
        if let image = try? generator.copyCGImage(at: time, actualTime: nil) {
            return UIImage(cgImage: image)
        }
        return nil
    }
}

public struct LivePhotoGeneratorRsult {
    public var livePhoto: PHLivePhoto
    public var imageURL: URL
    public var videoURL: URL
}

public typealias LivePhotoGeneratorCompletion = (LivePhotoGeneratorRsult?) -> Void
public typealias LivePhotoGeneratorProgress = (Double) -> Void

// 通过视频生成实况照片
public enum LivePhotoGenerator {
    
    static public func createAndSave(_ videoPath: String, completion: @escaping (Bool) -> Void) {
        createLivePhotoFrom(URL(fileURLWithPath: videoPath)) { result in
            guard let result = result else {
                completion(false)
                return
            }
            PHPhotoLibrary.shared().performChanges { 
                let creationRequest = PHAssetCreationRequest.forAsset()
                let options = PHAssetResourceCreationOptions()
                
                creationRequest.addResource(with: PHAssetResourceType.pairedVideo, fileURL: result.videoURL, options: options)
                creationRequest.addResource(with: PHAssetResourceType.photo, fileURL: result.imageURL, options: options)
            } completionHandler: { success, error -> Void in
                completion(success)
            }
        }
    }
    
    static public func createLivePhotoFrom(_ videoURL: URL, isMute: Bool = false, placeholder: UIImage? = nil, progress: LivePhotoGeneratorProgress? = nil, completion: @escaping LivePhotoGeneratorCompletion) {
        
        FileHelper.clearLivePhotoCache()
        
        let placeholderImage: UIImage
        if let placeholder = placeholder {
            placeholderImage = placeholder
        } else {
            let videoAsset = AVAsset(url: videoURL)
            guard let videoThumbImage = videoAsset.thumbnailImage() else {
                completion(nil)
                return
            }
            placeholderImage = videoThumbImage
        }
        
        
        let assetIdentifier = UUID().uuidString
        
        guard let imageURL = createImageURL(placeholderImage, assetIdentifier: assetIdentifier) else {
            completion(nil)
            return
        }
        
        let videoAsset = AVAsset(url: videoURL)
        
        createVideoURL(videoAsset, isMute: isMute, assetIdentifier: assetIdentifier, progress: progress, completion: { videoURL in
            guard let videoURL = videoURL else {
                completion(nil)
                return
            }
            PHLivePhoto.request(withResourceFileURLs: [imageURL, videoURL],
                                placeholderImage: placeholderImage,
                                targetSize: placeholderImage.size,
                                contentMode: .aspectFill) { livePhoto, info in
                guard let livePhoto = livePhoto else {
                    completion(nil)
                    return
                }
                let isDegraded = info[PHLivePhotoInfoIsDegradedKey] as? Bool ?? false
                if !isDegraded {
                    completion(LivePhotoGeneratorRsult(livePhoto: livePhoto, imageURL: imageURL, videoURL: videoURL))
                }
            }
        })
    }
    
    // MARK: Image
    static private func createImageURL(_ image: UIImage, assetIdentifier: String) -> URL? {
        let imagePath = FileHelper.createLivePhotoPhotoPath()
        let imageURL = URL.init(fileURLWithPath: imagePath)
        
        guard let cgImage = image.cgImage,
              let destination = CGImageDestinationCreateWithURL(imageURL as CFURL, kUTTypeJPEG, 1, nil) else {
            return nil
        }
        
        let imageMetadata = [kCGImagePropertyMakerAppleDictionary: ["17": assetIdentifier]] as CFDictionary
        CGImageDestinationAddImage(destination, cgImage, imageMetadata)
        CGImageDestinationFinalize(destination)
        
        return imageURL
    }
    
    // MARK: Video
    static private func createVideoURL(_ asset: AVAsset, isMute: Bool, assetIdentifier: String, progress: LivePhotoGeneratorProgress? = nil, completion: @escaping (URL?) -> Void) {
        let videoPath = FileHelper.createLivePhotoVideoPath()
        let videoURL = URL.init(fileURLWithPath: videoPath)
        
        guard let assetReader = try? AVAssetReader(asset: asset),
              let assetWriter = try? AVAssetWriter(outputURL: videoURL, fileType: .mov),
              let videoTrack = asset.tracks(withMediaType: .video).first else {
            completion(nil)
            return
        }
        
        let assetWriterMetadata = AVMutableMetadataItem()
        assetWriterMetadata.key = "com.apple.quicktime.content.identifier" as NSString
        assetWriterMetadata.keySpace = AVMetadataKeySpace.quickTimeMetadata
        assetWriterMetadata.value = assetIdentifier as (NSCopying & NSObjectProtocol)?
        assetWriterMetadata.dataType = "com.apple.metadata.datatype.UTF-8"
        assetWriter.metadata = [assetWriterMetadata]
        
        let readSetting = [kCVPixelBufferPixelFormatTypeKey: kCVPixelFormatType_32BGRA] as [String: Any]
        let readerVideoOutput = AVAssetReaderTrackOutput(track: videoTrack, outputSettings: readSetting)
        readerVideoOutput.alwaysCopiesSampleData = false
        if assetReader.canAdd(readerVideoOutput) {
            assetReader.add(readerVideoOutput)
        }
        
        let videooutputSettings: [String: Any] = [AVVideoCodecKey: AVVideoCodecType.h264,
                                                   AVVideoWidthKey: videoTrack.naturalSize.width,
                                                  AVVideoHeightKey: videoTrack.naturalSize.height]
        let assetWriterVideoInput = AVAssetWriterInput(mediaType: .video,
                                                       outputSettings: videooutputSettings)
        assetWriterVideoInput.expectsMediaDataInRealTime = true
        assetWriterVideoInput.transform = videoTrack.preferredTransform
        if assetWriter.canAdd(assetWriterVideoInput) {
            assetWriter.add(assetWriterVideoInput)
        }
        
        var readerAudioOutput: AVAssetReaderTrackOutput?
        var assetWriterAudioInput: AVAssetWriterInput?
        
        if !isMute, let audioTrack = asset.tracks(withMediaType: .audio).first {
            readerAudioOutput = AVAssetReaderTrackOutput(track: audioTrack, outputSettings: nil)
            readerAudioOutput!.alwaysCopiesSampleData = false
            if assetReader.canAdd(readerAudioOutput!) {
                assetReader.add(readerAudioOutput!)
            }
            
            assetWriterAudioInput = AVAssetWriterInput(mediaType: .audio, outputSettings: nil)
            assetWriterAudioInput!.expectsMediaDataInRealTime = true
            if assetWriter.canAdd(assetWriterAudioInput!) {
                assetWriter.add(assetWriterAudioInput!)
            }
        }
        
        let specifications = [[kCMMetadataFormatDescriptionMetadataSpecificationKey_Identifier:
                                "mdta/com.apple.quicktime.still-image-time",
                                 kCMMetadataFormatDescriptionMetadataSpecificationKey_DataType:
                                kCMMetadataBaseDataType_SInt8 as String]]  as CFArray
        
        var descriptionOut: CMFormatDescription? = nil
        CMMetadataFormatDescriptionCreateWithMetadataSpecifications(allocator: kCFAllocatorDefault,
                                                                    metadataType: kCMMetadataFormatType_Boxed,
                                                                    metadataSpecifications: specifications,
                                                                    formatDescriptionOut: &descriptionOut)
        let metadataiInput = AVAssetWriterInput(mediaType: .metadata, outputSettings: nil, sourceFormatHint: descriptionOut)
        
        let metadataAdaptor = AVAssetWriterInputMetadataAdaptor(assetWriterInput: metadataiInput)
        assetWriter.add(metadataAdaptor.assetWriterInput)
        
        assetReader.startReading()
        assetWriter.startWriting()
        assetWriter.startSession(atSourceTime: .zero)
        
        let adapterMetadata = AVMutableMetadataItem()
        adapterMetadata.key = "com.apple.quicktime.still-image-time" as NSString
        adapterMetadata.keySpace = AVMetadataKeySpace.quickTimeMetadata
        adapterMetadata.value = 0 as (NSCopying & NSObjectProtocol)?
        adapterMetadata.dataType = kCMMetadataBaseDataType_SInt8 as String
        
        let rangeStart = CMTimeMake(value: 0, timescale: 1000)
        let rangeDuration = CMTimeMake(value: 200, timescale: 3000)
        let dummyTimeRange = CMTimeRangeMake(start: rangeStart, duration: rangeDuration)
        metadataAdaptor.append(AVTimedMetadataGroup(items: [adapterMetadata], timeRange: dummyTimeRange))
        
        let dispatchGroup = DispatchGroup()
        let audioQueue = DispatchQueue(label: "com.WLPhotoPicker.DispatchQueue.LivePhotoGenerator.Audio")
        let videoQueue = DispatchQueue(label: "com.WLPhotoPicker.DispatchQueue.LivePhotoGenerator.Video")
        
        let totalSeconds = asset.duration.seconds
        
        dispatchGroup.enter()
        assetWriterVideoInput.requestMediaDataWhenReady(on: videoQueue) {
            while assetWriterVideoInput.isReadyForMoreMediaData {
                guard let sampleBuffer = readerVideoOutput.copyNextSampleBuffer() else {
                    assetWriterVideoInput.markAsFinished()
                    dispatchGroup.leave()
                    break
                }
                let timeStamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
                progress?(timeStamp.seconds / totalSeconds)
                assetWriterVideoInput.append(sampleBuffer)
            }
        }
        
        if let readerAudioOutput = readerAudioOutput,
           let assetWriterAudioInput = assetWriterAudioInput {
            dispatchGroup.enter()
            assetWriterAudioInput.requestMediaDataWhenReady(on: audioQueue) {
                while assetWriterAudioInput.isReadyForMoreMediaData {
                    guard let sampleBuffer = readerAudioOutput.copyNextSampleBuffer() else {
                        assetWriterAudioInput.markAsFinished()
                        dispatchGroup.leave()
                        break
                    }
                    assetWriterAudioInput.append(sampleBuffer)
                }
            }
        }
        
        dispatchGroup.notify(queue: DispatchQueue.main) {
            assetReader.cancelReading()
            assetWriter.finishWriting {
                completion(videoURL)
            }
        }
    }
    
}
