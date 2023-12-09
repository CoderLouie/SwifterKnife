//
//  Dictionary+Add.swift
//  SwifterKnife
//
//  Created by liyang on 2021/10/19.
//

import Foundation

// MARK: - Methods

public extension Dictionary {

    /// Check if key exists in dictionary.
    ///
    ///        let dict: [String: Any] = ["testKey": "testValue", "testArrayKey": [1, 2, 3, 4, 5]]
    ///        dict.has(key: "testKey") -> true
    ///        dict.has(key: "anotherKey") -> false
    ///
    /// - Parameter key: key to search for.
    /// - Returns: true if key exists in dictionary.
    func has(key: Key) -> Bool {
        return index(forKey: key) != nil
    }

    /// Remove all keys contained in the keys parameter from the dictionary.
    ///
    ///        var dict: [String: String] = ["key1": "value1", "key2": "value2", "key3": "value3"]
    ///        dict.removeAll(keys: ["key1", "key2"])
    ///        dict.keys.contains("key3") -> true
    ///        dict.keys.contains("key1") -> false
    ///        dict.keys.contains("key2") -> false
    ///
    /// - Parameter keys: keys to be removed.
    mutating func removeAll<S: Sequence>(keys: S) where S.Element == Key {
        keys.forEach { removeValue(forKey: $0) }
    }

    /// Remove a value for a random key from the dictionary.
    @discardableResult
    mutating func removeRandom() -> (Key, Value)? {
        guard let key = keys.randomElement(),
              let value = removeValue(forKey: key) else { return nil }
        return (key, value)
    } 

    /// Returns a dictionary containing the results of mapping the given closure over the sequence’s elements.
    /// - Parameter transform: A mapping closure. `transform` accepts an element of this sequence as its parameter and returns a transformed value of the same or of a different type.
    /// - Returns: A dictionary containing the transformed elements of this sequence.
    func mapKeysAndValues<K, V>(_ transform: ((key: Key, value: Value)) throws -> (K, V)) rethrows -> [K: V] {
        return try [K: V](uniqueKeysWithValues: map(transform))
    }

    /// Returns a dictionary containing the non-`nil` results of calling the given transformation with each element of this sequence.
    /// - Parameter transform: A closure that accepts an element of this sequence as its argument and returns an optional value.
    /// - Returns: A dictionary of the non-`nil` results of calling `transform` with each element of the sequence.
    /// - Complexity: *O(m + n)*, where _m_ is the length of this sequence and _n_ is the length of the result.
    func compactMapKeysAndValues<K, V>(_ transform: ((key: Key, value: Value)) throws -> (K, V)?) rethrows -> [K: V] {
        return try [K: V](uniqueKeysWithValues: compactMap(transform))
    }

    /// Creates a new dictionary using specified keys.
    ///
    ///        var dict =  ["key1": 1, "key2": 2, "key3": 3, "key4": 4]
    ///        dict.pick(keys: ["key1", "key3", "key4"]) -> ["key1": 1, "key3": 3, "key4": 4]
    ///        dict.pick(keys: ["key2"]) -> ["key2": 2]
    ///
    /// - Complexity: O(K), where _K_ is the length of the keys array.
    ///
    /// - Parameter keys: An array of keys that will be the entries in the resulting dictionary.
    ///
    /// - Returns: A new dictionary that contains the specified keys only. If none of the keys exist, an empty dictionary will be returned.
    func pick(keys: [Key]) -> [Key: Value] {
        keys.reduce(into: [Key: Value]()) { result, key in
            result[key] = self[key]
        }
    }
}

// MARK: - Methods (Value: Equatable)

public extension Dictionary where Value: Equatable {
    /// Returns an array of all keys that have the given value in dictionary.
    ///
    ///        let dict = ["key1": "value1", "key2": "value1", "key3": "value2"]
    ///        dict.keys(forValue: "value1") -> ["key1", "key2"]
    ///        dict.keys(forValue: "value2") -> ["key3"]
    ///        dict.keys(forValue: "value3") -> []
    ///
    /// - Parameter value: Value for which keys are to be fetched.
    /// - Returns: An array containing keys that have the given value.
    func keys(forValue value: Value) -> [Key] {
        return keys.filter { self[$0] == value }
    }
}

// MARK: - Methods (ExpressibleByStringLiteral)

public extension Dictionary where Key: StringProtocol {
    /// Lowercase all keys in dictionary.
    ///
    ///        var dict = ["tEstKeY": "value"]
    ///        dict.lowercaseAllKeys()
    ///        print(dict) // prints "["testkey": "value"]"
    ///
    mutating func lowercaseAllKeys() {
        // http://stackoverflow.com/questions/33180028/extend-dictionary-where-key-is-of-type-string
        for key in keys {
            if let lowercaseKey = String(describing: key).lowercased() as? Key {
                self[lowercaseKey] = removeValue(forKey: key)
            }
        }
    }
}

