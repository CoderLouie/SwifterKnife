//
//  ExCodable.swift
//  ExCodable
//
//  Created by Mr. Ming on 2021-02-10.
//  Copyright (c) 2021 Mr. Ming <minglq.9@gmail.com>. Released under the MIT license.
//

import Foundation

/**
 *  # ExCodable
 *
 *  A protocol extends `Encodable` & `Decodable` with `keyMapping`
 *
 *  - seealso: [Usage](https://github.com/iwill/ExCodable#usage) from GitGub
 *  - seealso: `ExCodableTests.swift` form the source code
 */

public protocol ExCodingKeyMap {
    associatedtype Root = Self where Root: ExCodingKeyMap
    static var keyMapping: [KeyMap<Root>] { get }
}
 
public extension Encodable where Self: ExCodingKeyMap {
    func encode(to encoder: Encoder, with keyMapping: [KeyMap<Self>]) {
        keyMapping.forEach { $0.encode?(self, encoder) }
    }
}
public extension Encodable where Self: ExCodingKeyMap, Self.Root == Self {
    func encode(to encoder: Encoder) throws {
        encode(to: encoder, with: Self.keyMapping)
    }
}
public extension Decodable where Self: ExCodingKeyMap {
    mutating func decode(from decoder: Decoder, with keyMapping: [KeyMap<Self>]) {
        keyMapping.forEach { $0.decode?(&self, decoder) }
    }
}
public extension Decodable where Self: ExCodingKeyMap, Self: AnyObject {
    func decode(from decoder: Decoder, with keyMapping: [KeyMap<Self>]) {
        var this = self
        keyMapping.forEach { $0.decode?(&this, decoder) }
    }
}

// MARK: -
public final class KeyMap<Root> {
    fileprivate typealias EncodeClosure = (_ root: Root, _ encoder: Encoder) -> Void
    fileprivate var encode: EncodeClosure?
    
    fileprivate typealias DecodeValClosure = (_ root: inout Root, _ decoder: Decoder) -> Void
    fileprivate var decode: DecodeValClosure?
    
    fileprivate init(encode: EncodeClosure?,
                     decode: DecodeValClosure?) {
        (self.encode, self.decode) = (encode, decode)
    }
    fileprivate init() {  }
    
    fileprivate func setEncode<Value: Encodable>(_ keyPath: WritableKeyPath<Root, Value>, to codingKeys: [String]) {
        self.encode = { (root, encoder) in
            try? encoder.encode(root[keyPath: keyPath], for: codingKeys[0])
        }
    }
    
    fileprivate func setDecode<Value: Decodable>(_ keyPath: WritableKeyPath<Root, Value>, to codingKeys: [String]) {
        self.decode = { (root, decoder) in
            if let value: Value = try? decoder.decode(codingKeys) {
                root[keyPath: keyPath] = value
            }
        }
    }
}

public extension KeyMap {
    convenience init<Value: Decodable>(_ keyPath: WritableKeyPath<Root, Value>, to codingKeys: String...) {
        self.init()
        setDecode(keyPath, to: codingKeys)
    }
    convenience init<Value: Encodable>(_ keyPath: WritableKeyPath<Root, Value>, to codingKeys: String...) {
        self.init()
        setEncode(keyPath, to: codingKeys)
    }
    
    convenience init<Value: Codable>(_ keyPath: WritableKeyPath<Root, Value>, to codingKeys: String...) {
        self.init()
        setEncode(keyPath, to: codingKeys)
        setDecode(keyPath, to: codingKeys)
    }
}
 

// MARK: -

public extension Encoder {
    func encode<T: Encodable>(_ value: T, for stringKey: String) throws {
        if case Optional<Any>.none = (value as Any) {
            return
        }
        var keys = stringKey.split(separator: ".").map { ExCodingKey($0) }
        var container = container(keyedBy: ExCodingKey.self)
        guard keys.count > 1 else {
            try container.encode(value, forKey: keys[0])
            return
        }
        let lastKey = keys.removeLast()
        
        for key in keys {
            container = container.nestedContainer(keyedBy: ExCodingKey.self, forKey: key)
        }
        try container.encode(value, forKey: lastKey)
    }
}


