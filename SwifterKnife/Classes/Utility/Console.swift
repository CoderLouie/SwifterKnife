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
    
    public static var printEnable: Bool = App.isDebug
    public static var nslogEnable: Bool = App.isDebug
    
    private static func buildLog(
        _ items: [Any],
        blendTime: Bool,
        whose: String = "",
        tag: Tag = .empty,
        separator: String,
        file: StaticString,
        line: UInt,
        fn: StaticString) -> String {
        var newItems: [Any] = []
        var i = 0
        let n = items.count
        while i < n {
            let item = items[i]
            i += 1
            guard let format = item as? String, format.contains("%") else {
                newItems.append(item)
                continue
            }
            
            let regex: Regex = #"(%@)|(%c)|(%s)|(%\d*l{0,2}[d|D|i|u|U])|(%\d*\.*\d*[f|g])"#
            let count = regex.matchesCount(in: format)
            guard count > 0 else {
                newItems.append(item)
                continue
            }
            
            var args: [CVarArg] = []
            args.reserveCapacity(count)
            var n = 0
            for item in items[i...] {
                if args.count >= count { break }
                if let arg = item as? CVarArg {
                    args.append(arg)
                } else { newItems.append(item) }
                n += 1
            }
            if args.count < count {
                fatalError("the format string \(format) must has \(count) params")
            }
            let str = String(format: format, arguments: args)
            newItems.append(str)
            i += n
        }
            
        let method = whose.isEmpty ? "\(fn):" : "\(whose).\(fn):"
        var cmps: [String] = [tag.rawValue]
        if blendTime { cmps.append(timeString) }
        cmps.append(NSString(stringLiteral: file).lastPathComponent)
        cmps.append(String(line))
        cmps.append(String(method))
        let content = newItems.map(String.init(describing:)).joined(separator: separator)
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
        _ items: Any...,
        tag: Tag = .empty,
        separator: String = " ",
        file: StaticString = #file,
        line: UInt = #line,
        fn: StaticString = #function) {
        guard Console.nslogEnable else { return }
        let content = buildLog(items, blendTime: false, tag: tag, separator: separator, file: file, line: line, fn: fn)
        os_log("%s", content)
    }
    static func osInfo(
        _ items: Any...,
        tag: Tag = .empty,
        separator: String = " ",
        file: StaticString = #file,
        line: UInt = #line,
        fn: StaticString = #function) {
        guard Console.nslogEnable else { return }
        let content = buildLog(items, blendTime: false, tag: tag, separator: separator, file: file, line: line, fn: fn)
        os_log("%s", type: .info, content)
    }
    static func osDebug(
        _ items: Any...,
        tag: Tag = .empty,
        separator: String = " ",
        file: StaticString = #file,
        line: UInt = #line,
        fn: StaticString = #function) {
        guard Console.nslogEnable else { return }
        let content = buildLog(items, blendTime: false, tag: tag, separator: separator, file: file, line: line, fn: fn)
        os_log("%s", type: .debug, content)
    }
    static func osError(
        _ items: Any...,
        tag: Tag = .empty,
        separator: String = " ",
        file: StaticString = #file,
        line: UInt = #line,
        fn: StaticString = #function) {
        guard Console.nslogEnable else { return }
        let content = buildLog(items, blendTime: false, tag: tag, separator: separator, file: file, line: line, fn: fn)
        os_log("%s", type: .error, content)
    }
    static func osFault(
        _ items: Any...,
        tag: Tag = .empty,
        separator: String = " ",
        file: StaticString = #file,
        line: UInt = #line,
        fn: StaticString = #function) {
        guard Console.nslogEnable else { return }
        let content = buildLog(items, blendTime: false, tag: tag, separator: separator, file: file, line: line, fn: fn)
        os_log("%s", type: .fault, content)
    }
}

public extension Console {
    static func log(
        _ items: Any...,
        tag: Tag = .empty,
        separator: String = " ",
        file: StaticString = #file,
        line: UInt = #line,
        fn: StaticString = #function) {
        guard Console.printEnable else { return }
        let content = buildLog(items, blendTime: true, tag: tag, separator: separator, file: file, line: line, fn: fn)
        print(content)
    }
    
    // 20:47:47.401 ViewController.swift 18 viewDidLoad: hello
    static func log<Whose>(
        _ items: Any...,
        whose: Whose?,
        tag: Tag = .empty,
        separator: String = " ",
        file: StaticString = #file,
        line: UInt = #line,
        fn: StaticString = #function) {
            
        guard Console.printEnable else { return }
        let caller = whose.map { "\(type(of: $0))" } ?? ""
        let content = buildLog(items, blendTime: true, whose: caller, tag: tag, separator: separator, file: file, line: line, fn: fn)
        print(content)
    }
    static func logFunc<Whose>(
        whose: Whose,
        file: StaticString = #file,
        line: UInt = #line,
        fn: StaticString = #function) {
        log(whose: whose, tag: .func, file: file, line: line, fn: fn)
    }
}

public extension Console {
    /// 重要的日志记录，测试人员和开发人员查看
    // 2021-10-28 20:48:16.251154+0800 SwifterKnife_Example[2550:8953056] world
    static func trace<Whose>(
        _ items: Any...,
        whose: Whose?,
        tag: Tag = .empty,
        separator: String = " ",
        file: StaticString = #file,
        line: UInt = #line,
        fn: StaticString = #function) {
        
        guard nslogEnable else { return }
        let caller = whose.map { "\(type(of: $0))" } ?? ""
        let content = buildLog(items, blendTime: false, whose: caller, tag: tag, separator: separator, file: file, line: line, fn: fn)
        os_log("%s", content)
    }
    
    /*
     let values: [String: Any] = [
         "age": 10,
         "score": [10, 20, 30],
         "name": "xiaohuang"
     ]
     let num = 10
     let val = 3.1415926
     Console.trace("喝了咯 hello %@ %05d, %.3f", values, num, val, num, val)
     喝了咯 hello {
        age = 10;
        name = xiaohuang;
        score = (
            10,
            20,
            30
        );
     } 00010, 3.142, 10 3.1415926
     */
    static func trace(
        _ items: Any...,
        tag: Tag = .empty,
        separator: String = " ",
        file: StaticString = #file,
        line: UInt = #line,
        fn: StaticString = #function) {
        
        guard nslogEnable else { return }
        let content = buildLog(items, blendTime: false, tag: tag, separator: separator, file: file, line: line, fn: fn)
        os_log("%{public}s", content)
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
