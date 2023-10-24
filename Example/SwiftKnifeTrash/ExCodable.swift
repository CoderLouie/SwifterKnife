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

// MARK: -
@propertyWrapper
public final class ExCodableMap<Value> {
    public var wrappedValue: Value
    public init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }
}
extension ExCodableMap: PropertyValuesConvertible {
    public var propertyValues: Any { wrappedValue }
}
@propertyWrapper
public final class ExCodableKeyMap<Value> {
    fileprivate let keys: [String]
    public var wrappedValue: Value
    public init(wrappedValue: Value, _ keys: String...) {
        self.wrappedValue = wrappedValue
        self.keys = keys
    }
}
extension ExCodableKeyMap: PropertyValuesConvertible {
    public var propertyValues: Any { wrappedValue }
}
fileprivate protocol EncodablePropertyWrapper {
    func encode(to encoder: Encoder, label: String) throws
}
extension ExCodableMap: EncodablePropertyWrapper where Value: Encodable {
    func encode(to encoder: Encoder, label: String) throws {
        try encoder.encode(wrappedValue, for: label)
    }
}
extension ExCodableKeyMap: EncodablePropertyWrapper where Value: Encodable {
    func encode(to encoder: Encoder, label: String) throws {
        try encoder.encode(wrappedValue, for: keys.first ?? label)
    }
}

fileprivate protocol DecodablePropertyWrapper {
    func decode(from decoder: Decoder, label: String) throws
}
extension ExCodableMap: DecodablePropertyWrapper where Value: Decodable {
    func decode(from decoder: Decoder, label: String) throws {
        if let value: Value = try decoder.decode(label) {
            wrappedValue = value
        }
    }
}
extension ExCodableKeyMap: DecodablePropertyWrapper where Value: Decodable {
    func decode(from decoder: Decoder, label: String) throws {
        let keys = keys.isEmpty ? [label] : keys
        if let value: Value = try decoder.decode(keys) {
            wrappedValue = value
        }
    }
}
public protocol ExAutoEncodable: Encodable {}
public extension ExAutoEncodable {
    func encode(to encoder: Encoder) throws {
        try? ex_encode(to: encoder)
    }
}

public protocol ExAutoDecodable: Decodable { init() }
public extension ExAutoDecodable {
    init(from decoder: Decoder) throws {
        self.init()
        try? ex_decode(from: decoder)
    }
}
public extension Encodable {
    func ex_encode(to encoder: Encoder) throws {
        let childs = sequence(first: Mirror(reflecting: self), next: \.superclassMirror).flatMap(\.children)
        for case let (label?, value) in childs {
            try (value as? EncodablePropertyWrapper)?.encode(to: encoder, label: String(label.dropFirst()))
        }
    }
}

public extension Decodable {
    func ex_decode(from decoder: Decoder) throws {
        let childs = sequence(first: Mirror(reflecting: self), next: \.superclassMirror).flatMap(\.children)
        for case let (label?, value) in childs {
            try (value as? DecodablePropertyWrapper)?.decode(from: decoder, label: String(label.dropFirst()))
        }
    }
}
public typealias ExAutoCodable = ExAutoEncodable & ExAutoDecodable


// MARK: -

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

public protocol ExDecodable: Decodable {
    init()
}
extension ExDecodable where Self: ExCodingKeyMap, Self.Root == Self {
    public init(from decoder: Decoder) throws {
        self.init(with: decoder, using: Self.keyMapping)
    }
    public init(with decoder: Decoder, using keyMapping: [KeyMap<Self>]) {
        self.init()
        decode(from: decoder, with: keyMapping)
    }
}
/// class 类型得用final修饰才能调用到这里来
extension ExDecodable where Self: ExCodingKeyMap, Self.Root == Self, Self: AnyObject {
    public init(from decoder: Decoder) throws {
        print("my init(from:)")
        self.init(with: decoder, using: Self.keyMapping)
    }
    public init(with decoder: Decoder, using keyMapping: [KeyMap<Self>]) {
        self.init()
        decode(from: decoder, with: keyMapping)
    }
}

public typealias ExCodable = ExDecodable & Encodable

