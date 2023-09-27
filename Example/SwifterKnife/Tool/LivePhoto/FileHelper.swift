//
//  FileHelper.swift
//  WLPhotoPicker
//
//  Created by Mr.Wang on 2021/12/23.
//

import UIKit
import CommonCrypto

fileprivate extension String {
    var md5:String {
        let utf8 = cString(using: .utf8)
        var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        CC_MD5(utf8, CC_LONG(utf8!.count - 1), &digest)
        return digest.reduce("") { $0 + String(format:"%02x", $1) }
    }
}

enum FileHelper {
    
    static var temporaryPath: String {
        return NSTemporaryDirectory() + "WLPhotoPicker/"
    }
    
    static var dateString: String {
        String(Date().timeIntervalSince1970)
    }
    
    static func createSubDirectory(_ name: String) -> String {
        let directoryPath = temporaryPath + name + "/"
        if !FileManager.default.fileExists(atPath: directoryPath) {
            try? FileManager.default.createDirectory(at: URL(fileURLWithPath: directoryPath),
                                                     withIntermediateDirectories: true,
                                                     attributes: nil)
        }
        return directoryPath
    }
    
}
 

// MARK: LivePhoto
extension FileHelper {
    static func clearLivePhotoCache() {
        let manager = FileManager.default
        let directoryPath = temporaryPath + "LivePhoto" + "/"
        if manager.fileExists(atPath: directoryPath) {
            try? manager.removeItem(atPath: directoryPath)
        }
    }
    static func createLivePhotoPhotoPath() -> String {
        let directoryPath = createSubDirectory("LivePhoto")
        return directoryPath + dateString.md5 + ".jpg"
    }
    
    static func createLivePhotoVideoPath() -> String {
        let directoryPath = createSubDirectory("LivePhoto")
        return directoryPath + dateString.md5 + ".mov"
    }
    
}
 