public extension Decoder {
    func nestedContainer(forKey key: String) throws -> KeyedDecodingContainer<ExCodingKey> {
        try container(keyedBy: ExCodingKey.self).nestedContainer(forKey: key)
    }
}
public extension KeyedDecodingContainer where Key == ExCodingKey {
    func nestedContainer(forKey key: String) throws -> Self {
        var container = self
        let keys = key.split(separator: ".")
        guard keys.count > 1 else {
            return try nestedContainer(keyedBy: ExCodingKey.self, forKey: ExCodingKey(key))
        }
        for key in keys {
            container = try container.nestedContainer(keyedBy: ExCodingKey.self, forKey: ExCodingKey(key))
        }
        return container
    }
    func nestedContainer(forKey key: Key) throws -> Self {
        try nestedContainer(keyedBy: ExCodingKey.self, forKey: key)
    }
    func decode<T: Decodable>(forKey key: Key) throws -> T {
        try decode(T.self, forKey: key)
    }
    func decodeIfPresent<T: Decodable>(forKey key: Key) throws -> T? {
        try decodeIfPresent(T.self, forKey: key)
    }
    func decode<T: Decodable>(forKey key: String) throws -> T {
        try decode(T.self, forKey: Key(key))
    }
    func decodeIfPresent<T: Decodable>(forKey key: String) throws -> T? {
        try decodeIfPresent(T.self, forKey: Key(key))
    }
}

private struct ExDecodeError: CustomStringConvertible, Error {
    let text: String
    init(_ text: String) { self.text = text }
    var description: String { text }
}
public extension Decoder {
    func decode<T: Decodable>(_ stringKeys: String..., as type: T.Type = T.self) throws -> T {
        return try decode(stringKeys, as: type)
    }
    func decode<T: Decodable>(_ keys: [String], as type: T.Type = T.self) throws -> T {
        let container = try? container(keyedBy: ExCodingKey.self)
        for key in keys {
            if let val = container?.tryNestedDecode(type, forKey: key) {
                return val
            }
        }
        if let valueType = T.self as? ExpressibleByNilLiteral.Type {
            return valueType.init(nilLiteral: ()) as! T
        } 
        throw ExDecodeError("decode failure: keys: \(keys)")
    }
}
// MARK: - alternative-keys + nested-keys + type-conversion

private extension KeyedDecodingContainer where K == ExCodingKey {
    func tryNestedDecode<Value>(_ type: Value.Type = Value.self, forKey key: String) -> Value? {
        var keys = key.split(separator: ".")
        guard keys.count > 1 else {
            return tryNormalDecode(type, forKey: key)
        }
        var container = try? nestedContainer(keyedBy: ExCodingKey.self, forKey: .init(keys.removeFirst()))
        let lastKey = keys.removeLast()
        for key in keys {
            container = try? container?.nestedContainer(keyedBy: ExCodingKey.self, forKey: .init(key))
        }
        return container?.tryNormalDecode(type, forKey: String(lastKey))
    }
    func tryNormalDecode<Value>(_ type: Value.Type = Value.self, forKey key: String) -> Value? {
        guard let key = Key(stringValue: key) else {
            return nil
        }
        let value = try? decodeIfPresent(AnyDecodable.self, forKey: key)?.value
        if let value = value {
            if let converted = value as? Value {
                return converted
            }
            if let _bridged = (Value.self as? _BuiltInBridgeType.Type)?._transform(from: value), let __bridged = _bridged as? Value {
                return __bridged
            }
            if let valueType = Value.self as? Decodable.Type {
                if let value = try? valueType.decode(from: self, forKey: key) as? Value {
                    return value
                }
            }
        }
        return nil
    }
}
private extension Decodable {
    static func decode<K>(from container: KeyedDecodingContainer<K>, forKey key: KeyedDecodingContainer<K>.Key) throws -> Self {
        return try container.decode(Self.self, forKey: key)
    }
}
 
