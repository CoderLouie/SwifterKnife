//
//  Async.swift
//
//  Created by Tobias DM on 15/07/14.
//
//	OS X 10.10+ and iOS 8.0+
//	Only use with ARC
//
//	The MIT License (MIT)
//	Copyright (c) 2014 Tobias Due Munk
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy of
//	this software and associated documentation files (the "Software"), to deal in
//	the Software without restriction, including without limitation the rights to
//	use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
//	the Software, and to permit persons to whom the Software is furnished to do so,
//	subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in all
//	copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
//	FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
//	COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
//	IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//	CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


import Foundation

// MARK: - DSL for GCD queues

/**
 `GCD` is a convenience enum with cases to get `DispatchQueue` of different quality of service classes, as provided by `DispatchQueue.global` or `DispatchQueue` for main thread or a specific custom queue.

 let mainQueue = GCD.main
 let utilityQueue = GCD.utility
 let customQueue = GCD.custom(queue: aDispatchQueue)

 - SeeAlso: Grand Central Dispatch
 */
// MARK: - Async – Struct

/**
The **Async** struct is the main part of the Async.framework. Handles an internally `@convention(block) () -> Swift.Void`.

Chainable dispatch blocks with GCD:

    Async.background {
    // Run on background queue
    }.main {
    // Run on main queue, after the previous block
    }

All moderns queue classes:

    Async.main {}
    Async.userInteractive {}
    Async.userInitiated {}
    Async.utility {}
    Async.background {}

Custom queues:

    let customQueue = dispatch_queue_create("Label", DISPATCH_QUEUE_CONCURRENT)
    Async.custom(customQueue) {}

Dispatch block after delay:

    let seconds = 0.5
    Async.main(after: seconds) {}

Cancel blocks not yet dispatched

    let block1 = Async.background {
        // Some work
    }
    let block2 = block1.background {
        // Some other work
    }
    Async.main {
        // Cancel async to allow block1 to begin
        block1.cancel() // First block is NOT cancelled
        block2.cancel() // Second block IS cancelled
    }

Wait for block to finish:

    let block = Async.background {
        // Do stuff
    }
    // Do other stuff
    // Wait for "Do stuff" to finish
    block.wait()
    // Do rest of stuff

- SeeAlso: Grand Central Dispatch
*/

private class Reference<T> {
    var value: T?
}

public struct Async<In, Out> {
    // MARK: - Private properties and init

    /**
     Private property to hold internally on to a `@convention(block) () -> Swift.Void`
    */
    private let block: DispatchWorkItem

    private let input: Reference<In>?
    private let output_: Reference<Out>
    public var output: Out? {
        return output_.value
    }

    /**
     Private init that takes a `@convention(block) () -> Swift.Void`
     */
    private init(_ item: DispatchWorkItem, input: Reference<In>? = nil, output: Reference<Out> = Reference()) {
        self.block = item
        self.input = input
        self.output_ = output
    }


    // MARK: - Static methods

    /**
    Sends the a block to be run asynchronously on the main thread.

    - parameters:
        - after: After how many seconds the block should be run.
        - block: The block that is to be passed to be run on the main queue

    - returns: An `Async` struct

    - SeeAlso: Has parity with non-static method
    */
    @discardableResult
    public static func main<O>(after seconds: Double? = nil, _ block: @escaping () -> O) -> Async<Void, O> {
        return Async.async(after: seconds, block: block, queue: .main)
    }

    /**
     Sends the a block to be run asynchronously on a queue with a quality of service of QOS_CLASS_BACKGROUND.

     - parameters:
        - after: After how many seconds the block should be run.
        - block: The block that is to be passed to be run on the queue

     - returns: An `Async` struct

     - SeeAlso: Has parity with non-static method
     */
    @discardableResult
    public static func global<O>(qos: DispatchQoS.QoSClass = .default, after seconds: Double? = nil, _ block: @escaping () -> O) -> Async<Void, O> {
        return Async.async(after: seconds, block: block, queue: .global(qos: qos))
    }

