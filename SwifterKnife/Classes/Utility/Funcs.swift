//
//  Funcs.swift
//  SwifterKnife
//
//  Created by liyang on 2023/2/28.
//

import Foundation

fileprivate protocol AnyOptional {
    var at_isNil: Bool { get }
}
extension Optional: AnyOptional {
    var at_isNil: Bool {
        switch self {
        case .none: return true
        case .some: return false
        }
    }
}

@propertyWrapper
public struct ATDefaults<T> {
    private var rawValue: T
    private let key: String
    
    public var wrappedValue: T {
        get { rawValue }
        set {
            rawValue = newValue
            if let optional = newValue as? AnyOptional,
               optional.at_isNil {
                UserDefaults.standard.removeObject(forKey: key)
            } else {
                UserDefaults.standard.set(newValue, forKey: key)
            }
        }
    }
    public init(defaultValue: T, key: String) {
        rawValue = UserDefaults.standard.value(forKey: key) as? T ?? defaultValue
        self.key = key
    }
}
extension ATDefaults where T: ExpressibleByNilLiteral {
    public init(key: String) {
        self.init(defaultValue: nil, key: key)
    }
}

// https://github.com/vincent-pradeilles/swift-tips
public func resultOf<T>(_ code: () -> T) -> T {
    return code()
}


@resultBuilder
public enum ResultBuilder<T> {
    public static func buildBlock(_ components: T...) -> T {
        let n = components.count
        return components[n - 1]
    }
    public static func buildEither(first component: T) -> T {
        component
    }
    public static func buildEither(second component: T) -> T {
        component
    }
}
public func buildResult<T>(@ResultBuilder<T> body: () -> T) -> T {
    return body()
}

public func && (lhs: Bool?, rhs: Bool?) -> Bool? {
    switch (lhs, rhs) {
    case (false, _), (_, false):
        return false
    case let (unwrapLhs?, unwrapRhs?):
        return unwrapLhs && unwrapRhs
    default:
        return nil
    }
}

public func || (lhs: Bool?, rhs: Bool?) -> Bool? {
    switch (lhs, rhs) {
    case (true, _), (_, true):
        return true
    case let (unwrapLhs?, unwrapRhs?):
        return unwrapLhs || unwrapRhs
    default:
        return nil
    }
}

public func parallel<T, U>(
    _ left: @autoclosure () -> T,
    _ right: @autoclosure () -> U) -> (T, U) {
    var leftRes: T?
    var rightRes: U?
    
    DispatchQueue.concurrentPerform(iterations: 2) { id in
        if id == 0 {
            leftRes = left()
        } else {
            rightRes = right()
        }
    }
    
    return (leftRes!, rightRes!)
}
 

public func until(_ condition: @autoclosure () -> Bool, statements: () -> Void) {
    while !condition() {
        statements()
    }
}
public func until(_ cond1: @autoclosure () -> Bool,
                  _ cond2: @autoclosure () -> Bool,
                  statements: () -> Void) {
    while !cond1(), !cond2() {
        statements()
    }
}
public func until(_ cond1: @autoclosure () -> Bool,
                  _ cond2: @autoclosure () -> Bool,
                  _ cond3: @autoclosure () -> Bool,
                  statements: () -> Void) {
    while !cond1(), !cond2(), !cond3() {
        statements()
    }
}


public typealias Provider<T> = () -> T



infix operator <=>: AssignmentPrecedence
public func <=><T>(lhs: inout T, rhs: T) -> T {
    lhs = rhs
    return rhs
}

public func ~=<T>(pattern: (T) -> Bool, value: T) -> Bool {
    pattern(value)
}

