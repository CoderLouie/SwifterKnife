//
//  PhotoManager.swift
//  SwifterKnife_Example
//
//  Created by 李阳 on 2023/8/10.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import Photos


enum PhotoManager {
    
    @discardableResult
    static func createAlbum(named name: String) -> PHAssetCollection? {
        // 获取所有的相册
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", name)
        let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: fetchOptions)
        
        // 如果相册已存在，直接获取该相册
        if let first = collection.firstObject {
            return first
        }
        
        // 创建新的相册
        do {
            var collectionId: String?
            try PHPhotoLibrary.shared().performChangesAndWait {
                collectionId = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: name).placeholderForCreatedAssetCollection.localIdentifier
            }
            guard let id = collectionId else { return nil }
            return PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [id], options: nil).firstObject
        } catch {
            return nil
        }
    }
     
    
    static func saveImage(image : UIImage?, toAlbumNamed albumName: String, completion: ((Bool) -> Void)? = nil) {
        guard let img = image else {
            completion?(false)
            return
        }
        let status = PHPhotoLibrary.authorizationStatus()
        
        if status == .denied || status == .restricted {
            completion?(false)
            return
        }
        
        let wrapClosure = { (success: Bool) -> Void in
            DispatchQueue.main.async {
                completion?(success)
            }
        }
        var assetLocalId: String?
        PHPhotoLibrary.shared().performChanges {
            assetLocalId = PHAssetChangeRequest.creationRequestForAsset(from: img).placeholderForCreatedAsset?.localIdentifier
        } completionHandler: { success, error in
            guard success, error == nil, let id = assetLocalId else {
                wrapClosure(false)
                return
            }
            guard let collection = createAlbum(named: albumName) else {
                wrapClosure(false)
                return
            }
            PHPhotoLibrary.shared().performChanges {
                let assets = PHAsset.fetchAssets(withLocalIdentifiers: [id], options: nil)
                let request = PHAssetCollectionChangeRequest(for: collection)
                request?.addAssets(assets)
            } completionHandler: { success, error in
                wrapClosure(success)
            }
        }
    }
    
    
    static func saveImage(_ image : UIImage?, completion: ( (Bool) -> Void )?){
        guard let img = image else {
            completion?(false)
            return
        }
        let status = PHPhotoLibrary.authorizationStatus()
        if status == .denied || status == .restricted {
            completion?(false)
            return
        }
        PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.creationRequestForAsset(from: img)
        } completionHandler: { success, error in
            DispatchQueue.main.async {
                completion?(success)
            }
        }
    }
    
    /// Save video to album.
    static func saveVideoToAlbum(url: URL, completion: @escaping (_ success: Bool) -> Void) {
        let status = PHPhotoLibrary.authorizationStatus()
        if status == .denied || status == .restricted {
            completion(false)
            return
        }
        PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
        } completionHandler: { success, error in
            DispatchQueue.main.async {
                completion(success)
            }
        }
    }
}
