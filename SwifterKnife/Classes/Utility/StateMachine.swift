//
//  StateMachine.swift
//  SwifterKnife
//
//  Created by liyang on 2023/1/5.
//

import Foundation

// https://mp.weixin.qq.com/s/Y4Ta8xPmZunIHxNHl6rGGw

public protocol IState: Hashable {}

public protocol IEvent: Hashable {}

public final class StateMachine<S: IState, E: IEvent> {
    public private(set) var currentState: S
    
    public init(_ initialState: S) {
        currentState = initialState
    }
    
    public struct Transition {
        public let event: E
        public let fromState: S
        public let toState: S
        init(event: E, fromState: S, toState: S) {
            self.event = event
            self.fromState = fromState
            self.toState = toState
        }
    }
    
    private struct Operation {
        let transition: Transition
        let triggerCallback: (Transition) -> Void
        
        func trigger() {
            triggerCallback(transition)
        }
    }
    private var routes: [S: [E: Operation]] = [:]
    
    private struct StateRecord {
        var enter: ((S, S) -> Void)?
        var leave: ((S, S) -> Void)?
    }
    private lazy var stateRecords: [S: StateRecord] = [:]

    public func onLeaveState(_ state: S, closure: @escaping (_ old: S, _ new: S) -> Void) {
        var record = stateRecords[state] ?? StateRecord()
        record.leave = closure
        stateRecords[state] = record
    }
    public func onEnterState(_ state: S, closure: @escaping (_ old: S, _ new: S) -> Void) {
        var record = stateRecords[state] ?? StateRecord()
        record.enter = closure
        stateRecords[state] = record
    }
    
    
    private struct EventRecord {
        var before: ((E) -> Void)?
        var after: ((E) -> Void)?
    }
    private lazy var eventRecords: [E: EventRecord] = [:]

    public func onBeforeEvent(_ event: E, closure: @escaping (E) -> Void) {
        var record = eventRecords[event] ?? EventRecord()
        record.before = closure
        eventRecords[event] = record
    }
    public func onAfterEvent(_ event: E, closure: @escaping (E) -> Void) {
        var record = eventRecords[event] ?? EventRecord()
        record.after = closure
        eventRecords[event] = record
    }
    
    public func listen(_ event: E, transit fromState: S, to toState: S, callback: @escaping (Transition) -> Void) {
        guard fromState != toState else {
            fatalError("fromState \(fromState) and toState \(toState) must not be equal")
        }
        // 当前状态，当前状态可能会有多个转变，比如  A->B，或者 A -> C
        var route = routes[fromState] ?? [:]
        let transition = Transition(event: event, fromState: fromState, toState: toState)
        let operation = Operation(transition: transition, triggerCallback: callback)
        route[event] = operation
        routes[fromState] = route
    }
    
    public func trigger(_ event: E) {
        guard let operation = routes[currentState]?[event] else { return }
        eventRecords[event]?.before?(event)
        // 状态切换
        let oldState = currentState
        let newState = operation.transition.toState
        stateRecords[oldState]?.leave?(oldState, newState)
        currentState = newState
        stateRecords[newState]?.enter?(oldState, newState)
        // 事件触发的回调
        operation.trigger()
        eventRecords[event]?.after?(event)
    }
}
