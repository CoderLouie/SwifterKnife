//
//  Defaults.swift
//  SwifterKnife
//
//  Created by 李阳 on 2022/10/27.
//

/*
 https://github.com/nmdias/DefaultsKit
 */

import Foundation

public struct DefaultsKeys {
    fileprivate init() {}
}

public protocol OptionalType {
    associatedtype Wrapped
    var def_isNil: Bool { get }
}

extension Optional: OptionalType {
    public var def_isNil: Bool {
        switch self {
        case .none: return true
        case .some: return false
        }
    }
}

/// Represents a `Key` with an associated generic value type conforming to the
/// `Codable` protocol.
///
///     static let someKey = Key<ValueType>("someKey")
public struct DefaultsKey<ValueType> {
    fileprivate let _key: String
    fileprivate let _defaultValue: ValueType

    public init(_ key: String, defaultValue value: ValueType) {
        _key = key
        _defaultValue = value 
    }
}
public extension DefaultsKey where ValueType: ExpressibleByNilLiteral {
    init(_ key: String) {
        _key = key
        _defaultValue = nil
    }
}

public let Defaults = DefaultsAdapter()

/// Provides strongly typed values associated with the lifetime
/// of an application. Apropriate for user preferences.
/// - Warning
/// These should not be used to store sensitive information that could compromise
/// the application or the user's security and privacy.
public final class DefaultsAdapter {
    private let keyStore = DefaultsKeys()
    private let userDefaults: UserDefaults
    
    /// Shared instance of `Defaults`, used for ad-hoc access to the user's
    /// defaults database throughout the app.
    
    /// An instance of `Defaults` with the specified `UserDefaults` instance.
    ///
    /// - Parameter userDefaults: The UserDefaults.
    public init(userDefaults: UserDefaults = UserDefaults.standard) {
        self.userDefaults = userDefaults
    }
    
    /// Deletes the value associated with the specified key, if any.
    ///
    /// - Parameter key: The key.
    public func clear<ValueType>(_ key: DefaultsKey<ValueType>) {
        userDefaults.removeObject(forKey: key._key)
    }
    public func clear(_ key: String) {
        userDefaults.removeObject(forKey: key)
    }
    
    /// Checks if there is a value associated with the specified key.
    ///
    /// - Parameter key: The key to look for.
    /// - Returns: A boolean value indicating if a value exists for the specified key.
    public func has<ValueType>(_ key: DefaultsKey<ValueType>) -> Bool {
        return userDefaults.value(forKey: key._key) != nil
    }
    public func has(_ key: String) -> Bool {
        return userDefaults.value(forKey: key) != nil
    }
    
    /// Returns the value associated with the specified key.
    ///
    /// - Parameter key: The key.
    /// - Returns: A `ValueType` or nil if the key was not found.
    public func get<ValueType: Decodable>(for key: String) -> ValueType? {
        if isSwiftCodableType(ValueType.self) ||
            isFoundationCodableType(ValueType.self) {
            return userDefaults.value(forKey: key) as? ValueType
        }
        
        guard let data = userDefaults.data(forKey: key) else {
            return nil
        }
        
        do {
            let decoder = JSONDecoder()
            let decoded = try decoder.decode(ValueType.self, from: data)
            return decoded
        } catch {
            #if DEBUG
                print(error)
            #endif
        }

        return nil
    }
    public func get<ValueType>(for key: DefaultsKey<ValueType>) -> ValueType.Wrapped? where ValueType: OptionalType, ValueType.Wrapped: Decodable {
        return get(for: key._key)
    }
    public func get<ValueType>(for key: DefaultsKey<ValueType>) -> ValueType where ValueType: Decodable {
        return get(for: key._key) ?? key._defaultValue
    }
    public func get<ValueType>(for key: DefaultsKey<ValueType>) -> ValueType.Wrapped? where ValueType: OptionalType, ValueType.Wrapped: RawRepresentable, ValueType.Wrapped.RawValue: Decodable {
        if let raw: ValueType.Wrapped.RawValue = get(for: key._key) {
            return ValueType.Wrapped(rawValue: raw)
        }
        return nil
    }
    public func get<ValueType>(for key: DefaultsKey<ValueType>) -> ValueType where ValueType: RawRepresentable, ValueType.RawValue: Decodable {
        if let raw: ValueType.RawValue = get(for: key._key),
           let res = ValueType(rawValue: raw) {
            return res
        }
        return key._defaultValue
    }
    
    /// Sets a value associated with the specified key.
    ///
    /// - Parameters:
    ///   - some: The value to set.
    ///   - key: The associated `Key<ValueType>`.
    public func set<ValueType: Encodable>(_ value: ValueType, for key: String) {
        if let val = value as? (any OptionalType), val.def_isNil {
            userDefaults.removeObject(forKey: key)
            return
        }

        if isSwiftCodableType(ValueType.self) || isFoundationCodableType(ValueType.self) {
            userDefaults.set(value, forKey: key)
            return
        }
        
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(value)
            userDefaults.set(data, forKey: key)
            userDefaults.synchronize()
        } catch {
            #if DEBUG
                print(error)
            #endif
        }
    }
    public func set<ValueType>(_ value: ValueType, for key: DefaultsKey<ValueType>) where ValueType: Encodable {
        set(value, for: key._key)
    }
    
    /// Removes given bundle's persistent domain
    ///
    /// - Parameter type: Bundle.
    public func removeAll(bundle : Bundle = Bundle.main) {
        guard let name = bundle.bundleIdentifier else { return }
        userDefaults.removePersistentDomain(forName: name)
    }
    
    /// Checks if the specified type is a Codable from the Swift standard library.
    ///
    /// - Parameter type: The type.
    /// - Returns: A boolean value.
    private func isSwiftCodableType<ValueType>(_ type: ValueType.Type) -> Bool {
        switch type {
        case is String.Type,
            is Bool.Type,
            is Int.Type,
            is Float.Type,
            is Double.Type:
            return true
        default:
            return false
        }
    }
    
    /// Checks if the specified type is a Codable, from the Swift's core libraries
    /// Foundation framework.
    ///
    /// - Parameter type: The type.
    /// - Returns: A boolean value.
    private func isFoundationCodableType<ValueType>(_ type: ValueType.Type) -> Bool {
        switch type {
        case is Date.Type:
            return true
        default:
            return false
        }
    }
}
 

public extension DefaultsAdapter {
    subscript<ValueType>(key: DefaultsKey<ValueType>) -> ValueType.Wrapped? where ValueType: OptionalType, ValueType.Wrapped: Codable {
        get { get(for: key) }
        set { set(newValue, for: key._key) }
    }
    subscript<ValueType>(key: DefaultsKey<ValueType>) -> ValueType where ValueType: Codable {
        get { get(for: key) }
        set { set(newValue, for: key) }
    }
}
public extension DefaultsAdapter {
    subscript<ValueType>(keyPath: KeyPath<DefaultsKeys, DefaultsKey<ValueType>>) -> ValueType.Wrapped? where ValueType: OptionalType, ValueType.Wrapped: Codable {
        get { self[keyStore[keyPath: keyPath]] }
        set { self[keyStore[keyPath: keyPath]] = newValue }
    }
    subscript<ValueType>(keyPath: KeyPath<DefaultsKeys, DefaultsKey<ValueType>>) -> ValueType where ValueType: Codable {
        get { self[keyStore[keyPath: keyPath]] }
        set { self[keyStore[keyPath: keyPath]] = newValue }
    }
}

