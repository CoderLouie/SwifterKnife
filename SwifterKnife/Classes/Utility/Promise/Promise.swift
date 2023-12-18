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
    
    public enum AsyncResult {
        case fulfill(_ val: Value)
        case reject(_ error: Swift.Error)
        case retry(after: TimeInterval)
    }
    public static func repeatWhile(
        on queue: DispatchQueue = .global(qos: .userInitiated),
        _ asyncCond: @escaping (_ index: Int, _ finish: @escaping (AsyncResult) -> Void) -> Void) -> Promise<Value> {
        let promise = Promise()
        var continuation: ((AsyncResult) -> Void)!
        var index = 0
        continuation = { result in
            switch result {
            case .fulfill(let val):
                promise.fulfill(val)
            case .reject(let err):
                promise.reject(err)
            case let .retry(after: interval):
                queue.asyncAfter(deadline: .now() + interval) {
                    index += 1
                    asyncCond(index, continuation)
                }
            }
        }
        queue.async {
            asyncCond(index, continuation)
        }
        return promise
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
    
    public func produce<Success, Failure: Swift.Error>(_ mapSuccess: @escaping (Success) throws -> Value?, _ mapError: ((Failure) -> Swift.Error?)? = nil) -> (Result<Success, Failure>) -> Void  {
        return { self.consume($0, mapSuccess, mapError) }
    }
    
    public func consume<Success, Failure: Swift.Error>(_ result: Result<Success, Failure>, _ mapSuccess: (Success) throws -> Value?, _ mapError: ((Failure) -> Swift.Error?)? = nil) {
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
    
    
    public func produce<Failure: Swift.Error>(_ mapError: ((Failure) -> Swift.Error?)? = nil) -> (Result<Value, Failure>) -> Void  {
        return { self.consume($0, mapError) }
    }
    
    public func consume<Failure: Swift.Error>(_ result: Result<Value, Failure>, _ mapError: ((Failure) -> Swift.Error?)? = nil) {
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
    public func awaitCompleted() -> Swift.Result<Value, Swift.Error> {
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
        return result
    }
    public func awaitCompleted() throws -> Value {
        try awaitCompleted().get()
    }
    public func awaitFulfilled() -> Value {
        try! awaitCompleted().get()
    }
    
    public func asyncFlatMap<NewValue>(
        on queue: ExecutionContext = DispatchQueue.main,
        closure: @escaping (_ value: Value, _ completion: @escaping (Result<Promise<NewValue>, Swift.Error>) -> Void) -> Void) -> Promise<NewValue> {
        return Promise<NewValue> { fulfill, reject in
            self.then(on: queue, onFulfilled: { value in
                closure(value) { result in
                    switch result {
                    case .success(let promise):
                        promise.then(on: queue, onFulfilled: fulfill, onRejected: reject)
                    case .failure(let error):
                        reject(error)
                    }
                }
            }, onRejected: reject)
        }
    }
    
    public func flatMap<NewValue>(
        on queue: ExecutionContext = DispatchQueue.main,
        transform: @escaping (Value) throws -> Promise<NewValue>) -> Promise<NewValue> {
        return Promise<NewValue> { fulfill, reject in
            self.then(on: queue, onFulfilled: { value in
                do {
                    try transform(value).then(on: queue, onFulfilled: fulfill, onRejected: reject)
                } catch {
                    reject(error)
                }
            }, onRejected: reject)
        }
    }
    public func reduce<Next, Result>(
        on queue: ExecutionContext = DispatchQueue.main,
        transform: @escaping (Value) throws -> Promise<Next>,
        combine: @escaping (_ value: Value, _ next: Next) throws -> Result) -> Promise<Result> {
        return Promise<Result> { fulfill, reject in
            self.then(on: queue, onFulfilled: { value in
                do {
                    try transform(value).then(on: queue, onFulfilled: { next in
                        do {
                            fulfill(try combine(value, next))
                        } catch {
                            reject(error)
                        }
                    }, onRejected: reject)
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
            self.then(on: queue, onFulfilled: { val in
                do {
                    let newVal = try transform(val)
                    fulfill(newVal)
                } catch {
                    reject(error)
                }
            }, onRejected: reject)
        }
    }
    
    public func delay(_ delay: TimeInterval) -> Promise<Value> {
        return Promise<Value> { fulfill, reject in
            self.then { value in
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    fulfill(value)
                }
            } onRejected: { error in
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    reject(error)
                }
            }
        }
    }

    public func verify1(
        on queue: ExecutionContext = DispatchQueue.main,
        test: @escaping (_ value: Value, _ completion: @escaping (Swift.Error?) -> Void) -> Void) -> Promise<Value> {
        return Promise<Value> { fulfill, reject in
            self.then(on: queue, onFulfilled: { value in
                test(value) { error in
                    if let err = error {
                        reject(err)
                    } else {
                        fulfill(value)
                    }
                }
            }, onRejected: reject)
        }
    }
    public func verify2<Placholder>(
        on queue: ExecutionContext = DispatchQueue.main,
        transform: @escaping (Value) throws -> Promise<Placholder>) -> Promise<Value> {
        return Promise<Value> { fulfill, reject in
            self.then(on: queue, onFulfilled: { value in
                do {
                    try transform(value).then(on: queue, onFulfilled: { _ in
                        fulfill(value)
                    }, onRejected: reject)
                } catch {
                    reject(error)
                }
            }, onRejected: reject)
        }
    }
    
    public func mapError(
        on queue: ExecutionContext = DispatchQueue.main,
        transform: @escaping (Swift.Error) throws -> Swift.Error?) -> Promise<Value> {
        return Promise<Value> { fulfill, reject in
            self.then(on: queue, onFulfilled: fulfill) { error in
                do {
                    if let newError = try transform(error) {
                        reject(newError)
                    } else {
                        reject(error)
                    }
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
            if let stepError = error as? StepError { 
                return stepError
            }
            return StepError(step: s, error: error)
        }
    }
     
    @discardableResult
    public func handle(
        on queue: ExecutionContext = DispatchQueue.main,
        _ handler: @escaping (Result<Value, Swift.Error>) -> Void) -> Promise<Value> {
        then(on: queue) {
            handler(.success($0))
        } onRejected: {
            handler(.failure($0))
        }
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
            return state.isPending
        }
    }
    
    public var isFulfilled: Bool {
        lockQueue.sync {
            return state.isFulfilled
        }
    }
    
    public var isRejected: Bool {
        lockQueue.sync {
            return state.isRejected
        }
    }
    public var isCompleted: Bool {
        lockQueue.sync {
            return state.isCompleted
        }
    }
    
    public var value: Value? {
        lockQueue.sync {
            return state.value
        }
    }
    
    public var error: Error? {
        lockQueue.sync {
            return state.error
        }
    }
    
    public var result: Result<Value, Swift.Error>? {
        lockQueue.sync {
            return state.result
        }
    }
    
    
    @discardableResult
    public func then(
        on queue: ExecutionContext = DispatchQueue.main,
        onFulfilled: @escaping (Value) -> Void,
        onRejected: @escaping (Error) -> Void = { _ in }) -> Promise<Value> {
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
        return self
    }
    /// StepError
    @discardableResult
    public func sthen(
        on queue: ExecutionContext = DispatchQueue.main,
        onFulfilled: @escaping (Value) -> Void,
        onRejected: @escaping (Error, Int?) -> Void = { _, _ in }) -> Promise<Value> {
        return then(on: queue, onFulfilled: onFulfilled) { err in
            if let stepErr = err as? StepError {
                onRejected(stepErr.error, stepErr.step)
            } else {
                onRejected(err, nil)
            }
        }
    }
    /// IndexError
    @discardableResult
    public func ithen(
        on queue: ExecutionContext = DispatchQueue.main,
        onFulfilled: @escaping (Value) -> Void,
        onRejected: @escaping (Error, Int?) -> Void = { _, _ in }) -> Promise<Value> {
        return then(on: queue, onFulfilled: onFulfilled) { err in
            if let idxErr = err as? IndexError {
                onRejected(idxErr.error, idxErr.index)
            } else {
                onRejected(err, nil)
            }
        }
    }
    
    private func updateState(_ newState: State<Value>) {
        lockQueue.async {
            guard case .pending(let callbacks) = self.state else { return }
            self.state = newState
            self.fireIfCompleted(callbacks: callbacks)
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

@available(macOS 12.0.0, iOS 15, watchOS 7, *)
public extension Promise {
    /// Awaits the value in the promise or an error.
    /// - Parameters:
    ///   - queue: Optional; queue to await on.
    ///            Defaults to the main queue.
    /// - Returns: The promise's value or an error.
    func wait(on queue: DispatchQueue = DispatchQueue.main) async throws -> Value {
        try await withCheckedThrowingContinuation { continuation in
            self.then(on: queue) { value in
                continuation.resume(with: .success(value))
            } onRejected: { error in
                continuation.resume(with: .failure(error))
            }
        }
    }
}

public typealias AnyPromise = Promise<Any>
public typealias VoidPromise = Promise<Void>
public typealias BoolPromise = Promise<Bool>
public typealias IntPromise = Promise<Int>
public typealias StringPromise = Promise<String>
public typealias DataPromise = Promise<Data>
public typealias DictPromise = Promise<[String: Any]>
public typealias ArrayPromise<Element> = Promise<[Element]>
public typealias JSONPromise = Promise<JSON>

