//
//  DispatchQueue+Add.swift
//  SwifterKnife
//
//  Created by liyang on 2021/10/19.
//

import Dispatch

// MARK: - Properties
public extension DispatchQueue {

    /// A Boolean value indicating whether the current dispatch queue is the main queue.
    static var isMainQueue: Bool {
        DispatchQueue.currentLabel == DispatchQueue.main.label
    }

    
    static var currentLabel: String {
        let label = __dispatch_queue_get_label(nil)
        return String(cString: label, encoding: .utf8) ?? ""
    }
}

// MARK: - Methods
public extension DispatchQueue {

    /// Returns a Boolean value indicating whether the current dispatch queue is the specified queue.
    ///
    /// - Parameter queue: The queue to compare against.
    /// - Returns: `true` if the current queue is the specified queue, otherwise `false`.
    static func isCurrent(_ queue: DispatchQueue) -> Bool {
        let key = DispatchSpecificKey<Void>()

        queue.setSpecific(key: key, value: ())
        defer { queue.setSpecific(key: key, value: nil) }

        return DispatchQueue.getSpecific(key: key) != nil
    }

}

import Foundation

public extension DispatchQueue {
    var userInteractive: DispatchQueue {
        .global(qos: .userInteractive)
    }
    var userInitiated: DispatchQueue {
        .global(qos: .userInitiated)
    }
    var utility: DispatchQueue {
        .global(qos: .utility)
    }
    var background: DispatchQueue {
        .global(qos: .background)
    }
    var `default`: DispatchQueue {
        .global(qos: .default)
    }
}

public extension DispatchQueue {
    /// Execute the provided closure after a `TimeInterval`.
    ///
    /// - Parameters:
    ///   - delay:   `TimeInterval` to delay execution.
    ///   - closure: Closure to execute.
    func after(_ delay: TimeInterval, execute closure: @escaping () -> Void) {
        asyncAfter(deadline: .now() + delay, execute: closure)
    }
    
    /// 可以取消
    func afterItem(_ delay: TimeInterval, execute closure: @escaping () -> Void) -> DispatchWorkItem {
        let item = DispatchWorkItem(block: closure)
        asyncAfter(deadline: .now() + delay, execute: item)
        return item
    }
    
    
    private static var _onceTracker: Set<String> = []
    
    @discardableResult
    static func once(file: String = #file, function: String = #function, line: Int = #line, block: () -> Void) -> String {
        let token = [file, function, String(line)].joined(separator: ":")
        once(token: token, block: block)
        return token
    }
    
    /**
     Executes a block of code, associated with a unique token, only once.  The code is thread safe and will
     only execute the code once even in the presence of multithreaded calls.
     
     - parameter token: A unique reverse DNS style name such as com.vectorform.<name> or a GUID
     - parameter block: Block to execute once
     */
    static func once(token: String, block:() -> Void) {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        
        if _onceTracker.contains(token) { return }
        
        _onceTracker.insert(token)
        block()
    }
    
    static func deonce(_ token: String) {
        _onceTracker.remove(token)
    }
}
