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
 *  swift codable json model type-inference
 *  key-mapping keypath codingkey subscript
 *  alternative-keys nested-keys type-conversion
 *
 *  - seealso: [Usage](https://github.com/iwill/ExCodable#usage) from GitGub
 *  - seealso: `ExCodableTests.swift` form the source code
 */
public protocol ExCodable: Codable {
    associatedtype Root = Self where Root: ExCodable
    static var keyMapping: [KeyMap<Root>] { get }
}

public extension ExCodable {
    func encode(to encoder: Encoder, with keyMapping: [KeyMap<Self>], nonnull: Bool = false, throws: Bool = false) throws {
        try keyMapping.forEach { try $0.encode(self, encoder, nonnull, `throws`) }
    }
    mutating func decode(from decoder: Decoder, with keyMapping: [KeyMap<Self>], nonnull: Bool = false, throws: Bool = false) throws {
        try keyMapping.forEach { try $0.decode?(&self, decoder, nonnull, `throws`) }
    }
    func decodeReference(from decoder: Decoder, with keyMapping: [KeyMap<Self>], nonnull: Bool = false, throws: Bool = false) throws {
        try keyMapping.forEach { try $0.decodeReference?(self, decoder, nonnull, `throws`) }
    }
}
public extension ExCodable where Root == Self {
    func encode(to encoder: Encoder) throws {
        try encode(to: encoder, with: Self.keyMapping)
    }
}

// MARK: -

public final class KeyMap<Root: Codable> {
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
    convenience init<Value: Codable>(_ keyPath: WritableKeyPath<Root, Value>, to codingKeys: String ..., nonnull: Bool? = nil, throws: Bool? = nil) {
        self.init(encode: { (root, encoder, nonnullAll, throwsAll) in
            try encoder.encode(root[keyPath: keyPath], for: codingKeys[0], nonnull: nonnull ?? nonnullAll, throws: `throws` ?? throwsAll)
        }, decode: { (root, decoder, nonnullAll, throwsAll) in
            if let value: Value = try decoder.decode(codingKeys, nonnull: nonnull ?? nonnullAll, throws: `throws` ?? throwsAll) {
                root[keyPath: keyPath] = value
            }
        }, decodeReference: nil)
    }
    convenience init<Value: Codable, Key: CodingKey>(_ keyPath: WritableKeyPath<Root, Value>, to codingKeys: Key ..., nonnull: Bool? = nil, throws: Bool? = nil) {
        self.init(encode: { (root, encoder, nonnullAll, throwsAll) in
            try encoder.encode(root[keyPath: keyPath], for: codingKeys.first!, nonnull: nonnull ?? nonnullAll, throws: `throws` ?? throwsAll)
        }, decode: { (root, decoder, nonnullAll, throwsAll) in
            if let value: Value = try decoder.decode(codingKeys, nonnull: nonnull ?? nonnullAll, throws: `throws` ?? throwsAll) {
                root[keyPath: keyPath] = value
            }
        }, decodeReference: nil)
    }
    convenience init<Value: Codable>(ref keyPath: ReferenceWritableKeyPath<Root, Value>, to codingKeys: String ..., nonnull: Bool? = nil, throws: Bool? = nil) {
        self.init(encode: { (root, encoder, nonnullAll, throwsAll) in
            try encoder.encode(root[keyPath: keyPath], for: codingKeys.first!, nonnull: nonnull ?? nonnullAll, throws: `throws` ?? throwsAll)
        }, decode: nil, decodeReference: { (root, decoder, nonnullAll, throwsAll) in
            if let value: Value = try decoder.decode(codingKeys, nonnull: nonnull ?? nonnullAll, throws: `throws` ?? throwsAll) {
                root[keyPath: keyPath] = value
            }
        })
    }
    convenience init<Value: Codable, Key: CodingKey>(ref keyPath: ReferenceWritableKeyPath<Root, Value>, to codingKeys: Key ..., nonnull: Bool? = nil, throws: Bool? = nil) {
        self.init(encode: { (root, encoder, nonnullAll, throwsAll) in
            try encoder.encode(root[keyPath: keyPath], for: codingKeys.first!, nonnull: nonnull ?? nonnullAll, throws: `throws` ?? throwsAll)
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
    subscript<T: Decodable>(stringKeys: String ...) -> T? {
        return decode(stringKeys, as: T.self)
    }
    subscript<T: Decodable, K: CodingKey>(codingKeys: [K]) -> T? {
        return decode(codingKeys, as: T.self)
    }
    subscript<T: Decodable, K: CodingKey>(codingKeys: K ...) -> T? {
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
        var container = self.container(keyedBy: ExCodingKey.self)
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
        var container = self.container(keyedBy: K.self)
        do {
            if nonnull { try container.encode(value, forKey: codingKey) }
            else { try container.encodeIfPresent(value, forKey: codingKey) }
        }
        catch { if `throws` || nonnull { throw error } }
    }
}

public extension Decoder {
    
    func decodeNonnullThrows<T: Decodable>(_ stringKeys: String ..., as type: T.Type = T.self) throws -> T {
        return try decodeNonnullThrows(stringKeys, as: type)
    }
    func decodeNonnullThrows<T: Decodable>(_ stringKeys: [String], as type: T.Type = T.self) throws -> T {
        return try decode(stringKeys, as: type, nonnull: true, throws: true)!
    }
    func decodeThrows<T: Decodable>(_ stringKeys: String ..., as type: T.Type = T.self) throws -> T? {
        return try decodeThrows(stringKeys, as: type)
    }
    func decodeThrows<T: Decodable>(_ stringKeys: [String], as type: T.Type = T.self) throws -> T? {
        return try decode(stringKeys, as: type, nonnull: false, throws: true)
    }
    func decode<T: Decodable>(_ stringKeys: String ..., as type: T.Type = T.self) -> T? {
        return decode(stringKeys, as: type)
    }
    func decode<T: Decodable>(_ stringKeys: [String], as type: T.Type = T.self) -> T? {
        return try? decode(stringKeys, as: type, nonnull: false, throws: false)
    }
    fileprivate func decode<T: Decodable>(_ stringKeys: [String], as type: T.Type = T.self, nonnull: Bool = false, throws: Bool = false) throws -> T? {
        return try decode(stringKeys.map { ExCodingKey($0) }, as: type, nonnull: nonnull, throws: `throws`)
    }
    
    func decodeNonnullThrows<T: Decodable, K: CodingKey>(_ codingKeys: K ..., as type: T.Type = T.self) throws -> T {
        return try decodeNonnullThrows(codingKeys, as: type)
    }
    func decodeNonnullThrows<T: Decodable, K: CodingKey>(_ codingKeys: [K], as type: T.Type = T.self) throws -> T {
        return try decode(codingKeys, as: type, nonnull: true, throws: true)!
    }
    func decodeThrows<T: Decodable, K: CodingKey>(_ codingKeys: K ..., as type: T.Type = T.self) throws -> T? {
        return try decodeThrows(codingKeys, as: type)
    }
    func decodeThrows<T: Decodable, K: CodingKey>(_ codingKeys: [K], as type: T.Type = T.self) throws -> T? {
        return try decode(codingKeys, as: type, nonnull: false, throws: true)
    }
    func decode<T: Decodable, K: CodingKey>(_ codingKeys: K ..., as type: T.Type = T.self) -> T? {
        return decode(codingKeys, as: type)
    }
    func decode<T: Decodable, K: CodingKey>(_ codingKeys: [K], as type: T.Type = T.self) -> T? {
        return try? decode(codingKeys, as: type, nonnull: false, throws: false)
    }
    fileprivate func decode<T: Decodable, K: CodingKey>(_ codingKeys: [K], as type: T.Type = T.self, nonnull: Bool = false, throws: Bool = false) throws -> T? {
        do {
            let container = try self.container(keyedBy: K.self)
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
            let codingKey = codingKeys.first!
            if let value = try decodeForNestedKeys(codingKey, as: type, nonnull: nonnull, throws: `throws`) {
                return value
            }
        }
        catch { firstError = error }
        
        let codingKeys = Array(codingKeys.dropFirst())
        if !codingKeys.isEmpty,
           let value = try? decodeForAlternativeKeys(codingKeys, as: type, nonnull: nonnull, throws: `throws`) {
            return value
        }
        
        if (`throws` || nonnull) && firstError != nil { throw firstError! }
        return nil
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
        if let exCodingKey = codingKey as? ExCodingKey, // Self.Key is ExCodingKey.Type
           exCodingKey.intValue == nil && exCodingKey.stringValue.contains(dot) {
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
        
        if let digit = T.self as? IntegerValue.Type {
            if let bool = try? decodeIfPresent(Bool.self, forKey: codingKey) {
                return digit.init(ex_int: bool ? 1 : 0) as? T }
            else if let double = try? decodeIfPresent(Double.self, forKey: codingKey) { return digit.init(ex_double: double) as? T } // include Float
            else if let string = try? decodeIfPresent(String.self, forKey: codingKey), let value = digit.init(ex_string: string) { return value as? T }
        }
        else if let float = T.self as? FloatingValue.Type {
            if let bool = try? decodeIfPresent(Bool.self, forKey: codingKey) {
                return float.init(ex_int64: bool ? 1 : 0) as? T }
            if let int64 = try? decodeIfPresent(Int64.self,  forKey: codingKey) { return float.init(ex_int64: int64) as? T } // include all Int types
            else if let string = try? decodeIfPresent(String.self, forKey: codingKey), let value = float.init(ex_string: string) { return value as? T }
        }
        else if type is String.Type {
            if let bool = try? decodeIfPresent(Bool.self, forKey: codingKey) { return String(describing: bool) as? T }
            else if let int64  = try? decodeIfPresent(Int64.self,  forKey: codingKey) { return String(describing: int64) as? T } // include all Int types
            else if let double = try? decodeIfPresent(Double.self, forKey: codingKey) { return String(describing: double) as? T } // include Float
        }
        if let custom = self as? ExCodableDecodingTypeConverter,
           let value = try? custom.decode(self, codingKey: codingKey, as: type) {
            return value
        }
        
        return nil
    }
}

public protocol ExCodableDecodingTypeConverter {
    func decode<T: Decodable, K: CodingKey>(_ container: KeyedDecodingContainer<K>, codingKey: K, as type: T.Type) throws -> T?
}

public typealias Modelable = ExCodable & DataCodable

fileprivate protocol IntegerValue {
    init?(ex_int val: Int)
    init?(ex_string val: String)
    init?(ex_double val: Double)
}
fileprivate extension IntegerValue where Self: FixedWidthInteger {
    init?(ex_int val: Int) { self = Self(val) }
    init?(ex_string val: String) {
        if let bool = bool(from: val) {
            self = bool ? 1 : 0
            return
        }
        if let x = Self(val) {
            self = x
        } else {
            return nil
        }
    }
    init?(ex_double val: Double) { self = Self(val) }
}
extension Int: IntegerValue {}
extension Int8: IntegerValue {}
extension Int16: IntegerValue {}
extension Int32: IntegerValue {}
extension Int64: IntegerValue {}
extension UInt: IntegerValue {}
extension UInt8: IntegerValue {}
extension UInt16: IntegerValue {}
extension UInt32: IntegerValue {}
extension UInt64: IntegerValue {}

fileprivate func bool(from string: String) -> Bool? {
    switch string.lowercased() {
        case "true", "t", "yes", "y":
            return true
        case "false", "f", "no", "n", "":
            return false
        default:
            return nil
    }
}

extension Bool: IntegerValue {
    init?(ex_int val: Int) { self = val != 0 }
    init?(ex_double d: Double) { self = !(d == 0 || d.nextDown == 0 || d.nextUp == 0) }
    init?(ex_string val: String) {
        if let bool = bool(from: val) {
            self = bool
            return
        }
        if let int = Int(val) { self = int != 0 }
        else if let double = Double(val) { self.init(ex_double: double) }
        return nil
    }
}

fileprivate protocol FloatingValue {
    init?(ex_int64 val: Int64)
    init?(ex_string val: String)
}
fileprivate protocol FixedWidthFloating: BinaryFloatingPoint {
    init?(_ text: String)
}

fileprivate extension FloatingValue where Self: FixedWidthFloating {
    init?(ex_int64 val: Int64) { self = Self(val) }
    init?(ex_string val: String) {
        if let bool = bool(from: val) {
            self = bool ? 1.0 : 0.0
            return
        }
        if let val = Self(val) {
            self = val
        } else {
            return nil
        }
    }
}

extension Double: FixedWidthFloating {}
extension Float: FixedWidthFloating {}
extension Double: FloatingValue {}
extension Float: FloatingValue {}
#if canImport(CoreGraphics)
import CoreGraphics
extension CGFloat: FixedWidthFloating {
    init?(_ text: String) {
        guard let val = Double(text) else { return nil }
        self = CGFloat(val)
    }
}
extension CGFloat: FloatingValue {}
#endif