    /**
     Sends the a block to be run asynchronously on a custom queue.

     - parameters:
        - after: After how many seconds the block should be run.
        - block: The block that is to be passed to be run on the queue

     - returns: An `Async` struct

     - SeeAlso: Has parity with non-static method
     */
    @discardableResult
    public static func custom<O>(queue: DispatchQueue, after seconds: Double? = nil, _ block: @escaping () -> O) -> Async<Void, O> {
        return Async.async(after: seconds, block: block, queue: queue)
    }


    // MARK: - Private static methods

    /**
     Convenience for dispatch_async(). Encapsulates the block in a "true" GCD block using DISPATCH_BLOCK_INHERIT_QOS_CLASS.

     - parameters:
         - block: The block that is to be passed to be run on the `queue`
         - queue: The queue on which the `block` is run.

     - returns: An `Async` struct which encapsulates the `@convention(block) () -> Swift.Void`
     */

    private static func async<O>(after seconds: Double? = nil, block: @escaping () -> O, queue: DispatchQueue) -> Async<Void, O> {
        let reference = Reference<O>()
        let item = DispatchWorkItem {
            reference.value = block()
        }

        if let seconds = seconds {
            let time = DispatchTime.now() + seconds
            queue.asyncAfter(deadline: time, execute: item)
        } else {
            queue.async(execute: item)
        }

        // Wrap block in a struct since @convention(block) () -> Swift.Void can't be extended
        return Async<Void, O>(item, output: reference)
    }


    // MARK: - Instance methods (matches static ones)

    /**
    Sends the a block to be run asynchronously on the main thread, after the current block has finished.

    - parameters:
        - after: After how many seconds the block should be run.
        - block: The block that is to be passed to be run on the main queue

    - returns: An `Async` struct

    - SeeAlso: Has parity with static method
    */
    @discardableResult
    public func main<O>(after seconds: Double? = nil, _ chainingBlock: @escaping (Out) -> O) -> Async<Out, O> {
        return chain(after: seconds, block: chainingBlock, queue: .main)
    }
    
    /**
     Sends the a block to be run asynchronously on a queue with a quality of service of QOS_CLASS_BACKGROUND, after the current block has finished.

     - parameters:
         - after: After how many seconds the block should be run.
         - block: The block that is to be passed to be run on the queue

     - returns: An `Async` struct

     - SeeAlso: Has parity with static method
     */
    @discardableResult
    public func global<O>(qos: DispatchQoS.QoSClass = .default,
                          after seconds: Double? = nil, _
                          chainingBlock: @escaping (Out) -> O) -> Async<Out, O> {
        return chain(after: seconds, block: chainingBlock, queue: .global(qos: qos))
    }

    /**
     Sends the a block to be run asynchronously on a custom queue, after the current block has finished.

     - parameters:
         - after: After how many seconds the block should be run.
         - block: The block that is to be passed to be run on the queue

     - returns: An `Async` struct

     - SeeAlso: Has parity with static method
     */
    @discardableResult
    public func custom<O>(queue: DispatchQueue, after seconds: Double? = nil, _ chainingBlock: @escaping (Out) -> O) -> Async<Out, O> {
        return chain(after: seconds, block: chainingBlock, queue: queue)
    }

    // MARK: - Instance methods

    /**
    Convenience function to call `dispatch_block_cancel()` on the encapsulated block.
    Cancels the current block, if it hasn't already begun running to GCD.

    Usage:

        let block1 = Async.background {
            // Some work
        }
        let block2 = block1.background {
            // Some other work
        }
        Async.main {
            // Cancel async to allow block1 to begin
            block1.cancel() // First block is NOT cancelled
            block2.cancel() // Second block IS cancelled
        }

    */
    public func cancel() {
        block.cancel()
    }

    public var isCancelled: Bool {
        block.isCancelled
    }

    /**
     Convenience function to call `dispatch_block_wait()` on the encapsulated block.
     Waits for the current block to finish, on any given thread.

     - parameters:
        - seconds: Max seconds to wait for block to finish. If value is 0.0, it uses DISPATCH_TIME_FOREVER. Default value is 0.

     - SeeAlso: dispatch_block_wait, DISPATCH_TIME_FOREVER
     */
    @discardableResult
    public func wait(seconds: Double? = nil) -> DispatchTimeoutResult {
        let timeout = seconds
            .flatMap { DispatchTime.now() + $0 }
            ?? .distantFuture
        return block.wait(timeout: timeout)
    }


