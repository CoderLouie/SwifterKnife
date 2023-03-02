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


/*
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
*/

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
 // 44
 https://github.com/vincent-pradeilles/swift-tips#transform-an-asynchronous-function-into-a-synchronous-one
 */
 
public struct AnyError: Swift.Error {
    public let error: Swift.Error
    public init(_ error: Swift.Error) {
        self.error = AnyError.rawError(of: error)
    }
    private static func rawError(of error: Swift.Error) -> Swift.Error {
        if let anyError = error as? AnyError {
            return rawError(of: anyError.error)
        }
        return error
    }
}

extension AnyError: CustomStringConvertible {
    public var description: String {
        "\(error)"
    }
}
extension AnyError: Equatable {
    public static func == (lhs: AnyError, rhs: AnyError) -> Bool {
        lhs.description == rhs.description
    }
}

public typealias Provider<T> = () -> T
public typealias ResultCompletion<Success, Failure: Swift.Error> = (Result<Success, Failure>) -> Void
public typealias GeneralResultCompletion<Success> = ResultCompletion<Success, AnyError>

// MARK: - Solving callback hell with function composition
// 用函数组合解决回调地狱
infix operator >>>: MultiplicationPrecedence

public func >>> <T, U, V, E1: Swift.Error, E2: Swift.Error>(
    _ first: @escaping (V, ResultCompletion<T, E1>) -> Void,
    _ second: @escaping (V, T, ResultCompletion<U, E2>) -> Void) -> (V, GeneralResultCompletion<U>) -> Void {
    return { v, completion in
        first(v) { firstResult  in
            switch firstResult {
            case .success(let value):
                second(v, value) { secondResult in
                    completion(secondResult.mapError(AnyError.init(_:)))
                }
            case .failure(let error):
                completion(.failure(AnyError(error)))
            }
        }
    }
}

public func >>> <T, U, V, E: Swift.Error>(
    _ first: @escaping (V, ResultCompletion<T, E>) -> Void,
    _ transform: @escaping (V, T) throws -> U) -> (V, GeneralResultCompletion<U>) -> Void {
    return { v, completion in
        first(v) { result in
            switch result {
            case .failure(let error):
                completion(.failure(AnyError(error)))
            case .success(let value):
                do {
                    completion(.success(try transform(v, value)))
                } catch {
                    completion(.failure(AnyError(error)))
                }
            }
        }
    }
}
/*
func service1(_ param: Int, _ completionHandler: ResultCompletion<Int, AppError>) {
    completionHandler(.success(42))
}
func service2(_ param: Int, arg: String, _ completionHandler: ResultCompletion<String, NetError>) {
    completionHandler(.success("🎉 \(arg)"))
}
func testChainFunc() {
    let chainedServices = service1
    >>> { String($1 / 2) // or throw some error }
    >>> service2
    chainedServices(10) { result in
        switch result {
        case .success(let val):
            print(val)
        case .failure(let anyError):
            let error = anyError.error
            print(error)
        }
    }
}
*/


// MARK: - Transform an asynchronous function into a synchronous one
// 将异步函数转换为同步函数
public func makeSynchrone<A, B>(_ asyncFunction: @escaping (A, (B) -> Void) -> Void) -> (A) -> B {
    return { arg in
        let lock = NSRecursiveLock()
        
        var result: B? = nil
        
        asyncFunction(arg) {
            result = $0
            lock.unlock()
        }
        
        lock.lock()
        
        return result!
    }
}
/*
func myAsyncFunction(arg: Int, completionHandler: (String) -> Void) {
    completionHandler("🎉 \(arg)")
}
let syncFunction = makeSynchrone(myAsyncFunction)
print(syncFunction(42)) // prints 🎉 42
*/
