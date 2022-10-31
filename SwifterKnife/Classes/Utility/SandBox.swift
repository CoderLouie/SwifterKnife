//
//  SandBox.swift
//  SwifterKnife
//
//  Created by liyang on 08/24/2021.
//

import Foundation

public enum SandBox { 
    public static func enumerateContents(
        of path: String,
        progress:(_ path: String,
                  _ level: Int,
                  _ stop: inout Bool) throws -> Void) rethrows {
        
        let manager = FileManager.default
        var isDirectory: ObjCBool = false
        var stop = false
        
        func enumerateContents(of path: String, innerLevel: Int) throws {
            guard !stop else { return }
            guard manager.fileExists(atPath: path, isDirectory: &isDirectory) else {
                return
            }
            guard isDirectory.boolValue else {
                return try progress(path, innerLevel, &stop)
            }
            let contents = try manager.contentsOfDirectory(atPath: path)
            for item in contents where !item.hasPrefix(".") {
                let fullPath = (path as NSString).appendingPathComponent(item)
                try enumerateContents(of: fullPath, innerLevel: innerLevel + 1)
                if stop { break }
            }
        }
        try enumerateContents(of: path, innerLevel: 0)
    }
    
    /// 如果path不存在会抛出错误
    public static func removeItem(at path: String) throws {
        let manager = FileManager.default
        guard manager.fileExists(atPath: path) else { return }
        try manager.removeItem(atPath: path)
    }
    
    public static func fileExists(atPath path: String) -> (exists: Bool, isDirector: Bool) {
        var isDirectory: ObjCBool = false
        let exists = FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory)
        return (exists, isDirectory.boolValue)
    }
    
    /*
     如果path是文件夹：存在则会清空文件夹，不存在则会创建路径
     如果path是文件 ：存在则会删除，不存在则会创建文件所在路径
     */
    public static func reset(path: String, clear: Bool = true) throws {
        let manager = FileManager.default
        var isDirectory: ObjCBool = false
        
        if manager.fileExists(atPath: path, isDirectory: &isDirectory) {
            guard clear else { return }
            
            try manager.removeItem(atPath: path)
            if isDirectory.boolValue {
                try manager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
            }
        } else {
            let mapPath = path.hasSuffix("/") ? path : (path as NSString).deletingLastPathComponent
            try manager.createDirectory(atPath: mapPath, withIntermediateDirectories: true, attributes: nil)
        }
    }
    
    public static func moveItem(atPath: String, toPath: String) throws {
        try FileManager.default.moveItem(atPath: atPath, toPath: toPath)
    }
    
    public static func write(data: Data, toPath: String) throws {
        try data.write(to: URL(fileURLWithPath: toPath), options: .atomic)
    }
    
    /// 如果path不存在会抛出错误
    public static func readData(from path: String) throws -> Data {
        return try Data(contentsOf: URL(fileURLWithPath: path))
    }
    
    public static func diskSpaceFree() -> Int? {
        let manager = FileManager.default
        guard let attrs = try? manager.attributesOfFileSystem(forPath: NSHomeDirectory()) else { return nil }
        return attrs[.systemFreeSize] as? Int
    }
    
    public static func path(forResource filename: String, ofType ext: String? = nil, bundleClass: AnyClass? = nil) -> String? {
        let cmps = filename.components(separatedBy: ".")
        let name = cmps[0]
        let bundle = bundleClass.map { Bundle(for: $0) } ?? Bundle.main
        
        var type: String? {
            if let t = ext { return t }
            guard cmps.count > 1 else { return nil }
            return cmps[1]
        }
        
        return bundle.path(forResource: name, ofType: type)
    }
    
    public static func path(forItem item: String, in folder: Folder) -> String {
        folder.path(for: item)
    }
    
    public static func totalSize(for directory: String) -> Int {
        let manager = FileManager.default
        guard let enumerator = manager.enumerator(atPath: directory) else { return 0 }
        var size = 0
        let nsDirectory = directory as NSString
        while let fileName = enumerator.nextObject() as? String {
            guard let attr = try? manager.attributesOfItem(atPath: nsDirectory.appendingPathComponent(fileName)),
                    let s = attr[.size] as? Int else { continue }
            size += s
        }
        return size
    }
    
    public static func totalCount(for directory: String) -> Int {
        let manager = FileManager.default
        guard let enumerator = manager.enumerator(at: URL(fileURLWithPath: directory), includingPropertiesForKeys: nil, options: .skipsHiddenFiles) else { return 0 }
        return enumerator.allObjects.count
    }
    
    /// 搜索文件夹中符合条件的文件
    public static func search<Result>(in directory: String, passMap: (_ fileURL: URL) -> Result?) -> (URL, Result)? {
        let keys: [URLResourceKey] = [.isDirectoryKey]
        guard let enumerator = FileManager.default.enumerator(at: URL(fileURLWithPath: directory), includingPropertiesForKeys: keys, options: .skipsHiddenFiles, errorHandler: nil) else {
            return nil
        }
                
        while let next = enumerator.nextObject() {
            guard let fileURL = next as? URL,
            let values = try? fileURL.resourceValues(forKeys: Set(keys)) else { continue }
            guard let v = values.allValues[.isDirectoryKey] as? Bool, !v else {
                continue
            }
            if let res = passMap(fileURL) { return (fileURL, res) }
        }
        return nil
    }
    
    public static func moveDirectory(atPath srcPath: String, toPath dstPath: String) throws {
        guard srcPath != dstPath else { return }
        
        let manager = FileManager.default
        var isDirectory: ObjCBool = false
        
        // 如果源文件夹不存在或者不是文件夹，直接返回
        if !manager.fileExists(atPath: srcPath, isDirectory: &isDirectory) ||
            !isDirectory.boolValue {
            return
        }
        let nssrcPath = srcPath as NSString
        let nsdstPath = dstPath as NSString
        if !manager.fileExists(atPath: dstPath, isDirectory: &isDirectory) ||
            !isDirectory.boolValue {
            if !isDirectory.boolValue {
                try manager.removeItem(atPath: dstPath)
            }
            let dstParentPath = nsdstPath.deletingLastPathComponent
            if !manager.fileExists(atPath: dstParentPath) {
                try manager.createDirectory(atPath: dstParentPath, withIntermediateDirectories: true, attributes: nil)
            }
            try manager.moveItem(atPath: srcPath, toPath: dstPath)
        } else {
            guard let enumerator = manager.enumerator(atPath: srcPath) else {
                return
            }
            while let next = enumerator.nextObject() {
                guard let fileName = next as? String else { continue }
                try manager.moveItem(atPath: nssrcPath.appendingPathComponent(fileName), toPath: nsdstPath.appendingPathComponent(fileName))
            }
            try manager.removeItem(atPath: srcPath)
        }
    }
}
 
