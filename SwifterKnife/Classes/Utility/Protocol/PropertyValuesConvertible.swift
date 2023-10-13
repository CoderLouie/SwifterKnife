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

public extension PropertyValuesConvertible {
    var propertyValues: [String: Any] {
        let mirror = Mirror(reflecting: self)
        let childs = sequence(first: mirror, next: \.superclassMirror).flatMap(\.children)
        return childs.reduce(into: [String: Any]()) {
            guard case let (label?, value) = $1 else { return }
            if let convertible = value as? PropertyValuesConvertible {
                $0[label] = convertible.propertyValues
            } else if let conv = value as? [PropertyValuesConvertible] {
                $0[label] = conv.map(\.propertyValues)
            } else {
                $0[label] = value
            }
        }
    }
}
