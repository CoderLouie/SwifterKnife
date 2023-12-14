//
//  KeyChain.swift
//  SwifterKnife
//
//  Created by liyang on 2023/12/12.
//

import Foundation
import Security

public enum KeyChain {
    public enum Error: Swift.Error {
        case operationNotImplemented
        case invalidParameters
        case userCanceled
        case itemNotAvailable
        case authFailed
        case duplicateItem
        case itemNotFound
        case interactionNotAllowed
        case decodeFailed
    }
    
    struct Query {
        struct Key {
            public let value: String
            public init(_ value: CFString) {
                self.value = value as String
            }
        }
        subscript(_ key: Key) -> Any? {
            get { fields[key.value] }
            set {
                fields[key.value] = newValue
            }
        }
        var cf: CFDictionary {
            fields as CFDictionary
        }
        private(set) var fields: [String: Any] = [:]
    }
    
    public struct Sample {
        fileprivate let query: Query
        
        public init(service: String,
                    synchronized: Bool = false,
                    accessGroup: String? = nil) {
            var query = Query()
            query[.kclass] = kSecClassGenericPassword
            query[.service] = service
            if synchronized {
                query[.synchronizable] = kCFBooleanTrue
            }
            if let group = accessGroup, !group.isEmpty {
                query[.accessGroup] = group
            }
            self.query = query
        }
    }
}

extension KeyChain.Sample {
    private func makeQuery(with key: String, data: Data? = nil, extra: ((inout KeyChain.Query) -> Void)? = nil) -> KeyChain.Query {
        var query = self.query
        query[.account] = key
        query[.valueData] = data
        extra?(&query)
        return query
    }
    @discardableResult
    private func firstDo(_ work: () -> OSStatus, second: ((KeyChain.Error) -> (OSStatus, Bool)?)? = nil) throws -> Bool {
        guard let error = KeyChain.Error(status: work()) else {
            return true
        }
        if let info = second?(error) {
            if let err = KeyChain.Error(status: info.0) {
                throw err
            }
            return info.1
        }
        throw error
    }
    
    public func set(_ data: Data, forKey key: String) throws {
        try firstDo {
            let query = makeQuery(with: key, data: data) {
                $0[.accessible] = kSecAttrAccessibleAfterFirstUnlock
            }
            return SecItemAdd(query.cf, nil)
        } second: { error in
            guard error == .duplicateItem else { return nil }
            var updateAttr = KeyChain.Query()
            updateAttr[.valueData] = data
            return (SecItemUpdate(makeQuery(with: key).cf, updateAttr.cf), true)
        }
    }
    
    public func remove(forKey key: String) throws {
        try firstDo {
            SecItemDelete(makeQuery(with: key).cf)
        }
    }
    
    public func removeAll() throws {
        try firstDo {
            SecItemDelete(query.cf)
        } second: {
            if $0 == .itemNotFound { return (errSecSuccess, true) }
            return nil
        }
    }
    
    public func has(forKey key: String) throws -> Bool {
        try firstDo {
            SecItemCopyMatching(makeQuery(with: key).cf, nil)
        } second: {
            if $0 == .itemNotFound { return (errSecSuccess, false) }
            return nil
        }
    }
    
    public func allKeys() throws -> [String] {
        var query = self.query
        query[.returnAttributes] = kCFBooleanTrue
        query[.matchLimit] = kSecMatchLimitAll
        var result: AnyObject?
        let status = SecItemCopyMatching(query.cf, &result)
        if let err = KeyChain.Error(status: status),
            err != .itemNotFound {
            throw err
        }
        guard let items = result as? [[String: Any]],
              !items.isEmpty else {
//            throw NSError(domain: "com.swifterknife.keychain", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to cast the retrieved items to a [[String: Any]] value"])
            return []
        }
        var keys: [String] = []
        
        for item in items {
            if let key = item[kSecAttrAccount as String] as? String {
                keys.append(key)
            }
        }
        return keys
    }
}

extension KeyChain.Error: RawRepresentable, CustomDebugStringConvertible {
    
    public init?(status: OSStatus) {
        switch status {
        case errSecUnimplemented: self = .operationNotImplemented
        case errSecParam: self = .invalidParameters
        case errSecUserCanceled: self = .userCanceled
        case errSecNotAvailable: self = .itemNotAvailable
        case errSecAuthFailed: self = .authFailed
        case errSecDuplicateItem: self = .duplicateItem
        case errSecItemNotFound: self = .itemNotFound
        case errSecInteractionNotAllowed: self = .interactionNotAllowed
        case errSecDecode: self = .decodeFailed
        default: return nil
        }
    }
    public var status: OSStatus {
        switch self {
        case .operationNotImplemented: return errSecUnimplemented
        case .invalidParameters: return errSecParam
        case .userCanceled: return errSecUserCanceled
        case .itemNotAvailable: return errSecNotAvailable
        case .authFailed: return errSecAuthFailed
        case .duplicateItem: return errSecDuplicateItem
        case .itemNotFound: return errSecItemNotFound
        case .interactionNotAllowed: return errSecInteractionNotAllowed
        case .decodeFailed: return errSecDecode
        }
    }
    
    public init?(rawValue: OSStatus) {
        self.init(status: rawValue)
    }
    public var rawValue: OSStatus {
        status
    }
    
    public var debugDescription: String {
        switch self {
        case .operationNotImplemented:
            return "errSecUnimplemented: A function or operation is not implemented."
        case .invalidParameters:
            return "errSecParam: One or more parameters passed to the function are not valid."
        case .userCanceled:
            return "errSecUserCanceled: User canceled the operation."
        case .itemNotAvailable:
            return "errSecNotAvailable: No trust results are available."
        case .authFailed:
            return "errSecAuthFailed: Authorization and/or authentication failed."
        case .duplicateItem:
            return "errSecDuplicateItem: The item already exists."
        case .itemNotFound:
            return "errSecItemNotFound: The item cannot be found."
        case .interactionNotAllowed:
            return "errSecInteractionNotAllowed: Interaction with the Security Server is not allowed."
        case .decodeFailed:
            return "errSecDecode: Unable to decode the provided data."
        }
    }
}

extension KeyChain.Query.Key {
    static var kclass: Self { .init(kSecClass) }
    static var service: Self { .init(kSecAttrService) }
    static var account: Self { .init(kSecAttrAccount) }
    static var accessGroup: Self { .init(kSecAttrAccessGroup) }
    static var accessible: Self { .init(kSecAttrAccessible) }
    static var authenticationContext: Self { .init(kSecUseAuthenticationContext) }
    static var matchLimit: Self { .init(kSecMatchLimit) }
    static var returnData: Self { .init(kSecReturnData) }
    static var valueData: Self { .init(kSecValueData) }
    static var returnAttributes: Self { .init(kSecReturnAttributes) }
    static var matchLimitAll: Self { .init(kSecMatchLimitAll) }
    static var synchronizable: Self { .init(kSecAttrSynchronizable) }
}
