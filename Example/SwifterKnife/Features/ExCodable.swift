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
    init()
    associatedtype Root = Self where Root: ExCodingKeyMap
    static var keyMapping: [KeyMap<Root>] { get }
}
 
public extension Encodable where Self: ExCodingKeyMap {
    func encode(to encoder: Encoder, with keyMapping: [KeyMap<Self>], nonnull: Bool = false, throws: Bool = false) throws {
        try keyMapping.forEach { try $0.encode?(self, encoder, nonnull, `throws`) }
    }
}
public extension Encodable where Self: ExCodingKeyMap, Self.Root == Self {
    func encode(to encoder: Encoder) throws {
        try encode(to: encoder, with: Self.keyMapping)
    }
}
public extension Decodable where Self: ExCodingKeyMap, Self.Root == Self {
    init(from decoder: Decoder) throws {
        self.init()
        try decode(from: decoder, with: Self.keyMapping)
    }
    mutating func decode(from decoder: Decoder, with keyMapping: [KeyMap<Self>], nonnull: Bool = false, throws: Bool = false) throws {
        try keyMapping.forEach { try $0.decode?(&self, decoder, nonnull, `throws`) }
    }
}
public extension Decodable where Self: ExCodingKeyMap, Self: AnyObject {
    func decode(from decoder: Decoder, with keyMapping: [KeyMap<Self>], nonnull: Bool = false, throws: Bool = false) throws {
        var this = self
        try keyMapping.forEach { try $0.decode?(&this, decoder, nonnull, `throws`) }
    }
}

// MARK: -
public final class KeyMap<Root> {
    fileprivate typealias EncodeClosure = (_ root: Root, _ encoder: Encoder, _ nonnullAll: Bool, _ throwsAll: Bool) throws -> Void
    fileprivate var encode: EncodeClosure?
    
    fileprivate typealias DecodeValClosure = (_ root: inout Root, _ decoder: Decoder, _ nonnullAll: Bool, _ throwsAll: Bool) throws -> Void
    fileprivate var decode: DecodeValClosure?
    
    fileprivate init(encode: EncodeClosure?,
                     decode: DecodeValClosure?) {
        (self.encode, self.decode) = (encode, decode)
    }
    fileprivate init() {  }
    
    fileprivate func setEncode<Value: Encodable>(_ keyPath: WritableKeyPath<Root, Value>, to codingKeys: [String], nonnull: Bool? = nil, throws: Bool? = nil) {
        self.encode = { (root, encoder, nonnullAll, throwsAll) in
            try encoder.encode(root[keyPath: keyPath], for: codingKeys[0], nonnull: nonnull ?? nonnullAll, throws: `throws` ?? throwsAll)
        }
    }
    
    fileprivate func setDecode<Value: Decodable>(_ keyPath: WritableKeyPath<Root, Value>, to codingKeys: [String], nonnull: Bool? = nil, throws: Bool? = nil) {
        self.decode = { (root, decoder, nonnullAll, throwsAll) in
            if Value.self is any ExCodingKeyMap.Type ||
                Value.self is [any ExCodingKeyMap].Type {
                let deco = try decoder.subDecoder(forKey: codingKeys[0])
                root[keyPath: keyPath] = try Value(from: deco)
                return
            } 
            if let value: Value = try decoder.decode(codingKeys, nonnull: nonnull ?? nonnullAll, throws: `throws` ?? throwsAll) {
                root[keyPath: keyPath] = value
            }
        }
    }
}
 
/// 嵌套模型
public extension KeyMap {
    convenience init<Value: Encodable & ExCodingKeyMap>(model keyPath: WritableKeyPath<Root, Value>, to codingKey: String, nonnull: Bool? = nil, throws: Bool? = nil) {
        self.init()
        setEncode(keyPath, to: [codingKey], nonnull: nonnull, throws: `throws`)
    }
    convenience init<Value: Decodable & ExCodingKeyMap>(model keyPath: WritableKeyPath<Root, Value>, to codingKey: String, nonnull: Bool? = nil, throws: Bool? = nil) {
        self.init()
        decode = { (root, decoder, nonnullAll, throwsAll) in
            let deco = try decoder.subDecoder(forKey: codingKey)
            root[keyPath: keyPath] = try Value(from: deco)
        }
    }
    convenience init<Value: Codable & ExCodingKeyMap>(model keyPath: WritableKeyPath<Root, Value>, to codingKey: String, nonnull: Bool? = nil, throws: Bool? = nil) {
        self.init()
        setEncode(keyPath, to: [codingKey], nonnull: nonnull, throws: `throws`)
        decode = { (root, decoder, nonnullAll, throwsAll) in
            let deco = try decoder.subDecoder(forKey: codingKey)
            root[keyPath: keyPath] = try Value(from: deco)
        }
    }
}

