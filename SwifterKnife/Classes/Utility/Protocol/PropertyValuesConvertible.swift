//
//  PropertyValuesConvertible.swift
//  SwifterKnife
//
//  Created by 李阳 on 2023/9/25.
//

import Foundation


public protocol PropertyValuesConvertible {
    var propertyValues: [String: Any] { get }
}
 
private func propertyValues(of val: Any) -> Any {
    if let dict = val as? [AnyHashable: Any] {
        return dict.reduce(into: [AnyHashable: Any]()) {
            $0[$1.key.description] = propertyValues(of: $1.value)
        }
    }
    let mirror = Mirror(reflecting: val)
    let childs = sequence(first: mirror, next: \.superclassMirror).flatMap(\.children)
    if childs.isEmpty { return val }
    return childs.reduce(into: [String: Any]()) {
        guard case let (label?, value) = $1 else { return }
        $0[label] = propertyValues(of: value)
    }
}

public extension PropertyValuesConvertible {
    var propertyValues: [String: Any] {
        SwifterKnife.propertyValues(of: self) as? [String: Any] ?? [:]
    }
}
