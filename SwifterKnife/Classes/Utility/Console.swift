//
//  Console.swift
//  SwifterKnife
//
//  Created by liyang on 2021/10/19.
//

import Foundation

public enum Console {
    
    public struct Tag: RawRepresentable {
        public let rawValue: String
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
        fileprivate var log: String {
            guard !rawValue.isEmpty else { return "" }
            return "\(rawValue) "
        }
    }
    
    private static let dataFmt: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter
    }()
    private static var timeString: String {
        return dataFmt.string(from: Date())
    }
    
    public static var printEnable: Bool = App.isDebug
    public static var nslogEnable: Bool = App.isDebug
    
    public static func buildLog(
        _ items: [Any],
        blendTime: Bool,
        tag: Tag,
        separator: String,
        file: NSString,
        line: Int,
        fn: String) -> String {
        
        let flag: Bool? = nil
        return buildLog(items, blendTime: blendTime, whose: flag, tag: tag, separator: separator, file: file, line: line, fn: fn)
    }
    public static func buildLog<Whose>(
        _ items: [Any],
        blendTime: Bool,
        whose: Whose?,
        tag: Tag,
        separator: String,
        file: NSString,
        line: Int,
        fn: String) -> String {
        if let format = items.first as? String, format.contains("%") {
            let regex: Regex = #"(%@)|(%c)|(%s)|(%\d*l{0,2}[d|D|i|u|U])|(%\d*\.*\d*[f|g])"#
            let count = regex.matchesCount(in: format)
            if count > 0 {
                guard items.count > count else {
                    fatalError("the format string \(format) must has \(count) params")
                }
                let str = String(format: format, arguments: items[1...count].compactMap { $0 as? CVarArg })
                return _buildLog([str] + items[(count+1)...], blendTime: blendTime, whose: whose, tag: tag, separator: separator, file: file, line: line, fn: fn)
            }
        }
        return _buildLog(items, blendTime: blendTime, whose: whose, tag: tag, separator: separator, file: file, line: line, fn: fn)
    }
    private static func _buildLog<Whose>(
        _ items: [Any],
        blendTime: Bool,
        whose: Whose?,
        tag: Tag,
        separator: String,
        file: NSString,
        line: Int,
        fn: String) -> String {
        
        let caller = whose.map { "\(type(of: $0))." } ?? ""
        let method = "\(caller)\(fn)"
        var prefix = "\(tag.log)\(blendTime ? timeString + " " : "")\(file.lastPathComponent) \(line) \(method)"
        prefix.append(":")
        let content = items.map { String(describing: $0) }.joined(separator: separator)
        prefix += " \(content)"
        return prefix
    }
    
    public static func log(
        _ items: Any...,
        tag: Tag = .none,
        separator: String = " ",
        file: NSString = #file,
        line: Int = #line,
        fn: String = #function) {
        
        guard Console.printEnable else { return }
        let content = buildLog(items, blendTime: true, tag: tag, separator: separator, file: file, line: line, fn: fn)
        print(content)
    }
    
    // 20:47:47.401 ViewController.swift 18 viewDidLoad: hello
    public static func log<Whose>(
        _ items: Any...,
        whose: Whose?,
        tag: Tag = .none,
        separator: String = " ",
        file: NSString = #file,
        line: Int = #line,
        fn: String = #function) {
        
        guard Console.printEnable else { return }
        let content = buildLog(items, blendTime: true, whose: whose, tag: tag, separator: separator, file: file, line: line, fn: fn)
        print(content)
    }
    public static func logFunc<Whose>(
        whose: Whose,
        file: NSString = #file,
        line: Int = #line,
        fn: String = #function) {
        log(whose: whose, tag: .func, file: file, line: line, fn: fn) 
    }
    
    /// 重要的日志记录，测试人员和开发人员查看
    // 2021-10-28 20:48:16.251154+0800 SwifterKnife_Example[2550:8953056] world
    public static func trace<Whose>(
        _ items: Any...,
        whose: Whose?,
        tag: Tag = .none,
        separator: String = " ",
        file: NSString = #file,
        line: Int = #line,
        fn: String = #function) {
        
        guard nslogEnable else { return }
        
        let content = buildLog(items, blendTime: false, whose: whose, tag: tag, separator: separator, file: file, line: line, fn: fn)
        NSLog("\n\(content)")
    }
    
    
    public static func trace(
        _ items: Any...,
        tag: Tag = .none,
        separator: String = " ",
        file: NSString = #file,
        line: Int = #line,
        fn: String = #function) {
        
        guard nslogEnable else { return }
        
        let content = buildLog(items, blendTime: false, tag: tag, separator: separator, file: file, line: line, fn: fn)
        NSLog("\n\(content)")
    }
    
    public static func measure(closure: () -> Void) -> Float {
        let start = CACurrentMediaTime()
        closure()
        
        let end = CACurrentMediaTime()
        return Float(end - start)
    }
}

public extension Console.Tag {
    static let none: Console.Tag = .init(rawValue: "")
    static let error: Console.Tag = .init(rawValue: "[‼️ Error]")
    static let warning: Console.Tag = .init(rawValue: "[⚠️ Warning]")
    static let info: Console.Tag = .init(rawValue: "[ℹ️ Info]")
    static let success: Console.Tag = .init(rawValue: "[✅ Success]")
    static let `func`: Console.Tag = .init(rawValue: "[FUNC]")
}
