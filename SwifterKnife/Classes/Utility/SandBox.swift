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
        progress:(_ path: String, _ level: Int, _ stop: UnsafeMutablePointer<Bool>) throws -> Void) rethrows {
        
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
    
    /*
     如果path是文件夹：存在则会清空文件夹，不存在则会创建路径
     如果path是文件 ：存在则会删除，不存在则会创建文件所在路径
     */
    public static func reset(path: String, clear: Bool = true) throws {
        let manager = FileManager.default
        var isDirectory: ObjCBool = false
        
        if manager.fileExists(atPath: path, isDirectory: &isDirectory) {
            if clear {
                try manager.removeItem(atPath: path)
            }
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
        let type = ext ?? cmps[1]
        
        return bundle.path(forResource: name, ofType: type)
    }
    
    public static func path(forItem item: String, in folder: Folder) -> String {
        folder.path(for: item)
    }
    
    public static func randomVideoPath(clear: Bool = true) -> String {
        let directory = SandBox.path(forItem: "/Video/", in: .temporary)
        try? SandBox.reset(path: directory, clear: clear)
        return directory + "\(UUID().uuidString).mov"
    }
}


extension SandBox {
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
}
public extension SandBox.Folder {
    static var home: SandBox.Folder {
        .init(rawValue: NSHomeDirectory())
    }
    static var document: SandBox.Folder {
        .init(rawValue: NSHomeDirectory() + "/Documents")
    }
    static var library: SandBox.Folder {
        .init(rawValue: NSHomeDirectory() + "/Library")
    }
    static var caches: SandBox.Folder {
        .init(rawValue: NSHomeDirectory() + "/Library/Caches")
    }
    static var preference: SandBox.Folder {
        .init(rawValue: NSHomeDirectory() + "/Library/Preference")
    }
    static var temporary: SandBox.Folder {
        .init(rawValue: NSHomeDirectory() + "/tmp")
    }
    static var bundle: SandBox.Folder {
        .init(rawValue: Bundle.main.bundlePath)
    }
}


extension String {
    public func filePath(under folder: SandBox.Folder) -> String {
        return folder.path(for: self)
    }
}

extension SandBox.Folder {
    fileprivate func path(for item: String) -> String {
        let home = rawValue
        if item.hasPrefix("/") { return home + item }
        return home + "/\(item)"
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