    // MARK: Private instance methods

    /**
     Convenience for `dispatch_block_notify()` to

     - parameters:
         - block: The block that is to be passed to be run on the `queue`
         - queue: The queue on which the `block` is run.

     - returns: An `Async` struct which encapsulates the `@convention(block) () -> Swift.Void`, which is called when the current block has finished.

     - SeeAlso: dispatch_block_notify, dispatch_block_create
     */

    private func chain<O>(after seconds: Double? = nil, block chainingBlock: @escaping (Out) -> O, queue: DispatchQueue) -> Async<Out, O> {
        let reference = Reference<O>()
        let dispatchWorkItem = DispatchWorkItem {
            reference.value = chainingBlock(self.output_.value!)
        }

        if let seconds = seconds {
            block.notify(queue: queue) {
                let time = DispatchTime.now() + seconds
                queue.asyncAfter(deadline: time, execute: dispatchWorkItem)
            }
        } else {
            block.notify(queue: queue, execute: dispatchWorkItem)
        }

        // See Async.async() for comments
        return Async<Out, O>(dispatchWorkItem, input: self.output_, output: reference)
    }
}
 
// MARK: - Apply - DSL for `dispatch_apply`

/**
`Apply` is an empty struct with convenience static functions to parallelize a for-loop, as provided by `dispatch_apply`.

    Apply.background(100) { i in
        // Calls blocks in parallel
    }

`Apply` runs a block multiple times, before returning. If you want run the block asynchronously from the current thread, wrap it in an `Async` block:

    Async.background {
        Apply.background(100) { i in
            // Calls blocks in parallel asynchronously
        }
    }

- SeeAlso: Grand Central Dispatch, dispatch_apply
*/
public struct Apply {
  

    /**
     Block is run any given amount of times on a queue with a quality of service of QOS_CLASS_BACKGROUND. The block is being passed an index parameter.

     - parameters:
         - iterations: How many times the block should be run. Index provided to block goes from `0..<iterations`
         - block: The block that is to be passed to be run on a .
     */
    public static func global(
        qos: DispatchQoS.QoSClass = .default,
        _ iterations: Int,
        block: @escaping (Int) -> ()) {
        custom(queue: .global(qos: qos), iterations: iterations, block: block)
    }

    /**
     Block is run any given amount of times on a custom queue. The block is being passed an index parameter.

     - parameters:
         - iterations: How many times the block should be run. Index provided to block goes from `0..<iterations`
         - block: The block that is to be passed to be run on a .
     */
    public static func custom(queue: DispatchQueue, iterations: Int, block: @escaping (Int) -> ()) {
        queue.async {
            DispatchQueue.concurrentPerform(iterations: iterations, execute: block)
        }
    }
}


// MARK: - AsyncGroup – Struct

/**
The **AsyncGroup** struct facilitates working with groups of asynchronous blocks. Handles a internally `dispatch_group_t`.

Multiple dispatch blocks with GCD:

    let group = AsyncGroup()
    group.background {
        // Run on background queue
    }
    group.utility {
        // Run on untility queue, after the previous block
    }
    group.wait()

All moderns queue classes:

    group.main {}
    group.userInteractive {}
    group.userInitiated {}
    group.utility {}
    group.background {}

Custom queues:

    let customQueue = dispatch_queue_create("Label", DISPATCH_QUEUE_CONCURRENT)
    group.custom(customQueue) {}

Wait for group to finish:

    let group = AsyncGroup()
    group.background {
        // Do stuff
    }
    group.background {
        // Do other stuff in parallel
    }
    // Wait for both to finish
    group.wait()
    // Do rest of stuff

- SeeAlso: Grand Central Dispatch
*/
public struct AsyncGroup {

    // MARK: - Private properties and init

    /**
     Private property to internally on to a `dispatch_group_t`
    */
    private var group: DispatchGroup

    /**
     Private init that takes a `dispatch_group_t`
     */
    public init() {
        group = DispatchGroup()
    }

    /**
     Convenience for `dispatch_group_enter()`. Used to add custom blocks to the current group.

     - SeeAlso: dispatch_group_enter, dispatch_group_leave
     */
    public func enter() {
        group.enter()
    }

