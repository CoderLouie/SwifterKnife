//
//  LocalizedKeyRepresentable.swift
//  SwifterKnife
//
//  Created by liyang on 2021/07/20.
//

import Foundation


public protocol LocalizedKeyRepresentable {
    var localizeKey: String { get }
    
    var table: String? { get }
    static var bundle: Bundle { get }
}
public extension LocalizedKeyRepresentable {
    var table: String? { nil }
    static var bundle: Bundle { .main }
}


public extension LocalizedKeyRepresentable {
    var localized: String {
        NSLocalizedString(localizeKey, tableName: table, bundle: Self.bundle, value:"", comment:"")
    }
    
    func localizedFormat(with args: CVarArg...) -> String {
        String(format: localized, arguments: args)
    }
    
    var slocalized: String {
        slocalized(using: .current)
    }
    func slocalized(using language: Language) -> String {
        let key = localizeKey
        func query(in code: Language) -> String? {
            if let path = Self.bundle.path(forResource: code.rawValue, ofType: "lproj"),
                  let bundle = Bundle(path: path)  {
                return bundle.localizedString(forKey: key, value: nil, table: table)
            }
            return nil
        }
        return query(in: language) ?? query(in: .base) ?? key
    }
    func slocalizedFormat(with args: CVarArg..., using lan: Language? = nil) -> String {
        return String(format: slocalized(using: lan ?? .current), arguments: args)
    }
}


extension LocalizedKeyRepresentable where Self: RawRepresentable, Self.RawValue == String {
    public var localizeKey: String { rawValue }
}

extension String: LocalizedKeyRepresentable {
    public var localizeKey: String { self }
}


public struct LocalizedKey {
    public let key: String
    public let tableName: String
    public init(_ key: String, _ tableName: String) {
        self.key = key
        self.tableName = tableName
    }
}
extension LocalizedKey: LocalizedKeyRepresentable {
    public var localizeKey: String { key }
    public var table: String? { tableName }
} 
