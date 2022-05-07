//
//  Persistentable.swift
//  SwifterKnife
//
//  Created by liyang on 2021/10/19.
//

import Foundation

/// 可持久化的
public protocol Persistentable: DataCodable { }

public extension Persistentable {
    func save(toFile path: String) throws {
        let data = try encode()
        try data.write(to: URL(fileURLWithPath: path), options: .atomic)
    }
    static func load(fromFile path: String) throws -> Self {
        let data = try Data(contentsOf: URL(fileURLWithPath: path))
        return try decode(with: data)
    }
} 