    /**
     Convenience for `dispatch_group_leave()`. Used to flag a custom added block is complete.

     - SeeAlso: dispatch_group_enter, dispatch_group_leave
     */
    public func leave() {
        group.leave()
    }


    // MARK: - Instance methods

    /**
    Sends the a block to be run asynchronously on the main thread, in the current group.

    - parameters:
        - block: The block that is to be passed to be run on the main queue
    */
    public func main(_ block: @escaping @convention(block) () -> Swift.Void) {
        async(block: block, queue: .main)
    }

    /**
     Sends the a block to be run asynchronously on a queue with a quality of service of QOS_CLASS_BACKGROUND, in the current block.

     - parameters:
         - block: The block that is to be passed to be run on the queue
     */
    public func global(
        qos: DispatchQoS.QoSClass = .default,
        _ block: @escaping @convention(block) () -> Swift.Void) {
        async(block: block, queue: .global(qos: qos))
    }
    
    /**
     Convenience for `dispatch_group_async()`

     - parameters:
         - block: The block that is to be passed to be run on the `queue`
         - queue: The queue on which the `block` is run.

     - SeeAlso: dispatch_group_async, dispatch_group_create
     */
    private func async(block: @escaping @convention(block) () -> Swift.Void, queue: DispatchQueue) {
        queue.async(group: group, execute: block)
    }
    
    /**
     Sends the a block to be run asynchronously on a custom queue, in the current group.

     - parameters:
         - queue: Custom queue where the block will be run.
         - block: The block that is to be passed to be run on the queue
     */
    public func custom(queue: DispatchQueue, block: @escaping @convention(block) () -> Swift.Void) {
        queue.async(group: group, execute: block)
    }
    
    
    /**
     Convenience function to call `dispatch_group_wait()` on the encapsulated block.
     Waits for the current group to finish, on any given thread.

     - parameters:
         - seconds: Max seconds to wait for block to finish. If value is nil, it uses DISPATCH_TIME_FOREVER. Default value is nil.

     - SeeAlso: dispatch_group_wait, DISPATCH_TIME_FOREVER
     */
    @discardableResult
    public func wait(seconds: Double? = nil) -> DispatchTimeoutResult {
        let timeout = seconds
            .flatMap { DispatchTime.now() + $0 }
            ?? .distantFuture
        return group.wait(timeout: timeout)
    }
    
    @discardableResult
    public func notify(
        on queue: DispatchQueue,
        execute: @escaping () -> Void) -> DispatchWorkItem {
        let item = DispatchWorkItem(block: execute)
        group.notify(queue: queue, work: item)
        return item
    }
}


// MARK: - Extension for `qos_class_t`

/**
Extension to add description string for each quality of service class.
*/
public extension qos_class_t {

    /**
     Description of the `qos_class_t`. E.g. "Main", "User Interactive", etc. for the given Quality of Service class.
     */
    var description: String {
        get {
            switch self {
            case qos_class_main(): return "Main"
            case DispatchQoS.QoSClass.userInteractive.rawValue: return "User Interactive"
            case DispatchQoS.QoSClass.userInitiated.rawValue: return "User Initiated"
            case DispatchQoS.QoSClass.default.rawValue: return "Default"
            case DispatchQoS.QoSClass.utility.rawValue: return "Utility"
            case DispatchQoS.QoSClass.background.rawValue: return "Background"
            case DispatchQoS.QoSClass.unspecified.rawValue: return "Unspecified"
            default: return "Unknown"
            }
        }
    }
}


// MARK: - Extension for `DispatchQueue.GlobalAttributes`

/**
 Extension to add description string for each quality of service class.
 */
public extension DispatchQoS.QoSClass {

    var description: String {
        get {
            switch self {
            case DispatchQoS.QoSClass(rawValue: qos_class_main())!: return "Main"
            case .userInteractive: return "User Interactive"
            case .userInitiated: return "User Initiated"
            case .default: return "Default"
            case .utility: return "Utility"
            case .background: return "Background"
            case .unspecified: return "Unspecified"
            @unknown default: return "unknown"
            }
        }
    }
}