/*
 这样定义的话 class 类型 不用final修饰也可以
 public protocol ExDecodable: Decodable, ExCodingKeyMap where Self.Root == Self {
     init()
 }
 extension ExDecodable {
     public init(from decoder: Decoder) throws {
         self.init(with: decoder, using: Self.keyMapping)
     }
     public init(with decoder: Decoder, using keyMapping: [KeyMap<Self>]) {
         self.init()
         decode(from: decoder, with: keyMapping)
     }
 }
 */

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
 

fileprivate extension String {
    var keyComponent: (String, Int?) {
        let str = trimmed
        guard str.hasSuffix("]") else { return (str, nil) }
        guard let end = str.index(str.endIndex, offsetBy: -2, limitedBy: str.startIndex) else { return (str, nil) }
        var index = end
        while index != str.startIndex {
            let c = str[index]
            if c == "[" { break }
            guard c.isNumber else { return (str, nil) }
            index = str.index(before: index)
        }
        if index == str.startIndex { return (str, nil) }
        if index == end { return (String(str[..<index]), 0) }
        guard let num = Int(str[str.index(after: index)...end]) else { return (str, nil) }
        return (String(str[..<index]), num)
    }
}
// MARK: -
fileprivate typealias ExKeyedEncodingContainer = KeyedEncodingContainer<ExCodingKey>

public extension Encoder {
    func encode<T: Encodable>(_ value: T, for stringKey: String) throws {
        if case Optional<Any>.none = (value as Any) {
            return
        }
        var keys = stringKey.split(separator: ".")
        var container = container(keyedBy: ExCodingKey.self)

        guard keys.count > 1 else {
            try ex_encode(value, forSingleKey: String(keys[0]), using: container)
            return
        }
        let lastKey = keys.removeLast()
        
        for key in keys {
//            container = container.nestedContainer(keyedBy: ExCodingKey.self, forKey: key)
        }
//        try container.encode(value, forKey: String(lastKey), )
        try ex_encode(value, forSingleKey: String(lastKey), using: container)
    }
    
    private func ex_encode<T: Encodable>(_ value: T, forSingleKey key: String, using container: Any) throws {
        let info = key.keyComponent
        let newKey = ExCodingKey(info.0)
        if var keyedCon = container as? ExKeyedEncodingContainer {
            if var num = info.1 {
                var con = keyedCon.nestedUnkeyedContainer(forKey: newKey)
                while num > 0 {
                    if value is (any ExpressibleByIntegerLiteral) {
                        try con.encode(0)
                    } else if value is (any ExpressibleByBooleanLiteral) {
                        try con.encode(false)
                    } else if value is (any ExpressibleByStringLiteral) {
                        try con.encode("")
                    } else if value is (any ExpressibleByFloatLiteral) {
                        try con.encode(0.0)
                    } else if value is (any ExpressibleByArrayLiteral) {
                        try con.encode(Array<Int>())
                    } else {
                        let val: [String: String] = [:]
                        try con.encode(val)
                    }
                    num -= 1
                }
                try con.encode(value)
            } else {
                try keyedCon.encode(value, forKey: newKey)
            }
        } else if var con = container as? UnkeyedEncodingContainer {
//            var keyedCon = con.nestedUnkeyedContainer(forKey: newKey)
//            try keyedCon.encode(value, forKey: newKey)
//            var keyedCon = con.nestedContainer(keyedBy: ExCodingKey.self, forKey: newKey)
            var keyedCon = con.nestedContainer(keyedBy: ExCodingKey.self)
            keyedCon = keyedCon.nestedContainer(keyedBy: ExCodingKey.self, forKey: newKey)
            if let num = info.1 {
//                con.nestedUnkeyedContainer(forKey: newKey)
//                con = con.nestedUnkeyedContainer()
                keyedCon.nestedUnkeyedContainer(forKey: <#T##KeyedEncodingContainer<ExCodingKey>.Key#>)
            } else {
                var keyedCon = con.nestedContainer(keyedBy: ExCodingKey.self, forKey: newKey)
//                try con.encode(value, forKey: newKey)
                
            }
        }
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
        let container = try container(keyedBy: ExCodingKey.self)
        for key in keys {
            if let val = container.tryNestedDecode(type, forKey: key) {
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
        var container = try? nestedContainer(keyedBy: K.self, forKey: .init(keys.removeFirst()))
        let lastKey = keys.removeLast()
        for key in keys {
            container = try? container?.nestedContainer(keyedBy: K.self, forKey: .init(key))
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
 
