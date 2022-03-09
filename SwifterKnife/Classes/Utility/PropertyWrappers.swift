//
//  PropertyWrappers.swift
//  SwifterKnife
//
//  Created by 李阳 on 2022/1/12.
//

import Foundation


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
 
/// 对标OC中的 null_resettable 属性修饰符
@propertyWrapper
public struct NullResettable<T> {
    private var value: T
    private var builder: (() -> T)!
    
    public init(_ builder: @escaping @autoclosure () -> T) {
        self.builder = builder
        value = builder()
    }
    public init(_ builder: @escaping () -> T) {
        self.builder = builder
        value = builder()
    }
    public var wrappedValue: T! {
        get { return value }
        set { value = newValue ?? builder() }
    }
}

@propertyWrapper @dynamicMemberLookup
public final class Ref<Wrapped> {
    public var wrappedValue: Wrapped

    public init(wrappedValue: Wrapped) {
        self.wrappedValue = wrappedValue
    }

    public init(_ wrappedValue: Wrapped) {
        self.wrappedValue = wrappedValue
    }

    public subscript<T>(dynamicMember keyPath: KeyPath<Wrapped, T>) -> T {
        wrappedValue[keyPath: keyPath]
    }
}

@dynamicMemberLookup
public final class Weak<Wrapped: AnyObject> {
    public weak var wrappedValue: Wrapped?

    public init(wrappedValue: Wrapped?) {
        self.wrappedValue = wrappedValue
    }

    public init(_ wrappedValue: Wrapped?) {
        self.wrappedValue = wrappedValue
    }

    public subscript<T>(dynamicMember keyPath: ReferenceWritableKeyPath<Wrapped, T>) -> T? {
        get { wrappedValue?[keyPath: keyPath] }
        set {
            if let newValue = newValue {
                wrappedValue?[keyPath: keyPath] = newValue
            }
        }
    }

    public subscript<T>(dynamicMember keyPath: ReferenceWritableKeyPath<Wrapped, T?>) -> T? {
        get { wrappedValue?[keyPath: keyPath] }
        set { wrappedValue?[keyPath: keyPath] = newValue }
    }
}
