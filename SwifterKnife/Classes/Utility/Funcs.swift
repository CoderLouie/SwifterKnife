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

/*
 var array: [Object] = []
 array.removeAll(where: refPredicate(of: obj))
 */
public func refPredicate<T: AnyObject>(of obj: T) -> (T) -> Bool {
    { $0 === obj }
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
 

//public func until(_ condition: @autoclosure () -> Bool, statements: () -> Void) {
//    while !condition() {
//        statements()
//    }
//}
//public func until(_ cond1: @autoclosure () -> Bool,
//                  _ cond2: @autoclosure () -> Bool,
//                  statements: () -> Void) {
//    while !cond1(), !cond2() {
//        statements()
//    }
//}
//public func until(_ cond1: @autoclosure () -> Bool,
//                  _ cond2: @autoclosure () -> Bool,
//                  _ cond3: @autoclosure () -> Bool,
//                  statements: () -> Void) {
//    while !cond1(), !cond2(), !cond3() {
//        statements()
//    }
//}


public typealias Provider<T> = () -> T



infix operator <=>: AssignmentPrecedence
public func <=><T>(lhs: inout T, rhs: T) -> T {
    lhs = rhs
    return rhs
}

public func ~=<T>(pattern: (T) -> Bool, value: T) -> Bool {
    pattern(value)
}

/*
 rax、rdx常作为函数返回值使用
 register read/d rax 方便查看方法调用返回值 /d是10进制 /x是16进制
 */
