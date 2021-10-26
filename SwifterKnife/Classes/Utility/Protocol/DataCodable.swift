//
//  DataConvertible.swift
//  SwifterKnife
//
//  Created by liyang on 2021/10/19.
//

import Foundation
 
// MARK: - DataEncodable

public protocol DataEncodable {
    func encode() throws -> Data
}
extension DataEncodable {
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
}

extension DataEncodable where Self: Encodable {
    func encode() throws -> Data {
        try JSONEncoder().encode(self)
    }
}
extension DataEncodable where Self: NSCoding {
    func encode() throws -> Data {
        NSKeyedArchiver.archivedData(withRootObject: self)
    }
}

// MARK: - DataDecodable
public protocol DataDecodable {
    static func decode(with data: Data) throws -> Self
}
extension DataDecodable {
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
}


extension DataDecodable where Self: Decodable {
    static func decode(with data: Data) throws -> Self {
        try JSONDecoder().decode(Self.self, from: data)
    }
}

extension DataDecodable where Self: NSCoding {
    static func decode(with data: Data) throws -> Self {
        guard let model = NSKeyedUnarchiver.unarchiveObject(with: data) as? Self else {
            fatalError()
        }
        return model
    }
}

// MARK: - DataCodable

public typealias DataCodable = DataDecodable & DataEncodable
