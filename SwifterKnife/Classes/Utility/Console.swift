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
    }
    
    private static let dataFmt: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter
    }()
    private static var timeString: String {
        return dataFmt.string(from: Date())
    }
    
    public static var logEnable: Bool = App.isDebug
    
    private static func buildLog(
        _ content: String,
        blendTime: Bool,
        whose: String = "",
        tag: Tag = .empty,
        file: StaticString,
        line: UInt,
        fn: StaticString) -> String {

        var cmps: [String] = []
        let tagStr = tag.rawValue
        if !tagStr.isEmpty { cmps.append(tagStr) }
        if blendTime { cmps.append(timeString) }
        cmps.append(NSString(stringLiteral: file).lastPathComponent)
        cmps.append(String(line))
        let method = whose.isEmpty ? "\(fn):" : "\(whose).\(fn):"
        cmps.append(String(method))
        cmps.append(content)
        return cmps.joined(separator: " ")
    }
    
    public static func measure(closure: () -> Void) -> Float {
        let start = CACurrentMediaTime()
        closure()
        
        let end = CACurrentMediaTime()
        return Float(end - start)
    }
}

import OSLog
public extension Console {
    static func os(
        _ tag: Tag = .empty,
        _ content: @autoclosure () -> String,
        file: StaticString = #file,
        line: UInt = #line,
        fn: StaticString = #function) {
        guard Console.logEnable else { return }
        let content = buildLog(content(), blendTime: false, tag: tag, file: file, line: line, fn: fn)
        os_log("%s", content)
    }
    static func osInfo(
        _ tag: Tag = .empty,
        _ content: @autoclosure () -> String,
        file: StaticString = #file,
        line: UInt = #line,
        fn: StaticString = #function) {
        guard Console.logEnable else { return }
        let content = buildLog(content(), blendTime: false, tag: tag, file: file, line: line, fn: fn)
        os_log("%{public}s", type: .info, content)
    }
    static func osDebug(
        _ tag: Tag = .empty,
        _ content: @autoclosure () -> String,
        file: StaticString = #file,
        line: UInt = #line,
        fn: StaticString = #function) {
        guard Console.logEnable else { return }
        let content = buildLog(content(), blendTime: false, tag: tag, file: file, line: line, fn: fn)
        os_log("%{public}s", type: .debug, content)
    }
    static func osError(
        _ tag: Tag = .empty,
        _ content: @autoclosure () -> String,
        separator: String = " ",
        file: StaticString = #file,
        line: UInt = #line,
        fn: StaticString = #function) {
        guard Console.logEnable else { return }
        let content = buildLog(content(), blendTime: false, tag: tag, file: file, line: line, fn: fn)
        os_log("%{public}s", type: .error, content)
    }
    static func osFault(
        _ tag: Tag = .empty,
        _ content: @autoclosure () -> String,
        file: StaticString = #file,
        line: UInt = #line,
        fn: StaticString = #function) {
        guard Console.logEnable else { return }
        let content = buildLog(content(), blendTime: false, tag: tag, file: file, line: line, fn: fn)
        os_log("%{public}s", type: .fault, content)
    }
}

public extension Console {
    static func log(
        _ tag: Tag = .empty,
        _ content: @autoclosure () -> String,
        file: StaticString = #file,
        line: UInt = #line,
        fn: StaticString = #function) {
        guard Console.logEnable else { return }
        let content = buildLog(content(), blendTime: true, tag: tag, file: file, line: line, fn: fn)
        print(content)
    }
    
    // 20:47:47.401 ViewController.swift 18 viewDidLoad: hello
    static func log<Whose>(
        _ tag: Tag = .empty,
        _ content: @autoclosure () -> String,
        whose: Whose,
        file: StaticString = #file,
        line: UInt = #line,
        fn: StaticString = #function) { 
        guard Console.logEnable else { return }
        let caller = "\(type(of: whose))"
        let content = buildLog(content(), blendTime: true, whose: caller, tag: tag, file: file, line: line, fn: fn)
        print(content)
    }
    static func logFunc<Whose>(
        whose: Whose,
        file: StaticString = #file,
        line: UInt = #line,
        fn: StaticString = #function) {
        log(.func, "", whose: whose, file: file, line: line, fn: fn)
    }
}

public extension Console {
    /// 重要的日志记录，测试人员和开发人员查看
    // 2021-10-28 20:48:16.251154+0800 SwifterKnife_Example[2550:8953056] world
    static func trace<Whose>(
        _ tag: Tag = .empty,
        _ content: @autoclosure () -> String,
        whose: Whose?,
        separator: String = " ",
        file: StaticString = #file,
        line: UInt = #line,
        fn: StaticString = #function) {
        
        guard logEnable else { return }
        let caller = whose.map { "\(type(of: $0))" } ?? ""
        let content = buildLog(content(), blendTime: false, whose: caller, tag: tag, file: file, line: line, fn: fn)
        NSLog("\n\(content)")
    }
    
    static func trace(
        _ tag: Tag = .empty,
        _ content: @autoclosure () -> String,
        file: StaticString = #file,
        line: UInt = #line,
        fn: StaticString = #function) {
        
        guard logEnable else { return }
        let content = buildLog(content(), blendTime: false, tag: tag, file: file, line: line, fn: fn)
        NSLog("\n\(content)")
    }
}

public extension Console.Tag {
    static let empty: Console.Tag = .init(rawValue: "")
    static let error: Console.Tag = .init(rawValue: "[‼️ Error]")
    static let warning: Console.Tag = .init(rawValue: "[⚠️ Warning]")
    static let info: Console.Tag = .init(rawValue: "[ℹ️ Info]")
    static let success: Console.Tag = .init(rawValue: "[✅ Success]")
    static let `func`: Console.Tag = .init(rawValue: "[FUNC]")
}
