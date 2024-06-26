//
//  Optional+Add.swift
//  SwifterKnife
//
//  Created by liyang on 2021/10/19.
//

import Foundation


// MARK: - Methods

public extension Optional {
    
    /// Assign an optional value to a variable only if the value is not nil.
    ///
    ///     let someParameter: String? = nil
    ///     let parameters = [String: Any]() // Some parameters to be attached to a GET request
    ///     parameters[someKey] ??= someParameter // It won't be added to the parameters dict
    ///
    /// - Parameters:
    ///   - lhs: Any?
    ///   - rhs: Any?
    static func ??= (lhs: inout Optional, rhs: Optional) {
        guard let rhs = rhs else { return }
        lhs = rhs
    }
    static func ??= (lhs: inout Wrapped, rhs: Optional) {
        guard let rhs = rhs else { return }
        lhs = rhs
    }

    /// Assign an optional value to a variable only if the variable is nil.
    ///
    ///     var someText: String? = nil
    ///     let newText = "Foo"
    ///     let defaultText = "Bar"
    ///     someText ?= newText // someText is now "Foo" because it was nil before
    ///     someText ?= defaultText // someText doesn't change its value because it's not nil
    ///
    /// - Parameters:
    ///   - lhs: Any?
    ///   - rhs: Any?
    static func ?= (lhs: inout Optional, rhs: @autoclosure () -> Optional) {
        if lhs == nil {
            lhs = rhs()
        }
    }
    
    static func ?<<(lhs: inout Optional, rhs: @autoclosure () throws -> Wrapped) rethrows -> Wrapped {
        switch lhs {
        case let .some(value): return value
        case .none:
            let value = try rhs()
            lhs = .some(value)
            return value
        }
    }
    
    static func ???(optional: Optional, nilDescribing: @autoclosure () -> String) -> String {
        switch optional {
        case let .some(value): return String(describing: value)
        case .none: return nilDescribing()
        }
    }
    
    /*
     断言
     有条件：
     assert 当条件为 false 时，停止执行并输出信息。发布版本无效。
     precondition，当条件为 false 时，停止执行并输出信息。发布版本依然有效。
     
     无条件：
     fatalError 将接受一条信息，并且无条件地停止操作。
     assertionFailure，将接受一条信息，Debug环境下停止操作。
     */
//    static func !?(optional: Optional, nilDefault: @autoclosure () -> (value: Wrapped, message: String)) -> Wrapped {
//        if let x = optional { return x }
//        let info = nilDefault()
//        /// Debug模式下生效，Release模式下不会生效
//        assert(false, info.message)
//        return info.value
//    }
    /**
     因为对于返回 Void 的函数，使用可选链进行调用时将返回 Void?，所以利用这一点，你也可以 写一个非泛型的版本来检测一个可选链调用碰到 nil，且无操作的情况
     
     var output: String? = nil
     output?.write("something") !? "Wasn't expecting chained nil here"
     */
//    static func !?(optional: Optional, failureText: @autoclosure () -> String) where Wrapped == Void {
//        assert(optional != nil, failureText())
//    }
    
    func typeMap<T>(_ ifNone: @autoclosure () -> T, _ ifSome: (Wrapped) -> T) -> T {
        switch self {
        case .some(let x): return ifSome(x)
        case .none: return ifNone()
        }
    }
    func or(throws error: @autoclosure () -> Error) throws -> Wrapped {
        switch self {
        case .some(let x): return x
        case .none: throw error()
        }
    }
    
    var isNil: Bool {
        switch self {
        case .some: return false
        case .none: return true
        }
    }
    var isSome: Bool {
        switch self {
        case .some: return true
        case .none: return false
        }
    }
    
    func filter(_ predicate: (Wrapped) throws -> Bool) rethrows -> Optional {
        switch self {
        case .some(let x):
            return try predicate(x) ? self : .none
        case .none: return .none
        }
    }
    
    func modify(_ work: (inout Wrapped) throws -> Void) rethrows -> Optional {
        switch self {
        case .some(var x):
            try work(&x)
            return .some(x)
        case .none: return .none
        }
    }
}
public extension Optional where Wrapped: Swift.Error {
    var operateDesc: String {
        typeMap("成功") { "失败\($0)" }
    }
}
// MARK: - Methods (Collection)

public extension Optional where Wrapped: Collection {
    /// Check if optional is nil or empty collection.
    var isNilOrEmpty: Bool {
        return self?.isEmpty ?? true
    }

    var isValid: Bool {
        if let c = self, !c.isEmpty { return true }
        return false
    }
    /// Returns the collection only if it is not nil and not empty.
    var nonEmpty: Wrapped? {
        return (self?.isEmpty ?? true) ? nil : self
    }
}

// MARK: - Operators

infix operator ??=: AssignmentPrecedence
infix operator ?=: AssignmentPrecedence

infix operator ???: NilCoalescingPrecedence
infix operator ?<<: NilCoalescingPrecedence

//infix operator !!
//
//infix operator !?


public func zip<A, B>(_ lhs: A?,
                      _ rhs: @autoclosure () -> B?) -> (A, B)? {
    if let x = lhs, let y = rhs() {
        return (x, y)
    }
    return nil
}

public func zip<A, B, C>(_ a: A?,
                         _ b: @autoclosure () -> B?,
                         _ c: @autoclosure () -> C?) -> (A, B, C)? {
    if let x = a, let y = b(), let z = c() {
        return (x, y, z)
    }
    return nil
}
 

// MARK: - Methods (RawRepresentable, RawValue: Equatable)
public extension Optional where Wrapped: RawRepresentable, Wrapped.RawValue: Equatable {
 
    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    @inlinable static func == (lhs: Optional, rhs: Wrapped.RawValue?) -> Bool {
        return lhs?.rawValue == rhs
    }

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    @inlinable static func == (lhs: Wrapped.RawValue?, rhs: Optional) -> Bool {
        return lhs == rhs?.rawValue
    }

    /// Returns a Boolean value indicating whether two values are not equal.
    ///
    /// Inequality is the inverse of equality. For any values `a` and `b`,
    /// `a != b` implies that `a == b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    @inlinable static func != (lhs: Optional, rhs: Wrapped.RawValue?) -> Bool {
        return lhs?.rawValue != rhs
    }

    /// Returns a Boolean value indicating whether two values are not equal.
    ///
    /// Inequality is the inverse of equality. For any values `a` and `b`,
    /// `a != b` implies that `a == b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    @inlinable static func != (lhs: Wrapped.RawValue?, rhs: Optional) -> Bool {
        return lhs != rhs?.rawValue
    }

}

