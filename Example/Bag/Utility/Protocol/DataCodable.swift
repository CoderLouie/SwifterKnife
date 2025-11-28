//
//  DataCodable.swift
//  SwifterKnife
//
//  Created by liyang on 2021/10/19.
//

import Foundation
 
// MARK: - DataEncodable

public protocol DataEncodable {
    func encode() throws -> Data
}
public extension DataEncodable {
    func toJSON() -> [String: Any] {
        guard let data = try? encode(),
              let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
            return [:]
        }
        return json
    }
    func toArray() -> [Any] {
        guard let data = try? encode(),
              let array = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [Any] else {
            return []
        }
        return array
    }
    func toString() -> String {
        guard let data = try? encode(),
              let string = String(data: data, encoding: .utf8) else {
            return ""
        }
        return string
    }
    
    func save(toFile path: String) throws {
        let data = try encode()
        try data.write(to: URL(fileURLWithPath: path), options: .atomic)
    }
    func save(toFile url: URL) throws {
        let data = try encode()
        try data.write(to: url, options: .atomic)
    }
}

public extension DataEncodable where Self: Encodable {
    func encode() throws -> Data {
        try JSONEncoder().encode(self)
    }
}
/*
 当Element遵守 Encodable 协议时，Array自动遵守 Encodable
 所以可以自动扩展 Array 遵守 DataEncodable
 */
extension Array: DataEncodable where Element: Encodable {}

public extension DataEncodable where Self: NSCoding {
    func encode() throws -> Data {
        let key = String(describing: type(of: self))
        NSKeyedArchiver.setClassName(key, for: type(of: self))
        return NSKeyedArchiver.archivedData(withRootObject: self)
    }
}

// MARK: - DataDecodable
public protocol DataDecodable {
    static func decode(with data: Data) throws -> Self
}
public extension DataDecodable {
    static func decode(from json: [String: Any]) throws -> Self {
        let data = try JSONSerialization.data(withJSONObject: json, options: .fragmentsAllowed)
        return try decode(with: data)
    }
    static func decode(from jsonArray: [[String: Any]]) throws -> [Self] {
        try jsonArray.map { try decode(from: $0) }
    }
    static func decode(from string: String) throws -> Self {
        let data = Data(string.utf8)
        return try decode(with: data)
    }
    
    static func load(fromFile path: String) throws -> Self {
        let data = try Data(contentsOf: URL(fileURLWithPath: path))
        return try decode(with: data)
    }
    static func load(fromFile url: URL) throws -> Self {
        let data = try Data(contentsOf: url)
        return try decode(with: data)
    }
}


public extension DataDecodable where Self: Decodable {
    static func decode(with data: Data) throws -> Self {
        try JSONDecoder().decode(Self.self, from: data)
    }
}
/*
 当Element遵守 Decodable 协议时，Array自动遵守 Decodable
 所以可以自动扩展 Array 遵守 DataDecodable
 */
extension Array: DataDecodable where Element: Decodable {}

public extension DataDecodable where Self: NSCoding {
    static func decode(with data: Data) throws -> Self {
        let key = String(describing: Self.self)
        NSKeyedUnarchiver.setClass(Self.self, forClassName: key)
        guard let model = NSKeyedUnarchiver.unarchiveObject(with: data) as? Self else {
            throw NSError(domain: "com.data.decodable", code: -1, userInfo: ["message": "can't unarchive data to \(Self.self)"])
        }
        return model
    }
}

// MARK: - DataCodable

public typealias DataCodable = DataDecodable & DataEncodable