/// 嵌套模型数组
public extension KeyMap {
    convenience init<Value: Encodable & ExCodingKeyMap>(models keyPath: WritableKeyPath<Root, [Value]>, to codingKey: String, nonnull: Bool? = nil, throws: Bool? = nil) {
        self.init()
        setEncode(keyPath, to: [codingKey], nonnull: nonnull, throws: `throws`)
    }
    
    convenience init<Value: Decodable & ExCodingKeyMap>(models keyPath: WritableKeyPath<Root, [Value]>, to codingKey: String, nonnull: Bool? = nil, throws: Bool? = nil) {
        self.init()
        decode = { (root, decoder, nonnullAll, throwsAll) in
            let deco = try decoder.subDecoder(forKey: codingKey)
            root[keyPath: keyPath] = try [Value](from: deco)
        }
    }
    convenience init<Value: Codable & ExCodingKeyMap>(models keyPath: WritableKeyPath<Root, [Value]>, to codingKey: String, nonnull: Bool? = nil, throws: Bool? = nil) {
        self.init()
        setEncode(keyPath, to: [codingKey], nonnull: nonnull, throws: `throws`)
        decode = { (root, decoder, nonnullAll, throwsAll) in
            let deco = try decoder.subDecoder(forKey: codingKey)
            root[keyPath: keyPath] = try [Value](from: deco)
        }
    }
}

public extension KeyMap {
    convenience init<Value: Decodable>(_ keyPath: WritableKeyPath<Root, Value>, to codingKeys: String..., nonnull: Bool? = nil, throws: Bool? = nil) {
        self.init()
        setDecode(keyPath, to: codingKeys, nonnull: nonnull, throws: `throws`)
    }
    convenience init<Value: Encodable>(_ keyPath: WritableKeyPath<Root, Value>, to codingKeys: String..., nonnull: Bool? = nil, throws: Bool? = nil) {
        self.init()
        setEncode(keyPath, to: codingKeys, nonnull: nonnull, throws: `throws`)
    }
    
    convenience init<Value: Codable>(_ keyPath: WritableKeyPath<Root, Value>, to codingKeys: String..., nonnull: Bool? = nil, throws: Bool? = nil) {
        self.init()
        setEncode(keyPath, to: codingKeys, nonnull: nonnull, throws: `throws`)
        setDecode(keyPath, to: codingKeys, nonnull: nonnull, throws: `throws`)
    }
}
 

// MARK: -

public extension Encoder {
    
    func encode<T: Encodable>(_ value: T?, for stringKey: String, nonnull: Bool = false, throws: Bool = false) throws {
        
        let dot: Character = "."
        guard stringKey.contains(dot), stringKey.count > 1 else {
            try encode(value, for: ExCodingKey(stringKey), nonnull: nonnull, throws: `throws`)
            return
        }
        
        let keys = stringKey.split(separator: dot).map { ExCodingKey($0) }
        var container = container(keyedBy: ExCodingKey.self)
        for key in keys.dropLast() {
            container = container.nestedContainer(keyedBy: ExCodingKey.self, forKey: key)
        }
        
        let codingKey = keys.last!
        do {
            if nonnull { try container.encode(value, forKey: codingKey) }
            else { try container.encodeIfPresent(value, forKey: codingKey) }
        }
        catch { if `throws` || nonnull { throw error } }
    }
    
    func encode<T: Encodable, K: CodingKey>(_ value: T?, for codingKey: K, nonnull: Bool = false, throws: Bool = false) throws {
        var container = container(keyedBy: K.self)
        do {
            if nonnull { try container.encode(value, forKey: codingKey) }
            else { try container.encodeIfPresent(value, forKey: codingKey) }
        }
        catch { if `throws` || nonnull { throw error } }
    }
}

public extension Decoder {
    
