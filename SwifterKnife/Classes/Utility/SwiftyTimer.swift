//
// SwiftyTimer
//
// Copyright (c) 2015-2016 Radosław Pietruszewski
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

import Foundation

extension Timer {
    
// MARK: Schedule timers
    
    /// Create and schedule a timer that will call `block` once after the specified time.
    
    @discardableResult
    public class func after(_ interval: TimeInterval, _ block: @escaping () -> Void) -> Timer {
        let timer = Timer.new(after: interval, block)
        timer.start()
        return timer
    }
    
    /// Create and schedule a timer that will call `block` repeatedly in specified time intervals.
    
    @discardableResult
    public class func every(
        _ interval: TimeInterval,
        firesImmediately: Bool = false,
        _ block: @escaping () -> Void) -> Timer {
        let timer = Timer.new(every: interval, firesImmediately: firesImmediately, block)
        timer.start()
        return timer
    }
    
    /// Create and schedule a timer that will call `block` repeatedly in specified time intervals.
    /// (This variant also passes the timer instance to the block)
    
    @nonobjc @discardableResult
    public class func every(
        _ interval: TimeInterval,
        firesImmediately: Bool = false,
        _ block: @escaping (Timer) -> Void) -> Timer {
        let timer = Timer.new(every: interval, firesImmediately: firesImmediately, block)
        timer.start()
        return timer
    }
    
// MARK: Create timers without scheduling
    
    /// Create a timer that will call `block` once after the specified time.
    ///
    /// - Note: The timer won't fire until it's scheduled on the run loop.
    ///         Use `NSTimer.after` to create and schedule a timer in one step.
    /// - Note: The `new` class function is a workaround for a crashing bug when using convenience initializers (rdar://18720947)

    public class func new(after interval: TimeInterval, _ block: @escaping () -> Void) -> Timer {
        return CFRunLoopTimerCreateWithHandler(kCFAllocatorDefault, CFAbsoluteTimeGetCurrent() + interval, 0, 0, 0) { _ in
            block()
        }
    }
    
    /// Create a timer that will call `block` repeatedly in specified time intervals.
    ///
    /// - Note: The timer won't fire until it's scheduled on the run loop.
    ///         Use `NSTimer.every` to create and schedule a timer in one step.
    /// - Note: The `new` class function is a workaround for a crashing bug when using convenience initializers (rdar://18720947)

    public class func new(every interval: TimeInterval,
                          firesImmediately: Bool = false,
                          _ block: @escaping () -> Void) -> Timer {
        var fireDate = CFAbsoluteTimeGetCurrent()
        if !firesImmediately { fireDate += interval }
        
        return CFRunLoopTimerCreateWithHandler(
            kCFAllocatorDefault, fireDate, interval, 0, 0) { _ in
            block()
        }
    }
    public class func new<O: AnyObject>(every interval: TimeInterval,
                          associate obj: O,
                          firesImmediately: Bool = false,
                          _ block: @escaping (O) -> Void) -> Timer {
        var fireDate = CFAbsoluteTimeGetCurrent()
        if !firesImmediately { fireDate += interval }
        
        return CFRunLoopTimerCreateWithHandler(
            kCFAllocatorDefault, fireDate, interval, 0, 0) { [weak obj] tt in
            guard let o = obj else {
                if let t = tt { CFRunLoopTimerInvalidate(t) }
                return
            }
            block(o)
        }
    }
    /// Create a timer that will call `block` repeatedly in specified time intervals.
    /// (This variant also passes the timer instance to the block)
    ///
    /// - Note: The timer won't fire until it's scheduled on the run loop.
    ///         Use `NSTimer.every` to create and schedule a timer in one step.
    /// - Note: The `new` class function is a workaround for a crashing bug when using convenience initializers (rdar://18720947)
    
    @nonobjc public class func new(
        every interval: TimeInterval,
        firesImmediately: Bool = false,
        _ block: @escaping (Timer) -> Void) -> Timer {
        
        var fireDate = CFAbsoluteTimeGetCurrent()
        if !firesImmediately { fireDate += interval }
        return CFRunLoopTimerCreateWithHandler(
            kCFAllocatorDefault,
            fireDate, interval, 0, 0) { block($0!) }
    }
    
// MARK: Manual scheduling
    
    /// Schedule this timer on the run loop
    ///
    /// By default, the timer is scheduled on the current run loop for the default mode.
    /// Specify `runLoop` or `modes` to override these defaults.
    @discardableResult
    public func start(onRunLoop runLoop: RunLoop = .current, modes: RunLoop.Mode...) -> Timer {
        let modes = modes.isEmpty ? [.default] : modes
        
        for mode in modes {
            runLoop.add(self, forMode: mode)
        }
        return self
    }
}

extension Timer {
    @discardableResult
    public func at_pause() -> Bool {
        guard isValid else { return false }
        fireDate = .distantFuture
        return true
    }
    
    @discardableResult
    public func at_resume(after seconds: TimeInterval = 0) -> Bool {
        guard isValid else { return false }
        fireDate = Date(timeIntervalSinceNow: seconds)
        return true
    }
}

// MARK: - Time extensions

extension TimeInterval {
    public var millisecond: TimeInterval { return self / 1000 }
    public var milliseconds: TimeInterval { return self / 1000 }
    public var ms: TimeInterval { return self / 1000 }
    
    public var second: TimeInterval { return self }
    public var seconds: TimeInterval { return self }
    
    public var minute: TimeInterval { return self * 60 }
    public var minutes: TimeInterval { return self * 60 }
    
    public var hour: TimeInterval { return self * 3600 }
    public var hours: TimeInterval { return self * 3600 }
    
    public var day: TimeInterval { return self * 3600 * 24 }
    public var days: TimeInterval { return self * 3600 * 24 }
}
 
public class DelayTimer {
    private var source: DispatchSourceTimer?
    private var work: (() -> Void)?
    private var timestamp: CFTimeInterval = 0
    private var interval: TimeInterval
    public init(after interval: TimeInterval, work: @escaping () -> Void) {
        self.interval = interval
        self.work = work
        self.source = makeTimer(interval)
    }
    private func makeTimer(_ interval: TimeInterval) -> DispatchSourceTimer {
        let source = DispatchSource.makeTimerSource(queue: .main)
        source.schedule(deadline: .now() + interval, repeating: interval)
        source.setEventHandler { [weak self] in
            self?.fire()
        }
        return source
    }
    public func active() {
        timestamp = CACurrentMediaTime()
        source?.activate()
    }
    private func fire() {
        let closure = work
        work = nil
        invalid()
        closure?() 
    }
    public func pause() {
        guard isValid else { return }
        let cost = CACurrentMediaTime() - timestamp
        let left = interval - cost
        guard left > 0 else { return }
        invalid()
        interval = left
    }
    public func resume() {
        guard isValid else { return }
        guard interval > 0 else { return }
        source = makeTimer(interval)
        active()
    }
    public func invalid() {
        work = nil
        source?.cancel()
        source = nil
    }
    public var isValid: Bool { source != nil && work != nil }
    public var isPaused: Bool {
        source == nil && work != nil
    }
}
