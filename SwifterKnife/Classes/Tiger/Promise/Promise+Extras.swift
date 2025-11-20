//
//  Promise+Extras.swift
//  Promise
//
//  Created by Soroush Khanlou on 8/3/16.
//
//

import Foundation

public enum PromiseError: Swift.Error {
    case timeout
    case missed
    case empty
}
public struct IndexError: Swift.Error {
    public let index: Int
    public let error: Swift.Error
    
    public init(index: Int, error: Swift.Error) {
        self.index = index
        self.error = error
    }
}

extension Promise {
    
    @discardableResult
    public func finally(
        on queue: ExecutionContext = DispatchQueue.main,
        onComplete: @escaping () -> Void) -> Promise<Value> {
        return then(on: queue) { _ in
            onComplete()
        } onRejected: { _ in
            onComplete()
        }
    }
    @discardableResult
    public func finallyRes(
        on queue: ExecutionContext = DispatchQueue.main,
        onComplete: @escaping (Result<Value, Swift.Error>) -> Void) -> Promise<Value> {
        return then(on: queue) {
            onComplete(.success($0))
        } onRejected: {
            onComplete(.failure($0))
        }
    }
}

public enum Promises {
    public static func any<T>(_ promises: [Promise<T>], cond: @escaping (Int, T) -> Bool) -> Promise<(Int, Bool)?> {
        return Promise { fulfill, reject in
            guard !promises.isEmpty else {
                fulfill((-1, false))
                return
            }
            for (idx, promise) in promises.enumerated() {
                promise.then { val in
                    if cond(idx, val) {
                        fulfill((idx, true))
                        return
                    }
                    if promises.allSatisfy(\.isFulfilled) {
                        fulfill((idx, false))
                    }
                } onRejected: { error in
                    if promises.allSatisfy(\.isRejected) {
                        fulfill(nil)
                    }
                }
            }
        }
    }
}

 
