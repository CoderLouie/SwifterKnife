//
//  Copyable.swift
//  SwifterKnife
//
//  Created by liyang on 2021/10/19.
//

import Foundation

protocol Copyable: AnyObject {
    associatedtype T
    
    func copyable() -> T
}

extension Copyable where Self: NSObject {
    func copyable() -> Self {
        copy() as! Self
    }
}

extension Copyable where Self: DataCodable {
    func copyable() -> Self {
        guard let data = try? encode(),
              let copied = try? Self.decode(with: data) else {
            fatalError()
        }
        return copied
    }
}
