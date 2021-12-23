//
//  Lazy.swift
//  SwifterKnife
//
//  Created by 李阳 on 2021/12/8.
//

import Foundation
 
public final class Lazy<T> {
    private var builder: (() -> T)!
    
    public init(_ builder: @escaping () -> T) {
        self.builder = builder
    } 
    public private(set) var rawValue: T?
    
    public var wrapped: T {
        if let v = rawValue { return v }
        let v = builder()
        builder = nil
        rawValue = v
        return v
    }
    public var isInitialized: Bool {
        return rawValue != nil
    }
}


@propertyWrapper
public struct Clamp<T: Comparable> {
    private var value: T
    private let min: T
    private let max: T
    public init(wrappedValue value: T, min: T, max: T) {
        assert(value >= min && value <= max, "\(value)不在范围内[\(min), \(max)]")
        (self.value, self.min, self.max) = (value, min, max)
    }
    public var wrappedValue: T {
        get { value }
        set {
            value = newValue < min ? min : (newValue > max ? max : newValue)
        }
    }
}