// MARK: - Subscripts

public extension Dictionary {
    /*
     final class AABox {
         var nums: [Int] = []
     }
     struct AABox {
         var nums: [Int] = []
     }
     var box: [String: AABox] = [:]
     box["xiaohua", default: AABox()].nums.append(3)
     如果是struct，可以存入box，class则不行
     */ 
    subscript(ref key: Key, or build: @autoclosure () -> Value) -> Value where Value: AnyObject {
        mutating get {
            if let val = self[key] {
                return val
            }
            let val = build()
            self[key] = val
            return val
        }
    }
}

// MARK: - Operators

public extension Dictionary {
    /// Merge the keys/values of two dictionaries.
    ///
    ///        let dict: [String: String] = ["key1": "value1"]
    ///        let dict2: [String: String] = ["key2": "value2"]
    ///        let result = dict + dict2
    ///        result["key1"] -> "value1"
    ///        result["key2"] -> "value2"
    ///
    /// - Parameters:
    ///   - lhs: dictionary.
    ///   - rhs: dictionary.
    /// - Returns: An dictionary with keys and values from both.
    static func + (lhs: [Key: Value], rhs: [Key: Value]) -> [Key: Value] {
        var result = lhs
        rhs.forEach { result[$0] = $1 }
        return result
    }

    // MARK: - Operators

    /// Append the keys and values from the second dictionary into the first one.
    ///
    ///        var dict: [String: String] = ["key1": "value1"]
    ///        let dict2: [String: String] = ["key2": "value2"]
    ///        dict += dict2
    ///        dict["key1"] -> "value1"
    ///        dict["key2"] -> "value2"
    ///
    /// - Parameters:
    ///   - lhs: dictionary.
    ///   - rhs: dictionary.
    static func += (lhs: inout [Key: Value], rhs: [Key: Value]) {
        rhs.forEach { lhs[$0] = $1 }
    }

    /// Remove keys contained in the sequence from the dictionary.
    ///
    ///        let dict: [String: String] = ["key1": "value1", "key2": "value2", "key3": "value3"]
    ///        let result = dict-["key1", "key2"]
    ///        result.keys.contains("key3") -> true
    ///        result.keys.contains("key1") -> false
    ///        result.keys.contains("key2") -> false
    ///
    /// - Parameters:
    ///   - lhs: dictionary.
    ///   - keys: array with the keys to be removed.
    /// - Returns: a new dictionary with keys removed.
    static func - <S: Sequence>(lhs: [Key: Value], keys: S) -> [Key: Value] where S.Element == Key {
        var result = lhs
        result.removeAll(keys: keys)
        return result
    }

    /// Remove keys contained in the sequence from the dictionary.
    ///
    ///        var dict: [String: String] = ["key1": "value1", "key2": "value2", "key3": "value3"]
    ///        dict-=["key1", "key2"]
    ///        dict.keys.contains("key3") -> true
    ///        dict.keys.contains("key1") -> false
    ///        dict.keys.contains("key2") -> false
    ///
    /// - Parameters:
    ///   - lhs: dictionary.
    ///   - keys: array with the keys to be removed.
    static func -= <S: Sequence>(lhs: inout [Key: Value], keys: S) where S.Element == Key {
        lhs.removeAll(keys: keys)
    }
}



public extension Dictionary {
    func omit(keys: Key...) -> [Key: Value] {
        filter { !keys.contains($0.key) }
    }
    func pick(keys: Key...) -> [Key: Value] {
        pick(keys: keys)
    }
    
    func replaceKeys(using map: [Key: Key]) -> [Key: Value] {
        var result: [Key: Value] = [:]
        for item in self {
            guard let newKey = map[item.key] else { continue }
            result[newKey] = item.value
        }
        return result
    }
    
    func filter(keys: Key...) -> [Key: Value] {
        filter(keys: keys)
    }
    func filter(keys: [Key]) -> [Key: Value] {
        var res = self
        for key in keys {
            res.removeValue(forKey: key)
        }
        return res
    }
    
    mutating func remove(keys: Key...) {
        remove(keys: keys)
    }
    mutating func remove(keys: [Key]) {
        for key in keys {
            removeValue(forKey: key)
        }
    }
}
/*
 哈希不变原则
 两个同样的实例(由你实现的 == 定义相同)，必须拥有同样的哈希值。
 不过反过来不必为真：两个相同哈希值的实例不一定需要相等
 
 */
