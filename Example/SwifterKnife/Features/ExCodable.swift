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

public protocol CodingKeyMap {
    associatedtype Root = Self where Root: CodingKeyMap
    static var keyMapping: [KeyMap<Root>] { get }
}
 
public extension Encodable where Self: CodingKeyMap {
    func encode(to encoder: Encoder, with keyMapping: [KeyMap<Self>], nonnull: Bool = false, throws: Bool = false) throws {
        try keyMapping.forEach { try $0.encode(self, encoder, nonnull, `throws`) }
    }
}
public extension Encodable where Self: CodingKeyMap, Self.Root == Self {
    func encode(to encoder: Encoder) throws {
        try encode(to: encoder, with: Self.keyMapping)
    }
}
public extension Decodable where Self: CodingKeyMap {
    mutating func decode(from decoder: Decoder, with keyMapping: [KeyMap<Self>], nonnull: Bool = false, throws: Bool = false) throws {
        try keyMapping.forEach { try $0.decode?(&self, decoder, nonnull, `throws`) }
    }
    func decodeReference(from decoder: Decoder, with keyMapping: [KeyMap<Self>], nonnull: Bool = false, throws: Bool = false) throws {
        try keyMapping.forEach { try $0.decodeReference?(self, decoder, nonnull, `throws`) }
    }
}
//public extension ExCodable where Root == Self {
//    func encode(to encoder: Encoder) throws {
//        try encode(to: encoder, with: Self.keyMapping)
//    }
////    init(from decoder: Decoder) throws {
////        self.init()
////        try decode(from: decoder, with: Self.keyMapping)
////    }
//}

// MARK: -

public final class KeyMap<Root> {
    fileprivate typealias EncodeClosure = (_ root: Root, _ encoder: Encoder, _ nonnullAll: Bool, _ throwsAll: Bool) throws -> Void
    fileprivate let encode: EncodeClosure
    
    fileprivate typealias DecodeValClosure = (_ root: inout Root, _ decoder: Decoder, _ nonnullAll: Bool, _ throwsAll: Bool) throws -> Void
    fileprivate let decode: DecodeValClosure?
    
    fileprivate typealias DecodeRefClosure = (_ root: Root, _ decoder: Decoder, _ nonnullAll: Bool, _ throwsAll: Bool) throws -> Void
    fileprivate let decodeReference: DecodeRefClosure?
    
    fileprivate init(encode: @escaping EncodeClosure,
                     decode: DecodeValClosure?,
                     decodeReference: DecodeRefClosure?) {
        (self.encode, self.decode, self.decodeReference) = (encode, decode, decodeReference)
    }
}

public extension KeyMap {
    convenience init<Value: Codable>(_ keyPath: WritableKeyPath<Root, Value>, to codingKeys: String..., nonnull: Bool? = nil, throws: Bool? = nil) {
        self.init(encode: { (root, encoder, nonnullAll, throwsAll) in
            try encoder.encode(root[keyPath: keyPath], for: codingKeys[0], nonnull: nonnull ?? nonnullAll, throws: `throws` ?? throwsAll)
        }, decode: { (root, decoder, nonnullAll, throwsAll) in
            if let value: Value = try decoder.decode(codingKeys, nonnull: nonnull ?? nonnullAll, throws: `throws` ?? throwsAll) {
                root[keyPath: keyPath] = value
            }
        }, decodeReference: nil)
    }
    convenience init<Value: Codable, Key: CodingKey>(_ keyPath: WritableKeyPath<Root, Value>, to codingKeys: Key..., nonnull: Bool? = nil, throws: Bool? = nil) {
        self.init(encode: { (root, encoder, nonnullAll, throwsAll) in
            try encoder.encode(root[keyPath: keyPath], for: codingKeys[0], nonnull: nonnull ?? nonnullAll, throws: `throws` ?? throwsAll)
        }, decode: { (root, decoder, nonnullAll, throwsAll) in
            if let value: Value = try decoder.decode(codingKeys, nonnull: nonnull ?? nonnullAll, throws: `throws` ?? throwsAll) {
                root[keyPath: keyPath] = value
            }
        }, decodeReference: nil)
    }
    convenience init<Value: Codable>(ref keyPath: ReferenceWritableKeyPath<Root, Value>, to codingKeys: String..., nonnull: Bool? = nil, throws: Bool? = nil) {
        self.init(encode: { (root, encoder, nonnullAll, throwsAll) in
            try encoder.encode(root[keyPath: keyPath], for: codingKeys[0], nonnull: nonnull ?? nonnullAll, throws: `throws` ?? throwsAll)
        }, decode: nil, decodeReference: { (root, decoder, nonnullAll, throwsAll) in
            if let value: Value = try decoder.decode(codingKeys, nonnull: nonnull ?? nonnullAll, throws: `throws` ?? throwsAll) {
                root[keyPath: keyPath] = value
            }
        })
    }
    convenience init<Value: Codable, Key: CodingKey>(ref keyPath: ReferenceWritableKeyPath<Root, Value>, to codingKeys: Key..., nonnull: Bool? = nil, throws: Bool? = nil) {
        self.init(encode: { (root, encoder, nonnullAll, throwsAll) in
            try encoder.encode(root[keyPath: keyPath], for: codingKeys[0], nonnull: nonnull ?? nonnullAll, throws: `throws` ?? throwsAll)
        }, decode: nil, decodeReference: { (root, decoder, nonnullAll, throwsAll) in
            if let value: Value = try decoder.decode(codingKeys, nonnull: nonnull ?? nonnullAll, throws: `throws` ?? throwsAll) {
                root[keyPath: keyPath] = value
            }
        })
    }
}

