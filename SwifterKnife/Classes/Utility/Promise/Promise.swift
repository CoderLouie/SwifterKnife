//
//  Promise.swift
//  Promise
//
//  Created by Soroush Khanlou on 7/21/16.
//
//

import Foundation

public protocol ExecutionContext {
    func execute(_ work: @escaping () -> Void)
}

extension DispatchQueue: ExecutionContext {
    public func execute(_ work: @escaping () -> Void) {
        async(execute: work)
    }
}

public final class InvalidatableQueue: ExecutionContext {

    private var valid = true

    private var queue: DispatchQueue

    public init(queue: DispatchQueue = .main) {
        self.queue = queue
    }

    public func invalidate() {
        valid = false
    }

    public func execute(_ work: @escaping () -> Void) {
        guard valid else { return }
        self.queue.async(execute: work)
    }
}

struct Callback<Value> {
    let onFulfilled: (Value) -> Void
    let onRejected: (Error) -> Void
    let executionContext: ExecutionContext
    
    func callFulfill(
        _ value: Value,
        completion: @escaping () -> Void = { }) {
        executionContext.execute {
            self.onFulfilled(value)
            completion()
        }
    }
    
    func callReject(
        _ error: Error,
        completion: @escaping () -> Void = { }) {
        executionContext.execute {
            self.onRejected(error)
            completion()
        }
    }
}

enum State<Value>: CustomStringConvertible {

    /// The promise has not completed yet.
    /// Will transition to either the `fulfilled` or `rejected` state.
    case pending(callbacks: [Callback<Value>])

    /// The promise now has a value.
    /// Will not transition to any other state.
    case fulfilled(value: Value)

    /// The promise failed with the included error.
    /// Will not transition to any other state.
    case rejected(error: Error)


    var isPending: Bool {
        if case .pending = self {
            return true
        } else {
            return false
        }
    }
    
    var isFulfilled: Bool {
        if case .fulfilled = self {
            return true
        } else {
            return false
        }
    }
    
    var isRejected: Bool {
        if case .rejected = self {
            return true
        } else {
            return false
        }
    }
    var isCompleted: Bool {
        !isPending
    }
    
    var value: Value? {
        if case let .fulfilled(value) = self {
            return value
        }
        return nil
    }
    
    var error: Error? {
        if case let .rejected(error) = self {
            return error
        }
        return nil
    }
    var result: Result<Value, Swift.Error>? {
        switch self {
        case let .fulfilled(value):
            return .success(value)
        case let .rejected(error):
            return .failure(error)
        case .pending:
            return nil
        }
    }

    var description: String {
        switch self {
        case .fulfilled(let value):
            return "Fulfilled (\(value))"
        case .rejected(let error):
            return "Rejected (\(error))"
        case .pending:
            return "Pending"
        }
    }
}

/*
 reject 这个类型的error将来可以知道是第几步出错
 */
public struct StepError: Swift.Error {
    public let step: Int
    public let error: Swift.Error
    public init(step: Int, error: Swift.Error) {
        self.step = step
        self.error = error
    }
    public init(step: Int) {
        self.step = step
        self.error = PromiseError.empty
    }
    
    public var rawError: Swift.Error {
        return SwifterKnife.rawError(self)
    }
}

private func rawError(_ error: Swift.Error) -> Swift.Error {
    if let err = error as? StepError {
        return rawError(err.error)
    }
    return error
}

fileprivate extension DispatchQueue {
    static let promiseAwait =  DispatchQueue(label:"com.swifterknife.promise.await", attributes: .concurrent)
}

public final class Promise<Value> {
//    deinit {
//        print("Promise \(state) deinit")
//    }
    
    private var state: State<Value>
    private let lockQueue = DispatchQueue(label: "promise_lock_queue", qos: .userInitiated)
    
    public init() {
        state = .pending(callbacks: [])
    }
    
    public init(value: Value) {
        state = .fulfilled(value: value)
    }
    
    public init(error: Error) {
        state = .rejected(error: error)
    }
    
    public static func resolve(_ value: Value) -> Promise<Value> {
        return Promise(value: value)
    }
    public static func reject(_ error: Error) -> Promise<Value> {
        return Promise(error: error)
    }
    
