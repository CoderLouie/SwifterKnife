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
        pass condition: (String) -> Bool,
        progress:(_ path: String,
                  _ level: Int,
                  _ mgr: FileManager,
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
                guard condition(path) else { return }
                return try progress(path, innerLevel, manager, &stop)
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
    
    public static func fileExists(atPath path: String) -> (exists: Bool, isDirectory: Bool) {
        var isDirectory: ObjCBool = false
        let exists = FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory)
        return (exists, isDirectory.boolValue)
    }
    
    public static func isDirectory(_ url: URL) -> Bool {
        return isDirectory(url.path)
    }
    public static func isDirectory(_ path: String) -> Bool {
        let manager = FileManager.default
        var isDirectory: ObjCBool = false
        guard manager.fileExists(atPath: path, isDirectory: &isDirectory) else { return false }
        return isDirectory.boolValue
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
    public static func createDirectory(atPath path: String) throws {
        try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
    }
    public static func createDirectory(at fileUrl: URL) throws {
        try FileManager.default.createDirectory(at: fileUrl, withIntermediateDirectories: true, attributes: nil)
    }
    
    public static func moveItem(at path: String, to folder: String) throws {
        if path.hasPrefix(folder) { return }
        let dstPath = (folder as NSString).appendingPathComponent((path as NSString).lastPathComponent)
        try FileManager.default.moveItem(atPath: path, toPath: dstPath)
    }
    public static func copyItem(at path: String, to folder: String) throws {
        if path.hasPrefix(folder) { return }
        let dstPath = (folder as NSString).appendingPathComponent((path as NSString).lastPathComponent)
        try FileManager.default.copyItem(atPath: path, toPath: dstPath)
    }
     
    @discardableResult
    public static func renameFile(at url: URL, newName closure: (_ filename: String) -> String?) throws -> Bool {
        let mgr = FileManager.default
        guard mgr.fileExists(atPath: url.path) else { return false }
        let filename = url.lastPathComponent
        guard let newname = closure(filename), !newname.isEmpty else { return false }
        let newurl = url.deletingLastPathComponent().appendingPathComponent(newname)
        try mgr.moveItem(at: url, to: newurl)
        return true
    }
    public static func replaceFileContent(at path: String, use map: [String: String]) throws {
        let url = URL(fileURLWithPath: path)
        let data = try Data(contentsOf: url)
        guard var string = String(data: data, encoding: .utf8) else { return }
        
        for (key, value) in map {
            string = string.replacingOccurrences(of: key, with: value)
        }
        try string.data(using: .utf8)?.write(to: url, options: .atomic)
    }
    public static func write(data: Data, toPath: String) throws {
        try data.write(to: URL(fileURLWithPath: toPath), options: .atomic)
    }
    public static func read(at srcPath: String, writeTo detPath: String) throws {
        try Data(contentsOf: URL(fileURLWithPath: srcPath)).write(to: URL(fileURLWithPath: detPath))
    }
    
    /// 如果path不存在会抛出错误
    public static func readData(from path: String) throws -> Data {
        return try Data(contentsOf: URL(fileURLWithPath: path))
    }
    
    /// 逐行读取文本文件
    public static func readLines(_ path: String, filter: (String) -> Bool) -> String? {
        guard let handle = FileHandle(forReadingAtPath: path) else {
            return nil
        }
        let newLineData = "\n".data(using: .utf8)
        var data = Data()
        let length = handle.seekToEndOfFile()
        var offset: UInt64 = 0
        handle.seek(toFileOffset: offset)
        
        while offset < length {
            let chunk = handle.readData(ofLength: 1)
            offset += 1
            if chunk == newLineData {
                if let str = String(data: data, encoding: .utf8),
                   filter(str) { return str }
                data = Data()
            } else {
                data += chunk
            }
        }
        return nil
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
        let manager = FileManager.default
        var isDirectory: ObjCBool = false
        let fold = URL(fileURLWithPath: directory)
        guard let contents = try? manager.contentsOfDirectory(atPath: directory) else { return nil }
        
        for item in contents where !item.hasPrefix(".") {
            let url = fold.appendingPathComponent(item)
            guard manager.fileExists(atPath: url.path, isDirectory: &isDirectory) else { continue }
            if isDirectory.boolValue { continue }
            if let res = passMap(url) {
                return (url, res)
            }
        }
        return nil
    }
    public static func deepSearch(
        in fold: URL,
        maxLevel: Int? = nil,
        pass condition: (_ fileURL: URL, _ level: Int) throws -> Bool) rethrows -> URL? {
        if let level = maxLevel, level < 0 { return nil }
        let manager = FileManager.default
        var isDirectory: ObjCBool = false
        
        var targetUrl: URL? = nil
        func enumerateContents(of url: URL, innerLevel: Int) throws -> URL? {
            guard targetUrl == nil else { return nil }
            let path = url.path
            guard manager.fileExists(atPath: path, isDirectory: &isDirectory) else {
                return nil
            }
            guard isDirectory.boolValue else {
                if try condition(url, innerLevel) {
                    if targetUrl == nil {
                        targetUrl = url; return url
                    }
                }
                return nil
            }
            if let level = maxLevel, innerLevel > level { return nil }
            let contents = try manager.contentsOfDirectory(atPath: path)
            for item in contents where !item.hasPrefix(".") {
                if let res = try enumerateContents(of: url + item, innerLevel: innerLevel + 1) { return res }
            }
            return nil
        }
        return try enumerateContents(of: fold, innerLevel: 0)
    }
    
    public static func deepAllFiles(
        in fold: URL, pass condition: (_ fileURL: URL, _ level: Int) throws -> Bool) rethrows -> [URL] {
        let manager = FileManager.default
        var isDirectory: ObjCBool = false
        var res: [URL] = []
        func enumerateContents(of url: URL, innerLevel: Int) throws {
            let path = url.path
            guard manager.fileExists(atPath: path, isDirectory: &isDirectory) else { return }
            guard isDirectory.boolValue else {
                if try condition(url, innerLevel) {
                    res.append(url)
                }
                return
            }
            let contents = try manager.contentsOfDirectory(atPath: path)
            for item in contents where !item.hasPrefix(".") {
                try enumerateContents(of: url + item, innerLevel: innerLevel + 1)
            }
        }
        try enumerateContents(of: fold, innerLevel: 0)
        return res
    }
    
    public static func allFiles(in fold: URL, isInclude: (_ fileURL: URL) -> Bool) -> [URL] {
        let manager = FileManager.default
        var isDirectory: ObjCBool = false
        guard let contents = try? manager.contentsOfDirectory(atPath: fold.path) else { return [] }
        var res: [URL] = []
        for item in contents where !item.hasPrefix(".") {
            let url = fold.appendingPathComponent(item)
            guard manager.fileExists(atPath: fold.path, isDirectory: &isDirectory) else { continue }
            if isDirectory.boolValue { continue }
            if isInclude(url) {
                res.append(url)
            }
        }
        return res
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
    
    func createTemporaryDirectory() throws -> URL {
        let mgr = FileManager.default
        return try mgr.url(for: .itemReplacementDirectory,
                           in: .userDomainMask,
                           appropriateFor: mgr.temporaryDirectory,
                           create: true)
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
    @available(*, deprecated, message: "filePath(under:) deprecated and will be removed in the future. Use fullPath(under:) instead.")
    public func filePath(under folder: Folder) -> String {
        return fullFilePath(under: folder)
    }
    public func fullFilePath(under folder: Folder) -> String {
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