// MARK: - subscript
// abortIfNull nonnull: Bool = false, abortOnError throws: Bool = false
public extension Encoder {
    subscript<T: Encodable>(stringKey: String) -> T? {
        get { return nil }
        nonmutating set { encode(newValue, for: stringKey) }
    }
    subscript<T: Encodable, K: CodingKey>(codingKey: K) -> T? {
        get { return nil }
        nonmutating set { encode(newValue, for: codingKey) }
    }
}
// abortIfNull nonnull: Bool = false, abortOnError throws: Bool = false
public extension Decoder {
    subscript<T: Decodable>(stringKeys: [String]) -> T? {
        return decode(stringKeys, as: T.self)
    }
    subscript<T: Decodable>(stringKeys: String...) -> T? {
        return decode(stringKeys, as: T.self)
    }
    subscript<T: Decodable, K: CodingKey>(codingKeys: [K]) -> T? {
        return decode(codingKeys, as: T.self)
    }
    subscript<T: Decodable, K: CodingKey>(codingKeys: K...) -> T? {
        return decode(codingKeys, as: T.self)
    }
}

// MARK: -

public extension Encoder {
    
    func encodeNonnullThrows<T: Encodable>(_ value: T, for stringKey: String) throws {
        try encode(value, for: stringKey, nonnull: true, throws: true)
    }
    func encodeThrows<T: Encodable>(_ value: T?, for stringKey: String) throws {
        try encode(value, for: stringKey, nonnull: false, throws: true)
    }
    func encode<T: Encodable>(_ value: T?, for stringKey: String) {
        try? encode(value, for: stringKey, nonnull: false, throws: false)
    }
    fileprivate func encode<T: Encodable>(_ value: T?, for stringKey: String, nonnull: Bool = false, throws: Bool = false) throws {
        
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
    
    func encodeNonnullThrows<T: Encodable, K: CodingKey>(_ value: T, for codingKey: K) throws {
        try encode(value, for: codingKey, nonnull: true, throws: true)
    }
    func encodeThrows<T: Encodable, K: CodingKey>(_ value: T?, for codingKey: K) throws {
        try encode(value, for: codingKey, nonnull: false, throws: true)
    }
    func encode<T: Encodable, K: CodingKey>(_ value: T?, for codingKey: K) {
        try? encode(value, for: codingKey, nonnull: false, throws: false)
    }
    fileprivate func encode<T: Encodable, K: CodingKey>(_ value: T?, for codingKey: K, nonnull: Bool = false, throws: Bool = false) throws {
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

fileprivate struct ExCodingKey: CodingKey {
    let stringValue: String
    let intValue: Int?
    init(_ stringValue: String) {
        (self.stringValue, self.intValue) = (stringValue, nil)
    }
    init(_ stringValue: Substring) {
        self.init(String(stringValue))
    }
    init?(stringValue: String) {
        self.init(stringValue)
    }
    init(_ intValue: Int) {
        (self.intValue, self.stringValue) = (intValue, String(intValue))
    }
    init?(intValue: Int) {
        self.init(intValue)
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
        
        if firstError != nil && (`throws` || nonnull) { throw firstError! }
        return nil
    }
    
    private func nestedContainer(with keys: [ExCodingKey]) -> Self? {
        var container: Self? = self
        for key in keys {
            container = try? container?.nestedContainer(keyedBy: Self.Key, forKey: key as! Self.Key)
            if container == nil { return nil }
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
        
        if firstError != nil && (`throws` || nonnull) { throw firstError! }
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
 
