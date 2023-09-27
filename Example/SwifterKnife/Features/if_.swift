//
//  if_.swift
//  SwifterKnife_Example
//
//  Created by 李阳 on 2023/3/3.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import Foundation


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
