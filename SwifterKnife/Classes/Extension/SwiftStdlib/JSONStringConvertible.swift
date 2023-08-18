//
//  JSONStringConvertible.swift
//  SwifterKnife
//
//  Created by liyang on 2023/8/18.
//

public protocol JSONStringConvertible {
    var jsonObject: Any { get }
}

extension JSONStringConvertible {
    public var jsonObject: Any { self }
}

public extension JSONStringConvertible { 
    func jsonData(prettify: Bool = false) -> Data? {
        guard JSONSerialization.isValidJSONObject(jsonObject) else { return nil }
        var options: JSONSerialization.WritingOptions = [.sortedKeys]
        if prettify { options.insert(.prettyPrinted) }
        if #available(iOS 13.0, *) {
            options.insert(.withoutEscapingSlashes)
        }
        return try? JSONSerialization.data(withJSONObject: self, options: options)
    }
    
    func jsonString(prettify: Bool = false) -> String? {
        guard let jsonData = jsonData(prettify: prettify) else { return nil }
        return String(data: jsonData, encoding: .utf8)
    }
}

extension Dictionary: JSONStringConvertible {}
extension Array: JSONStringConvertible {}
extension NSDictionary: JSONStringConvertible {}
extension NSArray: JSONStringConvertible {}
