//
//  MutableCollection+Add.swift
//  SwifterKnife
//
//  Created by liyang on 2021/10/19.
//


public extension MutableCollection where Self: RandomAccessCollection {
    /// Sort the collection based on a keypath and a compare function.
    ///
    /// - Parameter keyPath: Key path to sort by. The key path type must be Comparable.
    /// - Parameter compare: Comparison function that will determine the ordering.
    mutating func sort<T>(by keyPath: KeyPath<Element, T>, with compare: (T, T) -> Bool) {
        sort { compare($0[keyPath: keyPath], $1[keyPath: keyPath]) }
    } 
}

public extension MutableCollection {
    /// Assign a given value to a field `keyPath` of all elements in the collection.
    ///
    /// - Parameters:
    ///   - value: The new value of the field.
    ///   - keyPath: The actual field of the element.
    mutating func assignToAll<Value>(value: Value, by keyPath: WritableKeyPath<Element, Value>) {
        for idx in indices {
            self[idx][keyPath: keyPath] = value
        }
    }
}
