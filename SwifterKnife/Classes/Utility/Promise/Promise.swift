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
    public convenience init(
        queue: DispatchQueue = .global(qos: .userInitiated),
        value: Value?,
        work: @escaping (
            _ fulfill: @escaping (Value) -> Void,
            _ reject: @escaping (Error) -> Void) throws -> Void) {
        if let v = value {
            self.init(value: v)
        } else {
            self.init(queue: queue, work: work)
        }
    }

    /// - note: This one is "flatMap"
    @discardableResult
    public func then<NewValue>(
        on queue: ExecutionContext = DispatchQueue.main,
        _ onFulfilled: @escaping (Value) throws -> Promise<NewValue>) -> Promise<NewValue> {
        return Promise<NewValue> { fulfill, reject in
            self.addCallbacks(
                on: queue,
                onFulfilled: { value in
                    do {
                        try onFulfilled(value).then(on: queue, fulfill, reject)
                    } catch {
                        reject(error)
                    }
                },
                onRejected: reject
            )
        }
    }
    
    /// - note: This one is "map"
    @discardableResult
    public func then<NewValue>(
        on queue: ExecutionContext = DispatchQueue.main, _
        onFulfilled: @escaping (Value) throws -> NewValue) -> Promise<NewValue> {
        return then(on: queue) { (value) -> Promise<NewValue> in
            do {
                return Promise<NewValue>(value: try onFulfilled(value))
            } catch {
                return Promise<NewValue>(error: error)
            }
        }
    }
    
    @discardableResult
    public func then(
        on queue: ExecutionContext = DispatchQueue.main,
        _ onFulfilled: @escaping (Value) -> Void,
        _ onRejected: @escaping (Error) -> Void = { _ in })
    -> Promise<Value> {
        addCallbacks(on: queue, onFulfilled: onFulfilled, onRejected: onRejected)
        return self
    }
    
    @discardableResult
    public func catchs(
        on queue: ExecutionContext = DispatchQueue.main,
        _ onRejected: @escaping (Error) -> Void) ->
    Promise<Value> {
        return then(on: queue, { _ in }, onRejected)
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