/*
#if canImport(Zip)
import Zip

extension SandBox {
    static func unzipFile(_ zipFileURL: URL) throws {
        let destPath = zipFileURL.deletingPathExtension().path + "/"
        let destURL = URL(fileURLWithPath: destPath)
        let tmpDestPath = zipFileURL.deletingLastPathComponent().path + "TEMPLATE/"
        let tmpDestURL = URL(fileURLWithPath: tmpDestPath)
        let manager = FileManager.default
        do {
            try SandBox.reset(path: destPath)
            try SandBox.reset(path: tmpDestPath)
            var unzippedURL: [URL] = []
            try Zip.unzipFile(zipFileURL, destination: tmpDestURL, overwrite: true, password: nil, progress: nil) { unzippedFile in
                let path = unzippedFile.path
                if SandBox.fileExists(atPath: path).isDirector { return }
                let filename = unzippedFile.lastPathComponent
                if filename.hasPrefix(".") { return }
                unzippedURL.append(URL(fileURLWithPath: path))
            }
            for url in unzippedURL {
                try manager.moveItem(at: url, to: destURL.appendingPathComponent(url.lastPathComponent))
            }
            try manager.removeItem(at: tmpDestURL)
        } catch {
            try? manager.removeItem(at: destURL)
            try? manager.removeItem(at: tmpDestURL)
            throw error
        }
    }
}
#endif
 */

/*
 bundle:
 /var/containers/Bundle/Application/E2AD65EF-A541-4279-A2DA-CCB8927F46D6/VideoCutter_dev.app
 
 home:
 /var/mobile/Containers/Data/Application/6CEBBEAF-1DEA-446E-A2D1-D5B03960F2B5
 /home/
      /Documents/
      /Library/
              /Caches/
              /Preferences/
      /SystemData/
      /tmp/
 */
public struct Folder: RawRepresentable {
   public let rawValue: String
   public init(rawValue: String) {
       self.rawValue = rawValue
   }
}
public extension Folder {
    static var home: Folder {
        .init(rawValue: NSHomeDirectory())
    }
    static var document: Folder {
        .init(rawValue: NSHomeDirectory() + "/Documents")
    }
    static var library: Folder {
        .init(rawValue: NSHomeDirectory() + "/Library")
    }
    static var caches: Folder {
        .init(rawValue: NSHomeDirectory() + "/Library/Caches")
    }
    static var preference: Folder {
        .init(rawValue: NSHomeDirectory() + "/Library/Preference")
    }
    static var temporary: Folder {
        .init(rawValue: NSHomeDirectory() + "/tmp")
    }
    static var bundle: Folder {
        .init(rawValue: Bundle.main.bundlePath)
    }
}


extension String {
    public func filePath(under folder: Folder) -> String {
        return folder.path(for: self)
    }
}

public extension Folder {
    func path(for item: String) -> String {
        let home = rawValue
        if item.hasPrefix("/") { return home + item }
        return home + "/\(item)"
    }
    static func + (lhs: Folder, rhs: String) -> String {
        return lhs.path(for: rhs)
    }
    
//    var path: String {
//        switch self {
//        case .home:
//            return NSHomeDirectory()
//        case .document:
//            return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
//        case .library:
//            return NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)[0]
//        case .caches:
//            return NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]
//        case .preference:
//            return NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)[0].appending("/Preference")
//        case .temporary:
//            return NSTemporaryDirectory()
//        case .bundle:
//            return Bundle.main.bundlePath
//        }
//    }
}