    public convenience init(
        queue: DispatchQueue = .global(qos: .userInitiated),
        work: @escaping (
            _ fulfill: @escaping (Value) -> Void,
            _ reject: @escaping (Error) -> Void) throws -> Void) {
        self.init()
        queue.async {
            do {
                try work(self.fulfill, self.reject)
            } catch {
                self.reject(error)
            }
        }
    }
    public static func create(
        queue: DispatchQueue = .global(qos: .userInitiated),
        work: @escaping (
            _ fulfill: @escaping (Value) -> Void,
            _ reject: @escaping (Error) -> Void) throws -> Void) -> Promise<Value> {
        return .init(queue: queue, work: work)
    }
    public static func create(
        queue: DispatchQueue = .global(qos: .userInitiated),
        work: @escaping (Promise<Value>) -> Void) -> Promise<Value> {
        let promise = Promise<Value>()
        queue.async {
            work(promise)
        }
        return promise
    } 
    
    public func produce<Success, Failure: Swift.Error>(_ mapSuccess: @escaping (Success) throws -> Value?, _ mapError: ((Failure) -> Swift.Error)? = nil) -> (Result<Success, Failure>) -> Void  {
        return { result in
            self.consume(result, mapSuccess, mapError)
        }
    }
    public func consume<Success, Failure: Swift.Error>(_ result: Result<Success, Failure>, _ mapSuccess: (Success) throws -> Value?, _ mapError: ((Failure) -> Swift.Error)? = nil) {
        switch result {
        case .success(let success):
            do {
                if let val = try mapSuccess(success) {
                    fulfill(val)
                } else {
                    reject(PromiseError.missed)
                }
            } catch {
                reject(error)
            }
        case .failure(let e):
            reject(mapError?(e) ?? e)
        }
    }
    public func produce<Failure: Swift.Error>(_ mapError: ((Failure) -> Swift.Error)? = nil) -> (Result<Value, Failure>) -> Void  {
        return { result in
            self.consume(result, mapError)
        }
    }
    public func consume<Failure: Swift.Error>(_ result: Result<Value, Failure>, _ mapError: ((Failure) -> Swift.Error)? = nil) {
        switch result {
        case .success(let success):
            fulfill(success)
        case .failure(let e):
            reject(mapError?(e) ?? e)
        }
    }

    /**
     调用这个方法的线程和将来调用fulfill或者reject方法不能是同一个线程，否则会死锁
     */
    public func awaitCompleted() throws -> Value {
        let semaphore = DispatchSemaphore(value: 0)
        var result: Result<Value, Swift.Error> = .failure(PromiseError.timeout)
        then(on: DispatchQueue.promiseAwait) { value in
            result = .success(value)
            semaphore.signal()
        } onRejected: { error in
            result = .failure(error)
            semaphore.signal()
        }
        semaphore.wait()
        return try result.get()
    }
    public func awaitFulfilled() -> Value {
        try! awaitCompleted()
    }
    
    public func flatMap<NewValue>(
        on queue: ExecutionContext = DispatchQueue.main,
        transform: @escaping (Value) throws -> Promise<NewValue>) -> Promise<NewValue> {
        return Promise<NewValue> { fulfill, reject in
            self.addCallbacks(on: queue, onFulfilled: { value in
                do {
                    try transform(value).then(on: queue, onFulfilled: fulfill, onRejected: reject)
                } catch {
                    reject(error)
                }
            }, onRejected: reject)
        }
    }

    public func map<NewValue>(
        on queue: ExecutionContext = DispatchQueue.main,
        transform: @escaping (Value) throws -> NewValue) -> Promise<NewValue> {
        return Promise<NewValue> { fulfill, reject in
            self.addCallbacks(on: queue, onFulfilled: { val in
                do {
                    let newVal = try transform(val)
                    fulfill(newVal)
                } catch {
                    reject(error)
                }
            }, onRejected: reject)
        }
    }
    
    public func mapError(
        on queue: ExecutionContext = DispatchQueue.main,
        transform: @escaping (Swift.Error) throws -> Swift.Error) -> Promise<Value> {
        return Promise<Value> { fulfill, reject in
            self.addCallbacks(on: queue, onFulfilled: fulfill) { error in
                do {
                    let newError = try transform(error)
                    reject(newError)
                } catch {
                    reject(error)
                }
            }
        }
    }

    /// 便于在catchs 方法中知道是第几步出错
    public func step(
        _ s: Int,
        on queue: ExecutionContext = DispatchQueue.main) -> Promise<Value> {
        return mapError(on: queue) { error in
            if let stepErr = error as? StepError {
//                return StepError(step: s, error: rawError(stepErr))
                return stepErr
            }
            return StepError(step: s, error: rawError(error))
        }
    }

    
    @discardableResult
    public func then(
        on queue: ExecutionContext = DispatchQueue.main,
        onFulfilled: @escaping (Value) -> Void,
        onRejected: @escaping (Error) -> Void = { _ in }) -> Promise<Value> {
        addCallbacks(on: queue, onFulfilled: onFulfilled, onRejected: onRejected)
        return self
    }
    
