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


infix operator &&->: LogicalConjunctionPrecedence
@discardableResult @inlinable
public func &&-> <T>(lhs: Bool, rhs: @autoclosure () throws -> T) rethrows -> T? {
    return lhs ? try rhs() : nil
}
@discardableResult @inlinable
public func &&-> <T>(lhs: Bool, rhs: @autoclosure () throws -> T?) rethrows -> T? {
    return lhs ? try rhs() : nil
}

/*
 rax、rdx常作为函数返回值使用
 register read/d rax 方便查看方法调用返回值 /d是10进制 /x是16进制
 */


public func sk_pick<T>(_ condition: @escaping @autoclosure () -> Bool, _ type: T.Type) -> (_ ifTrue: @autoclosure () -> T, _ ifFalse: @autoclosure () -> T) -> T {
    { condition() ? $0() : $1() }
}


//public extension Bool {
//    func choose<T>(_ type: T.Type) -> (_ ifTrue: @autoclosure () -> T, _ ifFalse: @autoclosure () -> T) -> T  {
//        pick(self, type)
//    }
//}


/// Returns a modified closure that emits the latest non-nil value
/// if the original closure would return nil.
///
/// - SeeAlso: https://github.com/Thomvis/Construct/blob/main/Construct/Foundation/Memoize.swift
public func replayNonNil<A, B>(_ f: @escaping (A) -> B?) -> (A) -> B? {
    var memo: B?
    return {
        if let res = f($0) {
            memo = res
            return res
        }
        return memo
    }
}

/// Creates a closure (T?) -> T? that returns last non-`nil` T passed to it.
///
/// - SeeAlso: https://github.com/Thomvis/Construct/blob/main/Construct/Foundation/Memoize.swift
public func replayNonNil<T>() -> (T?) -> T? {
    replayNonNil { $0 }
}


public func cost(_ work: @escaping (Double) -> Void) -> () -> Void {
   let now = CACurrentMediaTime()
   return { work(CACurrentMediaTime() - now) }
}
/*
 func dowork(_ completion: @escaping (Int) -> Void) {
     DispatchQueue.main.after(2.1) {
         completion(1)
     }
 }
 dowork(cost { num, cost in
     print(num, cost)
 })
 */
public func cost<T>(_ work: @escaping (T, Double) -> Void) -> (T) -> Void {
    let now = CACurrentMediaTime()
    return { work($0, CACurrentMediaTime() - now) }
}

public func cost<T, V>(_ work: @escaping (T, V, Double) -> Void) -> (T, V) -> Void {
   let now = CACurrentMediaTime()
   return { work($0, $1, CACurrentMediaTime() - now) }
}

public func cost<T, V, P>(_ work: @escaping (T, V, P, Double) -> Void) -> (T, V, P) -> Void {
   let now = CACurrentMediaTime()
   return { work($0, $1, $2, CACurrentMediaTime() - now) }
}


