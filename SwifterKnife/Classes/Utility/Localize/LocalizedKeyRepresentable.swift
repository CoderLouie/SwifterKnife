//
//  LocalizedStringConvertible.swift
//  VideoCutter
//
//  Created by liyang on 07/20/2021.
//  Copyright (c) 2021 gomo. All rights reserved.
//

import Foundation


public protocol LocalizedKeyRepresentable {
    var localizeKey: String { get }
    
    var table: Language.Table? { get }
    static var bundle: Bundle { get }
}
public extension LocalizedKeyRepresentable {
    var table: Language.Table? { nil }
    static var bundle: Bundle { .main }
}


public extension LocalizedKeyRepresentable {
    var localized: String {
        localized(using: .current)
    }
    func localized(using language: Language) -> String {
        let key = localizeKey
        func query(in code: Language) -> String? {
            if let path = Self.bundle.path(forResource: code.rawValue, ofType: "lproj"),
                  let bundle = Bundle(path: path)  {
                return bundle.localizedString(forKey: key, value: nil, table: table?.rawValue)
            }
            return nil
        }
        return query(in: language) ?? query(in: .base) ?? key
    }
    func localizedFormat(with args: CVarArg..., using lan: Language? = nil) -> String {
        return String(format: localized(using: lan ?? .current), arguments: args)
    }
}


extension LocalizedKeyRepresentable where Self: RawRepresentable, Self.RawValue == String {
    public var localizeKey: String {
        return rawValue
    }
}

extension String: LocalizedKeyRepresentable {
    public var localizeKey: String { self }
}


public struct LocalizedKey {
    public private(set) var key: String
    public private(set) var tableName: String
    init(_ key: String, _ tableName: String) {
        self.key = key
        self.tableName = tableName
    }
}
extension LocalizedKey: LocalizedKeyRepresentable {
    public var localizeKey: String { key }
    public var table: Language.Table? {
        .init(rawValue: tableName)
    }
}

/*
extension String {
   var gif: LocalizedKey {
       LocalizedKey(self, "Gif")
   }
}
 
*/
