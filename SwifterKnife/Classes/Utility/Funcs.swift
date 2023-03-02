//
//  Funcs.swift
//  SwifterKnife
//
//  Created by liyang on 2023/2/28.
//

import Foundation

// https://github.com/vincent-pradeilles/swift-tips
public func resultOf<T>(_ code: () -> T) -> T {
    return code()
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



public func if_<Value>(_ condition: Bool, _ then: () -> Value) -> Value? {
    if condition { return then() }
    return nil
}
public func if_<Value>(_ condition1: Bool,
                       _ condition2: @autoclosure () -> Bool,
                       then: () -> Value) -> Value? {
    if condition1, condition2() { return then() }
    return nil
}
public func if_<Value>(_ condition1: Bool,
                       _ condition2: @autoclosure () -> Bool,
                       _ condition3: @autoclosure () -> Bool,
                       then: () -> Value) -> Value? {
    if condition1, condition2(), condition3() { return then() }
    return nil
}


public func if_some<O, Value>(_ op: O?,
                               _ then: (O) -> Value) -> Value? {
    if let o = op { return then(o) }
    return nil
}
public func if_some<O, Value>(_ op: O?,
                               and: @autoclosure () -> Bool,
                               _ then: (O) -> Value) -> Value? {
    if let o = op, and() { return then(o) }
    return nil
}
public func if_some<O, Value>(_ op: O?,
                               and: (O) -> Bool,
                               _ then: (O) -> Value) -> Value? {
    if let o = op, and(o) { return then(o) }
    return nil
}
public func if_some<O, Value>(_ op: O?,
                               and: (O) -> Bool,
                               _ cond: @autoclosure () -> Bool,
                               _ then: (O) -> Value) -> Value? {
    if let o = op, and(o), cond() { return then(o) }
    return nil
}


public func if_some<O1, O2, Value>(_ op1: O1?,
                                    _ op2: O2?,
                                    _ then: (O1, O2) -> Value) -> Value? {
    if let o1 = op1, let o2 = op2 { return then(o1, o2) }
    return nil
}
public func if_some<O1, O2, Value>(_ op1: O1?,
                                    _ op2: O2?,
                                    and: @autoclosure () -> Bool,
                                    _ then: (O1, O2) -> Value) -> Value? {
    if let o1 = op1, let o2 = op2, and() { return then(o1, o2) }
    return nil
}
public func if_some<O1, O2, Value>(_ op1: O1?,
                                    _ op2: O2?,
                                    and: (O1, O2) -> Bool,
                                    _ then: (O1, O2) -> Value) -> Value? {
    if let o1 = op1, let o2 = op2, and(o1, o2) { return then(o1, o2) }
    return nil
}
public func if_some<O1, O2, Value>(_ op1: O1?,
                                    _ op2: O2?,
                                    and: (O1, O2) -> Bool,
                                    _ cond: @autoclosure () -> Bool,
                                    _ then: (O1, O2) -> Value) -> Value? {
    if let o1 = op1, let o2 = op2, and(o1, o2), cond() { return then(o1, o2) }
    return nil
}

public extension Optional {
    func else_if(_ condition: Bool, _ then: () -> Wrapped) -> Wrapped? {
        if case .none = self, condition { return then() }
        return nil
    }
    func else_if_some<O>(_ op: O?,
                         _ then: (O) -> Wrapped) -> Wrapped? {
        if case .none = self, let o = op { return then(o) }
        return nil
    }
    func else_if_some<O1, O2>(_ op1: O1?,
                              _ op2: O2?,
                         _ then: (O1, O2) -> Wrapped) -> Wrapped? {
        if case .none = self, let o1 = op1, let o2 = op2 { return then(o1, o2) }
        return nil
    }
    
    func else_(_ then: () -> Wrapped) -> Wrapped {
        switch self {
        case .none: return then()
        case .some(let val): return val
        }
    }
    func else_(_ then: @autoclosure () -> Wrapped) -> Wrapped {
        switch self {
        case .none: return then()
        case .some(let val): return val
        }
    }
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

/*
public typealias ResultCallback<Success, Failure: Swift.Error> = (Result<Success, Failure>) -> Void

infix operator ~>: MultiplicationPrecedence

public func ~> <T, U, E>(
    _ first: @escaping (ResultCallback<T, E>) -> Void,
    _ second: @escaping (T, ResultCallback<U, E>) -> Void) -> (ResultCallback<U, E>) -> Void {
    return { completion in
        first { firstResult  in
            switch firstResult {
            case .success(let value):
                second(value) { secondResult in
                    completion(secondResult)
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

public func ~> <T, U, E>(
    _ first: @escaping (ResultCallback<T, E>) -> Void,
    _ transform: @escaping (T) -> U) -> (ResultCallback<U, E>) -> Void {
    return { completion in
        first { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let value):
                completion(.success(transform(value)))
            }
        }
    }
}
*/

