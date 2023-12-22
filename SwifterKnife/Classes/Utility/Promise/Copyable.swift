//
//  Copyable.swift
//  SwifterKnife
//
//  Created by liyang on 2021/10/19.
//

import Foundation

public protocol Copyable: AnyObject {
    func copyable() -> Self
}

public extension Copyable where Self: NSCopying {
    func copyable() -> Self {
        copy() as! Self
    }
}
public extension Copyable where Self: NSMutableCopying {
    func copyable() -> Self {
        mutableCopy() as! Self
    }
}

public extension Copyable where Self: DataCodable {
    func copyable() -> Self {
        guard let data = try? encode(),
              let copied = try? Self.decode(with: data) else {
            fatalError()
        }
        return copied
    }
}
