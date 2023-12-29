//
//  WrapCollection.swift
//  SwifterKnife
//
//  Created by liyang on 2023/12/25.
//

import Foundation
 
public protocol WrapContainerType {
    associatedtype WrapType
    var wrapValue: WrapType { get }
    init(_ wrapValue: WrapType)
}


// MARK: - WrapCollection

public struct WrapCollection<Collection: Swift.Collection> where Collection.Element: WrapContainerType {
    public typealias Index = Collection.Index
    
    public typealias Container = Collection.Element
    public typealias W = Container.WrapType
    private var _buffer: Collection
    public init(collection: Collection) {
        _buffer = collection
    }
}
//extension WrapCollection: CustomStringConvertible {
//    public var description: String {
//        _buffer.map(\.wrapValue).description
//    }
//}
extension WrapCollection: Sequence {
    public func makeIterator() -> IndexingIterator<[W]> {
        _buffer.map(\.wrapValue).makeIterator()
    }
}

extension WrapCollection: Swift.Collection {

    public var startIndex: Index {
        _buffer.startIndex
    }
    public var endIndex: Index {
        _buffer.endIndex
    }
    public func index(after i: Index) -> Index {
        _buffer.index(after: i)
    }
    public subscript(position: Index) -> W {
        _buffer[position].wrapValue
    }
}
extension WrapCollection: MutableCollection where Collection: MutableCollection {
    public subscript(position: Index) -> W {
        get { _buffer[position].wrapValue }
        set {
            _buffer[position] = Container(newValue)
        }
    }
}
extension WrapCollection: BidirectionalCollection where Collection: BidirectionalCollection {
    public func index(before i: Index) -> Index {
        _buffer.index(before: i)
    }
}

extension WrapCollection: RandomAccessCollection where Collection: RandomAccessCollection {}
extension WrapCollection: RangeReplaceableCollection where Collection: RangeReplaceableCollection {
    public init() {
        _buffer = .init()
    }
    public mutating func replaceSubrange<C>(_ subrange: Range<Index>, with newElements: C) where C: Swift.Collection, W == C.Element {
        _buffer.replaceSubrange(subrange, with: newElements.map(Container.init))
    }
    public mutating func reserveCapacity(_ n: Int) {
        _buffer.reserveCapacity(n)
    }
    public init(repeating repeatedValue: W, count: Int) {
        let val = Container(repeatedValue)
        _buffer = .init(repeating: val, count: count)
    }
    public init<S>(_ elements: S) where S : Sequence, W == S.Element {
        _buffer = .init(elements.map(Container.init))
    }
    public mutating func append(_ newElement: W) {
        _buffer.append(Container(newElement))
    }
    public mutating func append<S>(contentsOf newElements: S) where S : Sequence, W == S.Element {
        _buffer.append(contentsOf: newElements.map(Container.init))
    }
    public mutating func insert(_ newElement: W, at i: Index) {
        _buffer.insert(Container(newElement), at: i)
    }
    public mutating func insert<S>(contentsOf newElements: S, at i: Index) where S: Swift.Collection, W == S.Element {
        _buffer.insert(contentsOf: newElements.map(Container.init), at: i)
    }
    public mutating func remove(at i: Index) -> W {
        _buffer.remove(at: i).wrapValue
    }
    public mutating func removeSubrange(_ bounds: Range<Index>) {
        _buffer.removeSubrange(bounds)
    }
    public mutating func removeAll(keepingCapacity keepCapacity: Bool) {
        _buffer.removeAll(keepingCapacity: keepCapacity)
    }
}
extension WrapCollection: LazyCollectionProtocol { }

public extension WrapCollection where W: OptionalType {
    var compacted: [W.Wrapped] {
        _buffer.compactMap(\.wrapValue.value)
    }
}
public extension WrapCollection where W: OptionalType, Collection: ExpressibleByArrayLiteral, Collection.ArrayLiteralElement == [Container] {
    mutating func compact() {
        let keeped = _buffer.filter { $0.wrapValue.value != nil }
        _buffer = Collection(arrayLiteral: keeped)
    }
}

extension WrapCollection: ExpressibleByArrayLiteral where Collection: ExpressibleByArrayLiteral, Collection.ArrayLiteralElement == [Container] {
    public init(arrayLiteral elements: W...) {
        _buffer = Collection(arrayLiteral: elements.map(Container.init))
    }
}

// MARK: - Set
extension WrapCollection: Equatable where Collection: Equatable {}

extension WrapCollection: SetAlgebra where Collection: SetAlgebra, Collection.ArrayLiteralElement == [Container] {

