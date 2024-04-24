//
//  Sequence+Add.swift
//  SwifterKnife
//
//  Created by liyang on 2021/10/19.
//

public extension Sequence {
    
    func typedFirst<T>() -> T? {
        first { $0 is T } as? T
    } 
    
    func firstMap<T>(where predicate: (Self.Element) throws -> T?) rethrows -> T? {
        for element in self {
            if let tmp = try predicate(element) {
                return tmp
            }
        }
        return nil
    }
    
    /// Get element count based on condition.
    ///
    ///        [2, 2, 4, 7].count(where: {$0 % 2 == 0}) -> 3
    ///
    /// - Parameter condition: condition to evaluate each element against.
    /// - Returns: number of times the condition evaluated to true.
    func count(where condition: (Element) throws -> Bool) rethrows -> Int {
        var count = 0
        for element in self where try condition(element) {
            count += 1
        }
        return count
    }

    /// Calls the given closure with each element where condition is true.
    ///
    ///        [0, 2, 4, 7].forEach(where: {$0 % 2 == 0}, body: { print($0)}) -> // print: 0, 2, 4
    ///
    /// - Parameters:
    ///   - condition: condition to evaluate each element against.
    ///   - body: a closure that takes an element of the array as a parameter.
    func forEach(where condition: (Element) throws -> Bool, body: (Element) throws -> Void) rethrows {
        try lazy.filter(condition).forEach(body)
    }

    /// Reduces an array while returning each interim combination.
    ///
    ///     [1, 2, 3].accumulate(initial: 0, next: +) -> [1, 3, 6]
    ///
    /// - Parameters:
    ///   - initial: initial value.
    ///   - next: closure that combines the accumulating value and next element of the array.
    /// - Returns: an array of the final accumulated value and each interim combination.
    func accumulate<U>(initial: U, next: (U, Element) throws -> U) rethrows -> [U] {
        var runningTotal = initial
        return try map { element in
            runningTotal = try next(runningTotal, element)
            return runningTotal
        }
    }

    /// Filtered and map in a single operation.
    ///
    ///     [1,2,3,4,5].filtered({ $0 % 2 == 0 }, map: { $0.string }) -> ["2", "4"]
    ///
    /// - Parameters:
    ///   - isIncluded: condition of inclusion to evaluate each element against.
    ///   - transform: transform element function to evaluate every element.
    /// - Returns: Return an filtered and mapped array.
    func filtered<T>(_ isIncluded: (Element) throws -> Bool, map transform: (Element) throws -> T) rethrows -> [T] {
        return try lazy.filter(isIncluded).map(transform)
    }

    /// Get the only element based on a condition.
    ///
    ///     [].single(where: {_ in true}) -> nil
    ///     [4].single(where: {_ in true}) -> 4
    ///     [1, 4, 7].single(where: {$0 % 2 == 0}) -> 4
    ///     [2, 2, 4, 7].single(where: {$0 % 2 == 0}) -> nil
    ///
    /// - Parameter condition: condition to evaluate each element against.
    /// - Returns: The only element in the array matching the specified condition. If there are more matching elements, nil is returned. (optional)
    func single(where condition: (Element) throws -> Bool) rethrows -> Element? {
        var singleElement: Element?
        for element in self where try condition(element) {
            guard singleElement == nil else {
                singleElement = nil
                break
            }
            singleElement = element
        }
        return singleElement
    }

    /// Remove duplicate elements based on condition.
    ///
    ///        [1, 2, 1, 3, 2].withoutDuplicates { $0 } -> [1, 2, 3]
    ///        [(1, 4), (2, 2), (1, 3), (3, 2), (2, 1)].withoutDuplicates { $0.0 } -> [(1, 4), (2, 2), (3, 2)]
    ///
    /// - Parameter transform: A closure that should return the value to be evaluated for repeating elements.
    /// - Returns: Sequence without repeating elements
    /// - Complexity: O(*n*), where *n* is the length of the sequence.
    func withoutDuplicates<T: Hashable>(transform: (Element) throws -> T) rethrows -> [Element] {
        var set = Set<T>()
        return try filter { try set.insert(transform($0)).inserted }
    }

    ///  Separates all items into 2 lists based on a given predicate. The first list contains all items for which the specified condition evaluates to true. The second list contains those that don't.
    ///
    ///     let (even, odd) = [0, 1, 2, 3, 4, 5].divided { $0 % 2 == 0 }
    ///     let (minors, adults) = people.divided { $0.age < 18 }
    ///
    /// - Parameter condition: condition to evaluate each element against.
    /// - Returns: A tuple of matched and non-matched items
    func divided(by condition: (Element) throws -> Bool) rethrows -> (matching: [Element], nonMatching: [Element]) {
        // Inspired by: http://ruby-doc.org/core-2.5.0/Enumerable.html#method-i-partition
        var matching = [Element]()
        var nonMatching = [Element]()

        for element in self {
            try condition(element) ? matching.append(element) : nonMatching.append(element)
        }
        return (matching, nonMatching)
    }

