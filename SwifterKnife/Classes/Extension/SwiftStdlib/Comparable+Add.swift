//
//  Comparable+Add.swift
//  SwifterKnife
//
//  Created by liyang on 2021/10/19.
//

// MARK: - Methods

public extension Comparable {
    /// Returns true if value is in the provided range.
    ///
    ///    1.isBetween(5...7) // false
    ///    7.isBetween(6...12) // true
    ///    date.isBetween(date1...date2)
    ///    "c".isBetween(a...d) // true
    ///    0.32.isBetween(0.31...0.33) // true
    ///
    /// - Parameter range: Closed range against which the value is checked to be included.
    /// - Returns: `true` if the value is included in the range, `false` otherwise.
    func isBetween(_ range: ClosedRange<Self>) -> Bool {
        return range ~= self
    }

    /// Returns value limited within the provided range.
    ///
    ///     1.clamped(to: 3...8) // 3
    ///     4.clamped(to: 3...7) // 4
    ///     "c".clamped(to: "e"..."g") // "e"
    ///     0.32.clamped(to: 0.1...0.29) // 0.29
    ///
    /// - Parameter range: Closed range that limits the value.
    /// - Returns: A value limited to the range, i.e. between `range.lowerBound` and `range.upperBound`.
    func clamped(to range: ClosedRange<Self>) -> Self {
        return max(range.lowerBound, min(self, range.upperBound))
    }
    /**
     var num = 3
     num <>= 5...7
     print(num) 5
     */
    static func <>= (lhs: inout Self, rhs: ClosedRange<Self>) {
        lhs = max(rhs.lowerBound, min(lhs, rhs.upperBound))
    }
}
infix operator <>=: AssignmentPrecedence


@inlinable public func sk_min<T>(_ x: T, _ y: T) -> (T, Bool) where T : Comparable {
    if x < y { return (x, true) }
    return (y, false)
}
@inlinable public func sk_max<T>(_ x: T, _ y: T) -> (T, Bool) where T : Comparable {
    if x > y { return (x, true) }
    return (y, false)
}


public extension Comparable {
    
    /// Compares the reciever with another and returns their order.
    func sk_compare(_ other: Self) -> ComparisonResult {
        if self < other {
            return .orderedAscending
        }
        if self > other {
            return .orderedDescending
        }
        return .orderedSame
    }
}



extension Hashable {
    public func inSet(_ set: Set<Self>) -> Bool {
        set.contains(self)
    }
     
    public func pick<T>(in map: [Self: T]) -> T? {
        map[self]
    }
    public func pick<T>(in map: [Self: T?]) -> T? {
        if let v = map[self] { return v }
        return nil
    }
}
extension Equatable {
    public func inArray(_ array: Array<Self>) -> Bool {
        array.contains { $0 == self }
    }
}