    func decodeNonnullThrows<T: Decodable>(_ stringKeys: String..., as type: T.Type = T.self) throws -> T {
        return try decodeNonnullThrows(stringKeys, as: type)
    }
    func decodeNonnullThrows<T: Decodable>(_ stringKeys: [String], as type: T.Type = T.self) throws -> T {
        return try decode(stringKeys, as: type, nonnull: true, throws: true)!
    }
    func decodeThrows<T: Decodable>(_ stringKeys: String..., as type: T.Type = T.self) throws -> T? {
        return try decodeThrows(stringKeys, as: type)
    }
    func decodeThrows<T: Decodable>(_ stringKeys: [String], as type: T.Type = T.self) throws -> T? {
        return try decode(stringKeys, as: type, nonnull: false, throws: true)
    }
    func decode<T: Decodable>(_ stringKeys: String..., as type: T.Type = T.self) -> T? {
        return decode(stringKeys, as: type)
    }
    func decode<T: Decodable>(_ stringKeys: [String], as type: T.Type = T.self) -> T? {
        return try? decode(stringKeys, as: type, nonnull: false, throws: false)
    }
    fileprivate func decode<T: Decodable>(_ stringKeys: [String], as type: T.Type = T.self, nonnull: Bool = false, throws: Bool = false) throws -> T? {
        return try decode(stringKeys.map { ExCodingKey($0) }, as: type, nonnull: nonnull, throws: `throws`)
    }
    
    func decodeNonnullThrows<T: Decodable, K: CodingKey>(_ codingKeys: K..., as type: T.Type = T.self) throws -> T {
        return try decodeNonnullThrows(codingKeys, as: type)
    }
    func decodeNonnullThrows<T: Decodable, K: CodingKey>(_ codingKeys: [K], as type: T.Type = T.self) throws -> T {
        return try decode(codingKeys, as: type, nonnull: true, throws: true)!
    }
    func decodeThrows<T: Decodable, K: CodingKey>(_ codingKeys: K..., as type: T.Type = T.self) throws -> T? {
        return try decodeThrows(codingKeys, as: type)
    }
    func decodeThrows<T: Decodable, K: CodingKey>(_ codingKeys: [K], as type: T.Type = T.self) throws -> T? {
        return try decode(codingKeys, as: type, nonnull: false, throws: true)
    }
    func decode<T: Decodable, K: CodingKey>(_ codingKeys: K..., as type: T.Type = T.self) -> T? {
        return decode(codingKeys, as: type)
    }
    func decode<T: Decodable, K: CodingKey>(_ codingKeys: [K], as type: T.Type = T.self) -> T? {
        return try? decode(codingKeys, as: type, nonnull: false, throws: false)
    }
    fileprivate func decode<T: Decodable, K: CodingKey>(_ codingKeys: [K], as type: T.Type = T.self, nonnull: Bool = false, throws: Bool = false) throws -> T? {
        do {
            let container = try container(keyedBy: K.self)
            return try container.decodeForAlternativeKeys(codingKeys, as: type, nonnull: nonnull, throws: `throws`)
        }
        catch { if `throws` || nonnull { throw error } }
        return nil
    }
}

public struct ExCodingKey: CodingKey {
    public let stringValue: String
    public let intValue: Int?
    
    public init(_ stringValue: String) {
        (self.stringValue, self.intValue) = (stringValue, nil)
    }
    public init(_ stringValue: Substring) {
        self.init(String(stringValue))
    }
    public init?(stringValue: String) {
        self.init(stringValue)
    }
    public init(_ intValue: Int) {
        (self.intValue, self.stringValue) = (intValue, String(intValue))
    }
    public init?(intValue: Int) {
        self.init(intValue)
    }
    static let `super` = ExCodingKey("super")
}
extension ExCodingKey: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(value)
    }
}
extension ExCodingKey: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) {
        self.init(value)
    }
}

public extension Decoder {
    func nestedContainer(forKey key: String) throws -> KeyedDecodingContainer<ExCodingKey> {
        try container(keyedBy: ExCodingKey.self).nestedContainer(forKey: key)
    }
    
