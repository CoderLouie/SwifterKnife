//
//  Throttle.swift
//  SwifterKnife
//
//  Created by liyang on 2022/3/28.
//

import Foundation

@propertyWrapper
public final class Throttled<T> {
    private let throttler: Throttler<T>
    
    public init(_ interval: TimeInterval, on queue: DispatchQueue = .main) {
        throttler = Throttler(interval, on: queue)
    }
    public func receive(_ value: T) {
        throttler.receive(value)
    }
    public func on(throttled: @escaping (T) -> ()) {
        throttler.on(throttled: throttled)
    }
    public var wrappedValue: T? {
        get { throttler.value }
        set(v) { if let v = v { throttler.receive(v) } }
    }
}

public final class Throttler<T> {
    private(set) var value: T? = nil
    private var timestamp: TimeInterval?
    private var interval: TimeInterval
    private var queue: DispatchQueue
    private var callbacks: [(T) -> ()] = []
    
    public init(_ interval: TimeInterval, on queue: DispatchQueue = .main) {
        self.interval = interval
        self.queue = queue
    }
    public func receive(_ value: T) {
        self.value = value
        guard timestamp == nil else { return }
        dispatchThrottle()
    }
    public func on(throttled: @escaping (T) -> ()) {
        callbacks.append(throttled)
    }
    private func dispatchThrottle() {
        timestamp = Date().timeIntervalSince1970
        queue.asyncAfter(deadline: .now() + interval) { [weak self] in
            self?.onDispatch()
        }
    }
    private func onDispatch() {
        timestamp = nil
        if let value = self.value { callbacks.forEach { $0(value) } }
    }
}
