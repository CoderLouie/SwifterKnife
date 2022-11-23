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

public enum Promises {
    /// Wait for all the promises you give it to fulfill, and once they have, fulfill itself
    /// with the array of all fulfilled values.
    public static func all<T>(_ promises: [Promise<T>]) -> Promise<[T]> {
        return Promise<[T]> { fulfill, reject in
            guard !promises.isEmpty else { fulfill([]);
                return
            }
            for promise in promises {
                promise.then { _ in
                    if !promises.contains(where: { $0.isRejected || $0.isPending }) {
                        fulfill(promises.compactMap(\.value))
                    }
                } onRejected: { error in
                    reject(error)
                }
            }
        }
    }

    /// Resolves itself after some delay.
    /// - parameter delay: In seconds
    public static func delay(_ delay: TimeInterval) -> Promise<()> {
        return Promise<()> { fulfill, _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                fulfill(())
            }
        }
    }

    /// This promise will be rejected after a delay.
    public static func timeout<T>(_ timeout: TimeInterval) -> Promise<T> {
        return Promise<T> { _, reject in
            DispatchQueue.main.asyncAfter(deadline: .now() + timeout) {
                reject(PromiseError.timeout)
            }
        }
    }

    /// Fulfills or rejects with the first promise that completes
    /// (as opposed to waiting for all of them, like `.all()` does).
    public static func race<T>(_ promises: [Promise<T>]) -> Promise<T> {
        guard !promises.isEmpty else { fatalError() }
        return Promise<T> { fulfill, reject in
            for promise in promises {
                promise.then(onFulfilled: fulfill, onRejected: reject)
            }
        }
    }

    public static func retry<T>(
        count: Int,
        delay: TimeInterval,
        generate: @escaping (Int) -> Promise<T>) -> Promise<T> {
        if count <= 0 {
            return generate(count)
        }
        return Promise<T> { fulfill, reject in
            generate(count).recover { error in
                return self.delay(delay).flatMap {
                    return retry(count: count-1, delay: delay, generate: generate)
                }
            }.then(onFulfilled: fulfill, onRejected: reject)
        }
    }

    public static func kickoff<T>(
        _ block: @escaping () throws -> Promise<T>)
    -> Promise<T> {
        return Promise(value: ()).flatMap(transform: block)
    }

    public static func kickoff<T>(
        _ block: @escaping () throws -> T) -> Promise<T> {
        do {
            return try Promise(value: block())
        } catch {
            return Promise(error: error)
        }
    }

    public static func zip<T, U>(
        _ first: Promise<T>,
        _ second: Promise<U>) -> Promise<(T, U)> {
        return Promise<(T, U)> { fulfill, reject in
            let resolver: (Any) -> Void = { _ in
                if let firstValue = first.value,
                    let secondValue = second.value {
                    fulfill((firstValue, secondValue))
                }
            }
            first.then(onFulfilled: resolver, onRejected: reject)
            second.then(onFulfilled: resolver, onRejected: reject)
        }
    }

    // The following zip functions have been created with the 
    // "Zip Functions Generator" playground page. If you need variants with
    // more parameters, use it to generate them.

    /// Zips 3 promises of different types into a single Promise whose
    /// type is a tuple of 3 elements.
    public static func zip<T1, T2, T3>(
        _ p1: Promise<T1>,
        _ p2: Promise<T2>,
        _ p3: Promise<T3>) -> Promise<(T1, T2, T3)> {
        return Promise<(T1, T2, T3)> { fulfill, reject in

            let resolver: (Any) -> Void = { _ in
                if let value1 = p1.value,
                   let value2 = p2.value,
                   let value3 = p3.value {
                    fulfill((value1, value2, value3))
                }
            }
            p1.then(onFulfilled: resolver, onRejected: reject)
            p2.then(onFulfilled: resolver, onRejected: reject)
            p3.then(onFulfilled: resolver, onRejected: reject)
        }
    }

    /// Zips 4 promises of different types into a single Promise whose
    /// type is a tuple of 4 elements.
    public static func zip<T1, T2, T3, T4>(
        _ p1: Promise<T1>,
        _ p2: Promise<T2>,
        _ p3: Promise<T3>,
        _ p4: Promise<T4>) -> Promise<(T1, T2, T3, T4)> {
        return Promise<(T1, T2, T3, T4)> { fulfill, reject in
            
            let resolver: (Any) -> Void = { _ in
                if let val1 = p1.value,
                   let val2 = p2.value,
                   let val3 = p3.value,
                   let val4 = p4.value {
                    fulfill((val1, val2, val3, val4))
                }
            }
            p1.then(onFulfilled: resolver, onRejected: reject)
            p2.then(onFulfilled: resolver, onRejected: reject)
            p3.then(onFulfilled: resolver, onRejected: reject)
            p4.then(onFulfilled: resolver, onRejected: reject)
        }
    }
}