    fileprivate func subDecoder(forKey key: String) throws -> Decoder {
        var container = try container(keyedBy: ExCodingKey.self)
        var keys = key.split(separator: ".")
        guard keys.count > 1 else {
            return try container.superDecoder(forKey: ExCodingKey(key))
        }
        let last = keys.popLast()!
        for key in keys {
            container = try container.nestedContainer(keyedBy: ExCodingKey.self, forKey: ExCodingKey(key))
        }
        return try container.superDecoder(forKey: ExCodingKey(last))
    }
}
public extension KeyedDecodingContainer where Key == ExCodingKey {
    func nestedContainer(forKey key: String) throws -> Self {
        var container = self
        let keys = key.split(separator: ".")
        guard keys.count > 1 else { return container }
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

// MARK: - alternative-keys + nested-keys + type-conversion

fileprivate extension KeyedDecodingContainer {
    
    func decodeForAlternativeKeys<T: Decodable>(_ codingKeys: [Self.Key], as type: T.Type = T.self, nonnull: Bool, throws: Bool) throws -> T? {
        
        var firstError: Error?
        do {
            let codingKey = codingKeys[0]
            if let value = try decodeForNestedKeys(codingKey, as: type, nonnull: nonnull, throws: `throws`) {
                return value
            }
        }
        catch { firstError = error }
        
        let leftKeys = Array(codingKeys.dropFirst())
        guard !leftKeys.isEmpty else {
            if (`throws` || nonnull), let err = firstError { throw err }
            return nil
        }
        return try? decodeForAlternativeKeys(leftKeys, as: type, nonnull: nonnull, throws: `throws`)
    }
    
    func decodeForNestedKeys<T: Decodable>(_ codingKey: Self.Key, as type: T.Type = T.self, nonnull: Bool, throws: Bool) throws -> T? {
        
        var firstError: Error?
        do {
            if let value = try decodeForValue(codingKey, as: type, nonnull: nonnull, throws: `throws`) {
                return value
            }
        }
        catch { firstError = error }
        
        let dot: Character = "."
        if let exCodingKey = codingKey as? ExCodingKey,
           exCodingKey.intValue == nil,
           exCodingKey.stringValue.contains(dot) {
            let keys = exCodingKey.stringValue.split(separator: dot).map { ExCodingKey($0) }
            if !keys.isEmpty,
               let container = nestedContainer(with: keys.dropLast()),
               let codingKey = keys.last,
               let value = try? container.decodeForNestedKeys(codingKey as! Self.Key, as: type, nonnull: nonnull, throws: `throws`) {
                return value
            }
        }
        
        if (`throws` || nonnull), let err = firstError { throw err }
        return nil
    }
    
    private func nestedContainer(with keys: [ExCodingKey]) -> Self? {
        var container: Self = self
        for key in keys {
            guard let exKey = key as? Self.Key else { return nil }
            guard let nestCon = try? container.nestedContainer(keyedBy: Self.Key, forKey: exKey) else { return nil }
            container = nestCon
        }
        return container
    }
    
    func decodeForValue<T: Decodable>(_ codingKey: Self.Key, as type: T.Type = T.self, nonnull: Bool, throws: Bool) throws -> T? {
        
        var firstError: Error?
        do {
            if let value = nonnull
                ? (`throws` ? try decode(type, forKey: codingKey) : try? decode(type, forKey: codingKey))
                : (`throws` ? try decodeIfPresent(type, forKey: codingKey) : try? decodeIfPresent(type, forKey: codingKey)) {
                return value
            }
        }
        catch { firstError = error }
        
        if contains(codingKey),
           let value = decodeForTypeConversion(codingKey, as: type) {
            return value
        }
        
        if (`throws` || nonnull), let err = firstError { throw err }
        return nil
    }
    
    func decodeForTypeConversion<T: Decodable>(_ codingKey: Self.Key, as type: T.Type = T.self) -> T? {
        if type is Bool.Type {
            if let int = try? decodeIfPresent(Int.self, forKey: codingKey) {
                return (int != 0) as? T
            }
            else if let string = try? decodeIfPresent(String.self, forKey: codingKey) {
                switch string.lowercased() {
                case "true", "t", "yes", "y":
                    return true as? T
                case "false", "f", "no", "n", "":
                    return false as? T
                default:
                    if let int = Int(string) { return (int != 0) as? T }
                    else if let double = Double(string) { return (Int(double) != 0) as? T }
                }
            }
        }
        
        else if type is Int.Type {
            if let bool = try? decodeIfPresent(Bool.self,   forKey: codingKey) { return Int(bool ? 1 : 0) as? T }
            else if let double = try? decodeIfPresent(Double.self, forKey: codingKey) { return Int(double) as? T } // include Float
            else if let string = try? decodeIfPresent(String.self, forKey: codingKey), let value = Int(string) { return value as? T }
        }
        else if type is Int8.Type {
            if let bool = try? decodeIfPresent(Bool.self,   forKey: codingKey) { return Int8(bool ? 1 : 0) as? T }
            else if let double = try? decodeIfPresent(Double.self, forKey: codingKey) { return Int8(double) as? T } // include Float
            else if let string = try? decodeIfPresent(String.self, forKey: codingKey), let value = Int8(string) { return value as? T }
        }
        else if type is Int16.Type {
            if let bool = try? decodeIfPresent(Bool.self,   forKey: codingKey) { return Int16(bool ? 1 : 0) as? T }
            else if let double = try? decodeIfPresent(Double.self, forKey: codingKey) { return Int16(double) as? T } // include Float
            else if let string = try? decodeIfPresent(String.self, forKey: codingKey), let value = Int16(string) { return value as? T }
        }
        else if type is Int32.Type {
            if let bool = try? decodeIfPresent(Bool.self,   forKey: codingKey) { return Int32(bool ? 1 : 0) as? T }
            else if let double = try? decodeIfPresent(Double.self, forKey: codingKey) { return Int32(double) as? T } // include Float
            else if let string = try? decodeIfPresent(String.self, forKey: codingKey), let value = Int32(string) { return value as? T }
        }
        else if type is Int64.Type {
            if let bool = try? decodeIfPresent(Bool.self,   forKey: codingKey) { return Int64(bool ? 1 : 0) as? T }
            else if let double = try? decodeIfPresent(Double.self, forKey: codingKey) { return Int64(double) as? T } // include Float
            else if let string = try? decodeIfPresent(String.self, forKey: codingKey), let value = Int64(string) { return value as? T }
        }
        else if type is UInt.Type {
            if let bool = try? decodeIfPresent(Bool.self,   forKey: codingKey) { return UInt(bool ? 1 : 0) as? T }
            else if let string = try? decodeIfPresent(String.self, forKey: codingKey), let value = UInt(string) { return value as? T }
        }
        else if type is UInt8.Type {
            if let bool = try? decodeIfPresent(Bool.self,   forKey: codingKey) { return UInt8(bool ? 1 : 0) as? T }
            else if let string = try? decodeIfPresent(String.self, forKey: codingKey), let value = UInt8(string) { return value as? T }
        }
        else if type is UInt16.Type {
            if let bool = try? decodeIfPresent(Bool.self,   forKey: codingKey) { return UInt16(bool ? 1 : 0) as? T }
            else if let string = try? decodeIfPresent(String.self, forKey: codingKey), let value = UInt16(string) { return value as? T }
        }
        else if type is UInt32.Type {
            if let bool = try? decodeIfPresent(Bool.self,   forKey: codingKey) { return UInt32(bool ? 1 : 0) as? T }
            else if let string = try? decodeIfPresent(String.self, forKey: codingKey), let value = UInt32(string) { return value as? T }
        }
        else if type is UInt64.Type {
            if let bool = try? decodeIfPresent(Bool.self,   forKey: codingKey) { return UInt64(bool ? 1 : 0) as? T }
            else if let string = try? decodeIfPresent(String.self, forKey: codingKey), let value = UInt64(string) { return value as? T }
        }
        
        else if type is Double.Type {
            if let int64 = try? decodeIfPresent(Int64.self,  forKey: codingKey) { return Double(int64) as? T } // include all Int types
            else if let string = try? decodeIfPresent(String.self, forKey: codingKey), let value = Double(string) { return value as? T }
        }
        else if type is CGFloat.Type {
            if let int64 = try? decodeIfPresent(Int64.self,  forKey: codingKey) { return CGFloat(int64) as? T } // include all Int types
            else if let string = try? decodeIfPresent(String.self, forKey: codingKey), let value = Double(string) { return CGFloat(value) as? T }
        }
        else if type is Float.Type {
            if let int64 = try? decodeIfPresent(Int64.self,  forKey: codingKey) { return Float(int64) as? T } // include all Int types
            else if let string = try? decodeIfPresent(String.self, forKey: codingKey), let value = Float(string) { return value as? T }
        }
        
        else if type is String.Type {
            if let bool = try? decodeIfPresent(Bool.self,   forKey: codingKey) { return String(describing: bool) as? T }
            else if let int64  = try? decodeIfPresent(Int64.self,  forKey: codingKey) { return String(describing: int64) as? T } // include all Int types
            else if let double = try? decodeIfPresent(Double.self, forKey: codingKey) { return String(describing: double) as? T } // include Float
        }
        
        for conversion in _decodingTypeConverters {
            if let value = try? conversion.decode(self, codingKey: codingKey, as: type) {
                return value
            }
        }
        
        if let custom = self as? ExCodableDecodingTypeConverter,
           let value = try? custom.decode(self, codingKey: codingKey, as: type) {
            return value
        }
        
        return nil
    }
}

private var _decodingTypeConverters: [ExCodableDecodingTypeConverter] = []
public func excodable_register(_ decodingTypeConverter: ExCodableDecodingTypeConverter) {
    _decodingTypeConverters.append(decodingTypeConverter)
}
public protocol ExCodableDecodingTypeConverter {
    func decode<T: Decodable, K: CodingKey>(_ container: KeyedDecodingContainer<K>, codingKey: K, as type: T.Type) throws -> T?
}

//public typealias Modelable = ExCodable & DataCodable
 