    public init() {
        _buffer = .init()
    }
    public func contains(_ member: W) -> Bool {
        _buffer.contains(Container(member))
    }
    
    public func union(_ other: __owned WrapCollection<Collection>) -> WrapCollection<Collection> {
        let set = _buffer.union(other._buffer)
        return .init(collection: set)
    }
    public func intersection(_ other: WrapCollection<Collection>) -> WrapCollection<Collection> {
        let set = _buffer.intersection(other._buffer)
        return .init(collection: set)
    }
    public func symmetricDifference(_ other: __owned WrapCollection<Collection>) -> WrapCollection<Collection> {
        let set = _buffer.symmetricDifference(other._buffer)
        return .init(collection: set)
    }
    
    public mutating func insert(_ newMember: __owned W) -> (inserted: Bool, memberAfterInsert: W) {
        let flag = _buffer.insert(Container(newMember))
        return (flag.inserted, flag.memberAfterInsert.wrapValue)
    }
    public mutating func remove(_ member: W) -> W? {
        _buffer.remove(Container(member))?.wrapValue
    }
    public mutating func update(with newMember: __owned W) -> W? {
        _buffer.update(with: Container(newMember))?.wrapValue
    }
    public mutating func formUnion(_ other: __owned WrapCollection<Collection>) {
        _buffer.formUnion(other._buffer)
    }
    public mutating func formIntersection(_ other: WrapCollection<Collection>) {
        _buffer.formIntersection(other._buffer)
    }
    public mutating func formSymmetricDifference(_ other: __owned WrapCollection<Collection>) {
        _buffer.formSymmetricDifference(other._buffer)
    }
    
    public func subtracting(_ other: WrapCollection<Collection>) -> WrapCollection<Collection> {
        let set = _buffer.subtracting(other._buffer)
        return .init(collection: set)
    }
    public func isSubset(of other: WrapCollection<Collection>) -> Bool {
        _buffer.isSubset(of: other._buffer)
    }
    public func isDisjoint(with other: WrapCollection<Collection>) -> Bool {
        _buffer.isDisjoint(with: other._buffer)
    }
    public func isSuperset(of other: WrapCollection<Collection>) -> Bool {
        _buffer.isSuperset(of: other._buffer)
    }
    public var isEmpty: Bool { _buffer.isEmpty }
    
    public init<S>(_ sequence: __owned S) where S : Sequence, W == S.Element {
        _buffer = Collection(sequence.map(Container.init))
    }
    
    public mutating func subtract(_ other: WrapCollection<Collection>) {
        _buffer.subtract(other._buffer)
    }
}


// MARK: - Dictionary
//public protocol _DictionaryProtocol: Collection where Element == (key: Key, value: Value) {
//    associatedtype Key: Hashable
//    associatedtype Value
//
//    var keys: Dictionary<Key, Value>.Keys { get }
//
//    subscript(key: Key) -> Value? { get set }
//
//    mutating func merge<S: Sequence>(_ other: S, uniquingKeysWith combine: (Value, Value) throws -> Value) rethrows where S.Element == (Key, Value)
//
//    mutating func merge(
//        _ other: [Key: Value], uniquingKeysWith combine: (Value, Value) throws -> Value
//    ) rethrows
//
//    @discardableResult
//    mutating func removeValue(forKey key: Key) -> Value?
//
//    mutating func updateValue(_ value: Value, forKey key: Key) -> Value?
//}
//
//extension Dictionary: _DictionaryProtocol {}
 

public struct WeakBox<O: AnyObject>: WrapContainerType, Hashable {
    public static func == (lhs: WeakBox<O>, rhs: WeakBox<O>) -> Bool {
        switch (lhs.wrapValue, rhs.wrapValue) {
        case let (lw?, rw?):
            return lw === rw
        case (nil, nil):
            return true
        default: return false
        }
    }
    public func hash(into hasher: inout Hasher) {
        if let v = wrapValue {
            let val = unsafeBitCast(v, to: UInt.self)
            hasher.combine(val)
        }
    }
    
    public private(set) weak var wrapValue: O?
    public init(_ wrapValue: O?) {
        self.wrapValue = wrapValue
    }
}
//public typealias WeakPair<Key, O: AnyObject> = (Key, WeakBox<O>)
//extension WeakPair: WrapContainerType {
//
//}
public typealias WeakArray<O: AnyObject> = WrapCollection<ContiguousArray<WeakBox<O>>>
public typealias WeakSet<O: AnyObject> = WrapCollection<Set<WeakBox<O>>>
//public typealias WeakDictionary<Key: Hashable, O: AnyObject> = WrapCollection<Dictionary<Key, WeakBox<O>>>
