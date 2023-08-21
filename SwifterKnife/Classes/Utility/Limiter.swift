//
//  Limiter.swift
//  SwifterKnife
//
//  Created by liyang on 2023/1/5.
//

import Foundation

// MARK: - SyncLimiter
public protocol SyncLimiter {
    @discardableResult
    func execute(_ block: () -> Void) -> Bool
    func reset()
}
extension SyncLimiter {
    public func execute<T>(_ block: () -> T) -> T? {
        var value: T? = nil
        execute { value = block() }
        return value
    }
}

// MARK: TimedLimiter
public final class TimedLimiter: SyncLimiter {
    public let limit: TimeInterval
    public private(set) var lastExecutedTime: CFTimeInterval = 0

    private let syncQueue = DispatchQueue(label: "com.samsoffes.ratelimit", attributes: [])

    public init(limit: TimeInterval) {
        self.limit = limit
    }
 
    @discardableResult
    public func execute(_ block: () -> Void) -> Bool {
        let executed = syncQueue.sync { () -> Bool in
            let now = CACurrentMediaTime()
            let timeInterval = now - lastExecutedTime

            // If the time since last execution is greater than the limit, execute
            if timeInterval > limit {
                lastExecutedTime = now
                return true
            }
            return false
        }
        if executed { block() }

        return executed
    }

    public func reset() {
        syncQueue.sync {
            lastExecutedTime = 0
        }
    }
}

// MARK: CountedLimiter
public final class CountedLimiter: SyncLimiter {

    public let limit: UInt
    public private(set) var count: UInt = 0

    private let syncQueue = DispatchQueue(label: "com.samsoffes.ratelimit", attributes: [])
 
    public init(limit: UInt) {
        self.limit = limit
    }
 
    @discardableResult
    public func execute(_ block: () -> Void) -> Bool {
        let executed = syncQueue.sync { () -> Bool in
            if count < limit {
                count += 1
                return true
            }
            return false
        }

        if executed { block() }

        return executed
    }

    public func reset() {
        syncQueue.sync {
            count = 0
        }
    }
}
 
// MARK: - DebouncedLimiter
public final class DebouncedLimiter {

    public let limit: TimeInterval
    public let block: (Any) -> Void
    public let queue: DispatchQueue

    private var workItem: DispatchWorkItem?
    private let syncQueue = DispatchQueue(label: "com.samsoffes.ratelimit.debounced", attributes: [])
 
    public init(limit: TimeInterval, queue: DispatchQueue = .main, block: @escaping (Any) -> Void) {
        self.limit = limit
        self.block = block
        self.queue = queue
    }
 
    @objc public func execute(param: Any) {
        syncQueue.async { [weak self] in
            guard let this = self else { return }
            if let workItem = this.workItem {
                workItem.cancel()
                this.workItem = nil
            }

            let workItem = DispatchWorkItem {
                self?.block(param)
            }
            this.queue.asyncAfter(deadline: .now() + this.limit, execute: workItem)
            this.workItem = workItem
        }
    }
    @objc public func execute() {
        execute(param: ())
    }

    public func reset() {
        syncQueue.async { [weak self] in
            if let workItem = self?.workItem {
                workItem.cancel()
                self?.workItem = nil
            }
        }
    }
}
