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
    
    static func <>= (lhs: inout Self, rhs: ClosedRange<Self>) {
        lhs = max(rhs.lowerBound, min(lhs, rhs.upperBound))
    }
}
infix operator <>=: AssignmentPrecedence