    @discardableResult
    public func catchs(
        on queue: ExecutionContext = DispatchQueue.main,
        onRejected: @escaping (Error) -> Void) -> Promise<Value> {
        return then(on: queue, onFulfilled: { _ in }, onRejected: onRejected)
    }
    @discardableResult
    public func catchStep(
        on queue: ExecutionContext = DispatchQueue.main,
        onRejected: @escaping (_ error: Error, _ step: Int) -> Void) -> Promise<Value> {
        return then(on: queue, onFulfilled: { _ in }) { err in
            if let stepErr = err as? StepError {
                onRejected(stepErr.error, stepErr.step)
            }
        }
    }
    
    public func reject(_ error: Error) {
        updateState(.rejected(error: error))
    }
    
    public func fulfill(_ value: Value) {
        updateState(.fulfilled(value: value))
    }
    
    public var isPending: Bool {
        lockQueue.sync {
            return self.state.isPending
        }
    }
    
    public var isFulfilled: Bool {
        lockQueue.sync {
            return self.state.isFulfilled
        }
    }
    
    public var isRejected: Bool {
        lockQueue.sync {
            return self.state.isRejected
        }
    }
    public var isCompleted: Bool {
        lockQueue.sync {
            return self.state.isCompleted
        }
    }
    
    public var value: Value? {
        lockQueue.sync {
            return self.state.value
        }
    }
    
    public var error: Error? {
        lockQueue.sync {
            return self.state.error
        }
    }
    
    public var result: Result<Value, Swift.Error>? {
        lockQueue.sync {
            return self.state.result
        }
    }
    
    private func updateState(_ newState: State<Value>) {
        lockQueue.async {
            guard case .pending(let callbacks) = self.state else { return }
            self.state = newState
            self.fireIfCompleted(callbacks: callbacks)
        }
    }
    
    private func addCallbacks(
        on queue: ExecutionContext = DispatchQueue.main,
        onFulfilled: @escaping (Value) -> Void,
        onRejected: @escaping (Error) -> Void) {
        let callback = Callback(onFulfilled: onFulfilled, onRejected: onRejected, executionContext: queue)
        lockQueue.async(flags: .barrier) {
            switch self.state {
            case .pending(let callbacks):
                self.state = .pending(callbacks: callbacks + [callback])
            case .fulfilled(let value):
                callback.callFulfill(value)
            case .rejected(let error):
                callback.callReject(error)
            }
        }
    }
    
    private func fireIfCompleted(callbacks: [Callback<Value>]) {
        guard !callbacks.isEmpty else {
            return
        }
        lockQueue.async {
            switch self.state {
            case .pending: break
                
            case let .fulfilled(value):
                var mutableCallbacks = callbacks
                let firstCallback = mutableCallbacks.removeFirst()
                firstCallback.callFulfill(value) {
                    self.fireIfCompleted(callbacks: mutableCallbacks)
                }
                
            case let .rejected(error):
                var mutableCallbacks = callbacks
                let firstCallback = mutableCallbacks.removeFirst()
                firstCallback.callReject(error) {
                    self.fireIfCompleted(callbacks: mutableCallbacks)
                }
            }
        }
    }
}


extension Promise {
    public func chain<T1>(
        on queue: ExecutionContext = DispatchQueue.main,
        transform: @escaping (Value) throws -> Promise<T1>) -> Promise<(Value, T1)> {
        return Promise<(Value, T1)> { fulfill, reject in
            self.addCallbacks(on: queue, onFulfilled: { value in
                do {
                    try transform(value).then(on: queue, onFulfilled: {
                        fulfill((value, $0))
                    }, onRejected: reject)
                } catch {
                    reject(error)
                }
            }, onRejected: reject)
        }
    }
    
}

public typealias AnyPromise = Promise<Any>
public typealias VoidPromise = Promise<Void>
public typealias BoolPromise = Promise<Bool>
public typealias IntPromise = Promise<Int>
public typealias StringPromise = Promise<String>
public typealias DataPromise = Promise<Data>
public typealias JSONPromise = Promise<[String: Any]>
public typealias ArrayPromise<Element> = Promise<[Element]>