    /// Return a sorted array based on a key path and a compare function.
    ///
    /// - Parameter keyPath: Key path to sort by.
    /// - Parameter compare: Comparison function that will determine the ordering.
    /// - Returns: The sorted array.
    func sorted<T>(by keyPath: KeyPath<Element, T>, with compare: (T, T) -> Bool) -> [Element] {
        return sorted { compare($0[keyPath: keyPath], $1[keyPath: keyPath]) }
    }
 

    /// Sum of a `AdditiveArithmetic` property of each `Element` in a `Sequence`.
    ///
    ///     ["James", "Wade", "Bryant"].sum(for: \.count) -> 15
    ///
    /// - Parameter keyPath: Key path of the `AdditiveArithmetic` property.
    /// - Returns: The sum of the `AdditiveArithmetic` properties at `keyPath`.
    func sum<T: AdditiveArithmetic>(
        for keyPath: KeyPath<Element, T>) -> T {
        // Inspired by: https://swiftbysundell.com/articles/reducers-in-swift/
        return reduce(.zero) { $0 + $1[keyPath: keyPath] }
    } 
}

public extension Sequence where Element: Equatable {
    /// Check if array contains an array of elements.
    ///
    ///        [1, 2, 3, 4, 5].contains([1, 2]) -> true
    ///        [1.2, 2.3, 4.5, 3.4, 4.5].contains([2, 6]) -> false
    ///        ["h", "e", "l", "l", "o"].contains(["l", "o"]) -> true
    ///
    /// - Parameter elements: array of elements to check.
    /// - Returns: true if array contains all given items.
    /// - Complexity: _O(m·n)_, where _m_ is the length of `elements` and _n_ is the length of this sequence.
    func contains(_ elements: [Element]) -> Bool {
        return elements.allSatisfy { contains($0) }
    }
}

public extension Sequence where Element: Hashable {
    /// Check if array contains an array of elements.
    ///
    ///        [1, 2, 3, 4, 5].contains([1, 2]) -> true
    ///        [1.2, 2.3, 4.5, 3.4, 4.5].contains([2, 6]) -> false
    ///        ["h", "e", "l", "l", "o"].contains(["l", "o"]) -> true
    ///        [1, 2, 3].contains([1, 4]) -> false
    ///
    /// - Parameter elements: array of elements to check.
    /// - Returns: true if array contains all given items.
    /// - Complexity: _O(m + n)_, where _m_ is the length of `elements` and _n_ is the length of this sequence.
    func contains(_ elements: [Element]) -> Bool {
        let set = Set(self)
        return elements.allSatisfy { set.contains($0) }
    }

    /// Check whether a sequence contains duplicates.
    ///
    /// - Returns: true if the receiver contains duplicates.
    func containsDuplicates() -> Bool {
        var set = Set<Element>()
        return contains { !set.insert($0).inserted }
    }

    /// Getting the duplicated elements in a sequence.
    ///
    ///     [1, 1, 2, 2, 3, 3, 3, 4, 5].duplicates().sorted() -> [1, 2, 3])
    ///     ["h", "e", "l", "l", "o"].duplicates().sorted() -> ["l"])
    ///
    /// - Returns: An array of duplicated elements.
    ///
    func duplicates() -> [Element] {
        var set = Set<Element>()
        var duplicates = Set<Element>()
        forEach {
            if !set.insert($0).inserted {
                duplicates.insert($0)
            }
        }
        return Array(duplicates)
    }
}

public extension Sequence where Element: Hashable {
    var frequencies: [Element: Int] {
        let frequencyPairs = self.map { ($0, 1) }
        return Dictionary(frequencyPairs, uniquingKeysWith: +)
    }
}

// MARK: - Methods (AdditiveArithmetic)

public extension Sequence where Element: AdditiveArithmetic {
    /// Sum of all elements in array.
    ///
    ///        [1, 2, 3, 4, 5].sum() -> 15
    ///
    /// - Returns: sum of the array's elements.
    func sum() -> Element {
        return reduce(.zero, +)
    }
}

@inlinable public func indexSequence<T>(first: T, next: @escaping (Int, T) -> T?) -> UnfoldFirstSequence<T> {
    var index = 0
    return sequence(first: first) {
        index += 1
        return next(index, $0)
    }
}
