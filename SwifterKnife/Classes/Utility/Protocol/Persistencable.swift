//
//  Archivable.swift
//  SwifterKnife
//
//  Created by liyang on 2021/10/19.
//

import Foundation

/// 可持久化的
public protocol Persistencable: DataCodable { }

public extension Persistencable {
    @discardableResult
    func save(toFile path: String) -> Bool {
        do {
            let data = try encode()
            try data.write(to: URL(fileURLWithPath: path), options: .atomic)
            return true
        } catch {
            return false
        }
    }
    static func load(fromFile path: String) -> Self? {
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            return try decode(with: data)
        } catch {
            return nil
        }
    }
} 