extension Promises {
    
    public static func wrap<Value, Failure: Swift.Error>(
        queue: DispatchQueue = .global(qos: .userInitiated),
        _ fn: @escaping (@escaping (Result<Value, Failure>) -> Void) -> Void) -> Promise<Value> {
        let res = Promise<Value>()
        queue.async {
            fn { result in
                switch result {
                case .success(let v):
                    res.fulfill(v)
                case .failure(let e):
                    res.reject(e)
                }
            }
        }
        return res
    }
    public static func wrap<P, Value, Failure: Swift.Error>(
        queue: DispatchQueue = .global(qos: .userInitiated),
        param: P,
        _ fn: @escaping (P, @escaping (Result<Value, Failure>) -> Void) -> Void) -> Promise<Value> {
        wrap(queue: queue) { closure in
            fn(param, closure)
        }
    }
    public static func wrap<P1, P2, Value, Failure: Swift.Error>(
        queue: DispatchQueue = .global(qos: .userInitiated),
        param1: P1,
        param2: P2,
        _ fn: @escaping (P1, P2, @escaping (Result<Value, Failure>) -> Void) -> Void) -> Promise<Value> {
        wrap(queue: queue) { closure in
            fn(param1, param2, closure)
        }
    }
}

public struct IndexError: Swift.Error {
    public let index: Int
    public let error: Swift.Error
    
    public init(index: Int, error: Swift.Error) {
        self.index = index
        self.error = error
    }
}
extension Promises {
    public static func asyncMap
    <Element, Value, Failure: Swift.Error>(
        of array: [Element],
        on queue: DispatchQueue = .global(qos: .userInitiated),
        using closure: @escaping (_ element: Element,
                         _ index: Int,
                         _ completion: @escaping (Result<Value, Failure>) -> Void) -> Void) -> Promise<[Value]> {
        let promise = Promise<[Value]>()
        var iterator = array.enumerated().makeIterator()
        guard let first = iterator.next() else {
            promise.fulfill([])
            return promise
        }
        var res: [Value] = []
        func work(pair: (offset: Int, element: Element)?) {
            guard let pair = pair else {
                promise.fulfill(res)
                return
            }
            closure(pair.element, pair.offset) { result in
                switch result {
                case .success(let val):
                    queue.async {
                        res.append(val)
                        work(pair: iterator.next())
                    }
                case .failure(let err):
                    queue.async {
                        promise.reject(IndexError(index: pair.offset, error: err))
                    }
                }
            }
        }
        queue.async { work(pair: first) }
        return promise
    }
}

extension Promise {
    public func addTimeout(_ timeout: TimeInterval) -> Promise<Value> {
        return Promises.race([self, Promises.timeout(timeout)])
    }

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

    public func recover(
        _ recovery: @escaping (Error) throws -> Promise<Value>) -> Promise<Value> {
        return Promise { fulfill, reject in
            self.then(onFulfilled: fulfill) { error in
                do {
                    try recovery(error).then(onFulfilled: fulfill, onRejected: reject)
                } catch {
                    reject(error)
                }
            }
        }
    }

    public func filter(
        _ isValid: @escaping (Value) throws -> Bool) -> Promise<Value> {
        return map { (value: Value) -> Value in
            do {
                guard try isValid(value) else {
                    throw PromiseError.missed
                }
                return value
            } catch {
                throw error
            }
        }
    }
    
    @discardableResult
    public func catchs<E: Error>(
        as errorType: E.Type,
        onHit: @escaping (E) -> Void) -> Promise<Value> {
        catchs { error in
            if let castedError = error as? E {
                onHit(castedError)
            }
        }
    }
}
 
