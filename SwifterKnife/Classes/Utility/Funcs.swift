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

