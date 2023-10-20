//
//  PropertyValuesConvertible.swift
//  SwifterKnife
//
//  Created by liyang on 2023/9/25.
//

import Foundation


public protocol PropertyValuesConvertible {
    var propertyValues: Any { get }
}
 
private func propertyValues(of val: Any) -> Any {
    if let raw = val as? (any RawRepresentable) {
        return raw.rawValue
    }
    if let dict = val as? [AnyHashable: Any] {
        return dict.reduce(into: [AnyHashable: Any]()) {
            $0[$1.key.description] = propertyValues(of: $1.value)
        }
    }
    let mirror = Mirror(reflecting: val)
    if mirror.displayStyle == .enum {
        return String(describing: val)
    }
    let childs = sequence(first: mirror, next: \.superclassMirror).flatMap(\.children)
    if childs.isEmpty { return val }
    return childs.reduce(into: [String: Any]()) {
        guard case let (label?, value) = $1 else { return }
        let val = (value as? PropertyValuesConvertible).map(\.propertyValues) ?? value
        let lbl = label.hasPrefix("_") ? String(label.dropFirst()) : label
        $0[lbl] = propertyValues(of: val)
    }
}

public extension PropertyValuesConvertible {
    var propertyValues: Any {
        SwifterKnife.propertyValues(of: self)
    }
    
    var propertyMap: [String: Any] {
        propertyValues as? [String: Any] ?? [:]
    }
}
