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
    
    static var __swifty_empty: Self { get }
    
    init(_ some: Wrapped)
}

extension Optional: OptionalType {
    public static var __swifty_empty: Optional {
        return nil
    }
}

/// Represents a `Key` with an associated generic value type conforming to the
/// `Codable` protocol.
///
///     static let someKey = Key<ValueType>("someKey")
public struct DefaultsKey<ValueType: Codable> {
    fileprivate let _key: String
    fileprivate let _defaultValue: ValueType?

    public init(_ key: String, defaultValue value: ValueType) {
        _key = key
        _defaultValue = value 
    }
}
public extension DefaultsKey where ValueType: OptionalType, ValueType.Wrapped: Codable {
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
    public func get<ValueType: Decodable>(for key: String, default value: @autoclosure () -> ValueType) -> ValueType {
        return get(for: key) ?? value()
    }
    public func get<ValueType>(for key: DefaultsKey<ValueType>) -> ValueType.Wrapped? where ValueType: OptionalType, ValueType.Wrapped: Decodable {
        return get(for: key._key)
    }
    public func get<ValueType>(for key: DefaultsKey<ValueType>) -> ValueType {
        return get(for: key._key) ?? key._defaultValue!
    }
    
    /// Sets a value associated with the specified key.
    ///
    /// - Parameters:
    ///   - some: The value to set.
    ///   - key: The associated `Key<ValueType>`.
    public func set<ValueType: Encodable>(_ value: ValueType?, for key: String) {
        guard let value = value else {
            userDefaults.removeObject(forKey: key)
            return
        }

        if isSwiftCodableType(ValueType.self) || isFoundationCodableType(ValueType.self) {
            userDefaults.set(value, forKey: key)
            return
        }
        
        do {
            let encoder = JSONEncoder()
            let encoded = try encoder.encode(value)
            userDefaults.set(encoded, forKey: key)
            userDefaults.synchronize()
        } catch {
            #if DEBUG
                print(error)
            #endif
        }
    }
    public func set<ValueType>(_ value: ValueType?, for key: DefaultsKey<ValueType>) {
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
        case is String.Type, is Bool.Type, is Int.Type, is Float.Type, is Double.Type:
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

/*
// MARK: ValueType with RawRepresentable conformance
extension DefaultsAdapter {
    public func get<ValueType: RawRepresentable>(for key: String) -> ValueType? where ValueType.RawValue: Decodable {
        if let raw: ValueType.RawValue = get(for: key) {
            return ValueType(rawValue: raw)
        }
        return nil
    }
    public func get<ValueType: RawRepresentable>(for key: DefaultsKey<ValueType>) -> ValueType where ValueType.RawValue: Decodable {
        if let raw: ValueType.RawValue = get(for: key._key) {
            return ValueType(rawValue: raw) ?? key._defaultValue!
        }
        return key._defaultValue!
    }
    
    public func set<ValueType: RawRepresentable>(_ value: ValueType?, for key: String) where ValueType.RawValue: Encodable {
        set(value?.rawValue, for: key)
    }
    /// Sets a value associated with the specified key.
    ///
    /// - Parameters:
    ///   - some: The value to set.
    ///   - key: The associated `Key<ValueType>`.
    public func set<ValueType: RawRepresentable>(_ value: ValueType?, for key: DefaultsKey<ValueType>) where ValueType.RawValue: Encodable {
        set(value?.rawValue, for: key._key)
    }
}
*/

public extension DefaultsAdapter {
    subscript<ValueType>(key: DefaultsKey<ValueType>) -> ValueType.Wrapped? where ValueType: OptionalType, ValueType.Wrapped: Codable {
        get { get(for: key) }
        set { set(newValue, for: key._key) }
    }
    subscript<ValueType>(key: DefaultsKey<ValueType>) -> ValueType {
        get { get(for: key) }
        set { set(newValue, for: key) }
    }
//    subscript<ValueType: RawRepresentable>(key: DefaultsKey<ValueType>) -> ValueType where ValueType.RawValue: Codable {
//        get { get(for: key) }
//        set { set(newValue, for: key) }
//    }
}
public extension DefaultsAdapter {
    subscript<ValueType>(keyPath: KeyPath<DefaultsKeys, DefaultsKey<ValueType>>) -> ValueType.Wrapped? where ValueType: OptionalType, ValueType.Wrapped: Codable {
        get { self[keyStore[keyPath: keyPath]] }
        set { self[keyStore[keyPath: keyPath]] = newValue }
    }
    subscript<ValueType>(keyPath: KeyPath<DefaultsKeys, DefaultsKey<ValueType>>) -> ValueType {
        get { self[keyStore[keyPath: keyPath]] }
        set { self[keyStore[keyPath: keyPath]] = newValue }
    } 
//    subscript<ValueType: RawRepresentable>(keyPath: KeyPath<DefaultsKeys, DefaultsKey<ValueType>>) -> ValueType where ValueType.RawValue: Codable {
//        get { self[keyStore[keyPath: keyPath]] }
//        set { self[keyStore[keyPath: keyPath]] = newValue }
//    }
}

