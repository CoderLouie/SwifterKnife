//
//  LocalizedKeyRepresentable.swift
//  SwifterKnife
//
//  Created by liyang on 2021/07/20.
//

import Foundation


public protocol LocalizedKeyRepresentable {
    var key: String { get }
    
    var table: String? { get }
    var bundle: Bundle { get }
}
public extension LocalizedKeyRepresentable {
    var table: String? { nil }
    var bundle: Bundle { .main }
}


public extension LocalizedKeyRepresentable {
    var localized: String {
        NSLocalizedString(key, tableName: table, bundle: bundle, value:"", comment:"")
    }
    
    func localizedFormat(with args: CVarArg...) -> String {
        String(format: localized, arguments: args)
    }
    
    var i18n: String {
        i18n(using: .main)
    }
    func i18n(using lan: Lan) -> String {
        let key = key
        if let path = lan.bundle.path(forResource: lan.current.rawValue, ofType: "lproj"),
              let bundle = Bundle(path: path)  {
            return bundle.localizedString(forKey: key, value: nil, table: table)
        }
        return key
    }
    func i18nFormat(with args: CVarArg..., using lan: Lan = .main) -> String {
        return String(format: i18n(using: lan), arguments: args)
    }
}


extension LocalizedKeyRepresentable where Self: RawRepresentable, Self.RawValue == String {
    public var key: String { rawValue }
}

extension String: LocalizedKeyRepresentable {
    public var key: String { self }
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
    public var table: String? { tableName }
} 
