//
//  Promise+Extras.swift
//  Promise
//
//  Created by Soroush Khanlou on 8/3/16.
//
//

import Foundation 

struct PromiseCheckError: Error { }

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
                }.catchs { error in
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
                reject(NSError(domain: "com.khanlou.Promise", code: -1111, userInfo: [ NSLocalizedDescriptionKey: "Timed out" ]))
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
        generate: @escaping () -> Promise<T>) -> Promise<T> {
        if count <= 0 {
            return generate()
        }
        return Promise<T> { fulfill, reject in
            generate().recover { error in
                return self.delay(delay).flatMap {
                    return retry(count: count-1, delay: delay, generate: generate)
                }
            }.then(onFulfilled: fulfill).catchs(onRejected: reject)
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
            self.then(onFulfilled: fulfill).catchs { error in
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
                    throw PromiseCheckError()
                }
                return value
            } catch {
                throw error
            }
        }
    }
    
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
 
