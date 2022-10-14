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
}

public final class Promise<Value> {
    
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
    /*
    public convenience init(
        queue: DispatchQueue = .global(qos: .userInitiated),
        work: @escaping (
            _ fulfill: @escaping (Value) -> Void,
            _ reject: @escaping (Error) -> Void) throws -> Void) {
        self.init()
        queue.async {
            do {
                // 这样的写法Promise会立即释放
                let fulfill = { [weak self] (v: Value) -> Void in
                    guard let s = self else { return }
                    s.fulfill(v)
                }
                let reject = { [weak self] (e: Error) -> Void in
                    guard let s = self else { return }
                    s.reject(e)
                }
                try work(fulfill, reject)
            } catch {
                self.reject(error)
            }
        }
    }
     */
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

    public func flatMap<NewValue>(
        on queue: ExecutionContext = DispatchQueue.main,
        transform: @escaping (Value) throws -> Promise<NewValue>) -> Promise<NewValue> {
        return Promise<NewValue> { fulfill, reject in
            self.addCallbacks(
                on: queue,
                onFulfilled: { value in
                    do {
                        try transform(value).then(on: queue, onFulfilled: fulfill, onRejected: reject)
                    } catch {
                        reject(error)
                    }
                },
                onRejected: reject
            )
        }
    }

    public func map<NewValue>(
        on queue: ExecutionContext = DispatchQueue.main,
        transform: @escaping (Value) throws -> NewValue) -> Promise<NewValue> {
        return flatMap(on: queue) { (value) -> Promise<NewValue> in
            do {
                return Promise<NewValue>(value: try transform(value))
            } catch {
                return Promise<NewValue>(error: error)
            }
        }
    }
    
    public func mapError(
        on queue: ExecutionContext = DispatchQueue.main,
        transform: @escaping (Swift.Error) throws -> Swift.Error) -> Promise<Value> {
        return Promise<Value> { fulfill, reject in
            self.addCallbacks(
                on: queue,
                onFulfilled: fulfill) { error in
                    do {
                        let newError = try transform(error)
                        reject(newError)
                    } catch {
                        reject(error)
                    }
                }
        }
    }

    /**
     用于在catchs 方法中知道是第几步出错
     */
    public func step(
        _ s: Int,
        on queue: ExecutionContext = DispatchQueue.main) -> Promise<Value> {
        return mapError(on: queue) {
            return StepError(step: s, error: $0)
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

public typealias AnyPromise = Promise<Any>
public typealias VoidPromise = Promise<Void>
public typealias IntPromise = Promise<Int>
public typealias StringPromise = Promise<String>
public typealias DataPromise = Promise<Data>
public typealias JSONPromise = Promise<[String: Any]>
public typealias ArrayPromise<Element> = Promise<[Element]>
