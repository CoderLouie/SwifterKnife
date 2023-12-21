//
//  RangeReplaceableCollection+Add.swift
//  SwifterKnife
//
//  Created by liyang on 2021/10/19.
// 

// MARK: - Methods

public extension RangeReplaceableCollection {
    
    /// Removes the first element of the collection which satisfies the given predicate.
    ///
    ///        [1, 2, 2, 3, 4, 2, 5].removeFirst { $0 % 2 == 0 } -> [1, 2, 3, 4, 2, 5]
    ///        ["h", "e", "l", "l", "o"].removeFirst { $0 == "e" } -> ["h", "l", "l", "o"]
    ///
    /// - Parameter predicate: A closure that takes an element as its argument and returns a Boolean value that indicates whether the passed element represents a match.
    /// - Returns: The first element for which predicate returns true, after removing it. If no elements in the collection satisfy the given predicate, returns `nil`.
    @discardableResult
    mutating func removeFirst(where predicate: (Element) throws -> Bool) rethrows -> Element? {
        guard let index = try firstIndex(where: predicate) else { return nil }
        return remove(at: index)
    }
    
    /// Remove a random value from the collection.
    @discardableResult
    mutating func removeRandomElement() -> Element? {
        guard let randomIndex = indices.randomElement() else { return nil }
        return remove(at: randomIndex)
    }
    
    /// Keep elements of Array while condition is true.
    ///
    ///        [0, 2, 4, 7].keep(while: { $0 % 2 == 0 }) -> [0, 2, 4]
    ///
    /// - Parameter condition: condition to evaluate each element against.
    /// - Returns: self after applying provided condition.
    /// - Throws: provided condition exception.
    @discardableResult
    mutating func keep(while condition: (Element) throws -> Bool) rethrows -> Self {
        if let idx = try firstIndex(where: { try !condition($0) }) {
            removeSubrange(idx...)
        }
        return self
    }
    
    /// Take element of Array while condition is true.
    ///
    ///        [0, 2, 4, 7, 6, 8].take( where: {$0 % 2 == 0}) -> [0, 2, 4]
    ///
    /// - Parameter condition: condition to evaluate each element against.
    /// - Returns: All elements up until condition evaluates to false.
    func take(while condition: (Element) throws -> Bool) rethrows -> Self {
        return try Self(prefix(while: condition))
    }
    
    /// Skip elements of Array while condition is true.
    ///
    ///        [0, 2, 4, 7, 6, 8].skip( where: {$0 % 2 == 0}) -> [6, 8]
    ///
    /// - Parameter condition: condition to evaluate each element against.
    /// - Returns: All elements after the condition evaluates to false.
    func skip(while condition: (Element) throws -> Bool) rethrows -> Self {
        guard let idx = try firstIndex(where: { try !condition($0) }) else { return Self() }
        return Self(self[idx...])
    }
    
    /// Remove all duplicate elements using KeyPath to compare.
    ///
    /// - Parameter path: Key path to compare, the value must be Equatable.
    mutating func removeDuplicates<E: Equatable>(keyPath path: KeyPath<Element, E>) {
        var items = [Element]()
        removeAll { element -> Bool in
            guard items.contains(where: { $0[keyPath: path] == element[keyPath: path] }) else {
                items.append(element)
                return false
            }
            return true
        }
    }
    
    /// Remove all duplicate elements using KeyPath to compare.
    ///
    /// - Parameter path: Key path to compare, the value must be Hashable.
    mutating func removeDuplicates<E: Hashable>(keyPath path: KeyPath<Element, E>) {
        var set = Set<E>()
        removeAll { !set.insert($0[keyPath: path]).inserted }
    }
    
    /// Accesses a contiguous subrange of the collection’s elements.
    ///
    /// - Parameter range: A range of the collection’s indices offsets. The bounds of the range must be valid indices of the collection.
    subscript<R>(range: R) -> SubSequence where R: RangeExpression, R.Bound == Int {
        get {
            let indexRange = range.relative(to: 0..<count)
            return self[index(startIndex, offsetBy: indexRange.lowerBound)..<index(startIndex,
                                                                                   offsetBy: indexRange.upperBound)]
        }
        set {
            let indexRange = range.relative(to: 0..<count)
            replaceSubrange(
                index(startIndex, offsetBy: indexRange.lowerBound)..<index(startIndex, offsetBy: indexRange.upperBound),
                with: newValue)
        }
    }
    
    
    
    @discardableResult
    mutating func prependIfNonNil(_ newElement: Element?) -> Bool {
        guard let newElement = newElement else { return false }
        insert(newElement, at: startIndex)
        return true
    }
    /**
     Adds a new element at the end of the array, mutates the array in place
     - Parameter newElement: The optional element to append to the array
     */
    @discardableResult
    mutating func appendIfNonNil(_ newElement: Element?) -> Bool {
        guard let newElement = newElement else { return false }
        append(newElement)
        return true
    }
    
    /**
     Adds the elements of a sequence to the end of the array, mutates the array in place
     - Parameter newElements: The optional sequence to append to the array
     */
    mutating func appendIfNonNil<S>(contentsOf newElements: S?) where Element == S.Element, S : Sequence {
        guard let newElements = newElements else { return }
        append(contentsOf: newElements)
    }
}

public extension RangeReplaceableCollection where Self: BidirectionalCollection {
    
    ///     var nums = [1, 2, 3, 4, 5, 6]
    ///     print(nums.omitAll { $1 % 2 != 0 }, nums)
    ///     output: [1, 3, 5] [2, 4, 6]
    @discardableResult
    mutating func omitAll(where shouldBeRemoved: (Index, Element) throws -> Bool) rethrows -> [Element] {
        var removed: [Element] = []
        var index = endIndex
        while index > startIndex {
            formIndex(before: &index)
            let element = self[index]
            guard try shouldBeRemoved(index, element) else { continue }
            removed.append(remove(at: index))
        }
        return removed.reversed()
    }
}

public extension RangeReplaceableCollection {
    @inlinable
    init(capacity: Int) {
        self.init()
        reserveCapacity(capacity)
    }
}
public extension RangeReplaceableCollection where Self: BidirectionalCollection & MutableCollection {
    var theFirst: Element? {
        get { first }
        set {
            if let val = newValue {
                self[startIndex] = val
            } else {
                removeFirst()
            }
        }
    }
    var theLast: Element? {
        get { last }
        set {
            if let val = newValue {
                if let lastIdx = lastIndex {
                    self[lastIdx] = val
                } else {
                    append(val)
                }
            } else {
                _ = popLast()
            }
        }
    }
}
