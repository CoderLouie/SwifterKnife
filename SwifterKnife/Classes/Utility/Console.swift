//
//  Console.swift
//  SwifterKnife
//
//  Created by liyang on 2021/10/19.
//

import Foundation

public enum Console {
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
    // 20:47:47.401 ViewController.swift 18 viewDidLoad: hello
    public static func log(_ items: Any...,
                           separator: String = " ",
                           terminator: String = "\n",
                           file: NSString = #file,
                           line: Int = #line,
                           fn: String = #function) {
        guard Console.printEnable else { return }
        var prefix = "\(timeString) \(file.lastPathComponent) \(line) \(fn)"
        if prefix.hasSuffix("()") { prefix = String(prefix.dropLast(2)) }
        prefix.append(":")
        let content = items.map { String(describing: $0) }.joined(separator: separator)
        print(prefix, content, terminator: terminator)
    }
    public static func logFunc(file: NSString = #file,
                               line: Int = #line,
                               fn: String = #function) {
        log(file: file, line: line, fn: fn)
    }
    
    /// 重要的日志记录，测试人员和开发人员查看
    // 2021-10-28 20:48:16.251154+0800 SwifterKnife_Example[2550:8953056] world
    public static func trace(_ items: Any...,
                             separator: String = " ",
                             terminator: String = "\n",
                             file: NSString = #file,
                             line: Int = #line ) {
        guard nslogEnable else { return }
        let content = items.map { String(describing: $0) }.joined(separator: separator)
        NSLog(content)
    }
}
