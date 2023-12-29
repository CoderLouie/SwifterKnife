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

// MARK: - WrapCollection

public struct WrapArray<Container: WrapContainerType> {
    public typealias Element = Container.WrapType
    
    private var _buffer: ContiguousArray<Container>
    
    public init() {
        _buffer = .init()
    }
}
extension WrapArray: CustomStringConvertible {
    public var description: String {
        _buffer.map(\.wrapValue).description
    }
}
extension WrapArray: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: Element...) {
        self.init(elements)
    }
}
extension WrapArray: Sequence {
    public func makeIterator() -> IndexingIterator<[Element]> {
        _buffer.map(\.wrapValue).makeIterator()
    }
}
extension WrapArray: MutableCollection {
    public func index(after i: Int) -> Int {
        _buffer.index(after: i)
    }
    public subscript(position: Int) -> Element {
        get { _buffer[position].wrapValue }
        set {
            _buffer[position] = Container(newValue)
        }
    }
    public var startIndex: Int {
        _buffer.startIndex
    }
    
    public var endIndex: Int {
        _buffer.endIndex
    }
}
extension WrapArray: RandomAccessCollection {}
extension WrapArray: RangeReplaceableCollection {
    public mutating func replaceSubrange<C>(_ subrange: Range<Int>, with newElements: C) where C : Collection, Element == C.Element {
        _buffer.replaceSubrange(subrange, with: newElements.map(Container.init))
    }
    
    public mutating func reserveCapacity(_ n: Int) {
        _buffer.reserveCapacity(n)
    }
    public init(repeating repeatedValue: Element, count: Int) {
        let val = Container(repeatedValue)
        _buffer = .init(repeating: val, count: count)
    }
    public init<S>(_ elements: S) where S : Sequence, Element == S.Element {
        _buffer = .init(elements.map(Container.init))
    }
    public mutating func append(_ newElement: Element) {
        _buffer.append(Container(newElement))
    }
    public mutating func append<S>(contentsOf newElements: S) where S : Sequence, Element == S.Element {
        _buffer.append(contentsOf: newElements.map(Container.init))
    }
    public mutating func insert(_ newElement: Element, at i: Int) {
        _buffer.insert(Container(newElement), at: i)
    }
    public mutating func insert<S>(contentsOf newElements: S, at i: Int) where S : Collection, Element == S.Element {
        _buffer.insert(contentsOf: newElements.map(Container.init), at: i)
    }
    public mutating func remove(at i: Int) -> Element {
        _buffer.remove(at: i).wrapValue
    }
    public mutating func removeSubrange(_ bounds: Range<Int>) {
        _buffer.removeSubrange(bounds)
    }
    public mutating func removeAll(keepingCapacity keepCapacity: Bool) {
        _buffer.removeAll(keepingCapacity: keepCapacity)
    }
}
extension WrapArray: LazyCollectionProtocol { }

public extension WrapArray where Element: OptionalType {
    mutating func compact() {
        _buffer = _buffer.filter { $0.wrapValue.value != nil }
    }
    var compacted: [Element.Wrapped] {
        _buffer.compactMap(\.wrapValue.value)
    }
}

public typealias WeakArray<O: AnyObject> = WrapArray<WeakBox<O>>

/*
// MARK: - WrapCollection

public struct WrapCollection<Collection: Swift.Collection> where Collection.Element: WrapContainerType {
    public typealias Index = Collection.Index
    public typealias Container = Collection.Element
    public typealias Element = Container.WrapType
    
    private var _buffer: Collection
    public init(collection: Collection) {
        _buffer = collection
    }
}
extension WrapCollection: CustomStringConvertible {
    public var description: String {
        _buffer.map(\.wrapValue).description
    }
}
extension WrapCollection: Sequence {
    public func makeIterator() -> IndexingIterator<[Element]> {
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
    public subscript(position: Index) -> Element {
        _buffer[position].wrapValue
    }
}
extension WrapCollection: MutableCollection where Collection: MutableCollection {
    public subscript(position: Index) -> Element {
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
    public mutating func replaceSubrange<C>(_ subrange: Range<Index>, with newElements: C) where C: Swift.Collection, Element == C.Element {
        _buffer.replaceSubrange(subrange, with: newElements.map(Container.init))
    }
    public mutating func reserveCapacity(_ n: Int) {
        _buffer.reserveCapacity(n)
    }
    public init(repeating repeatedValue: Element, count: Int) {
        let val = Container(repeatedValue)
        _buffer = .init(repeating: val, count: count)
    }
    public init<S>(_ elements: S) where S : Sequence, Element == S.Element {
        _buffer = .init(elements.map(Container.init))
    }
    public mutating func append(_ newElement: Element) {
        _buffer.append(Container(newElement))
    }
    public mutating func append<S>(contentsOf newElements: S) where S : Sequence, Element == S.Element {
        _buffer.append(contentsOf: newElements.map(Container.init))
    }
    public mutating func insert(_ newElement: Element, at i: Index) {
        _buffer.insert(Container(newElement), at: i)
    }
    public mutating func insert<S>(contentsOf newElements: S, at i: Index) where S: Swift.Collection, Element == S.Element {
        _buffer.insert(contentsOf: newElements.map(Container.init), at: i)
    }
    public mutating func remove(at i: Index) -> Element {
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

public extension WrapCollection where Element: OptionalType {
    var compacted: [Element.Wrapped] {
        _buffer.compactMap(\.wrapValue.value)
    }
}
public extension WrapCollection where Element: OptionalType, Collection: ExpressibleByArrayLiteral {
    mutating func compact() {
        let keeped = _buffer.filter { $0.wrapValue.value != nil }
        self = .init(containers: keeped)
    }
}

extension WrapCollection: ExpressibleByArrayLiteral where Collection: ExpressibleByArrayLiteral {
    fileprivate init(containers: [Container]) {
        let creator = unsafeBitCast(
          Collection.init(arrayLiteral:),
          to: (([Container]) -> Collection).self
        )
        _buffer = creator(containers)
    }
    public init(arrayLiteral elements: Element...) {
        self.init(containers: elements.map(Container.init))
    }
}

// MARK: - Set
extension WrapCollection: Equatable where Collection: Equatable {}

extension WrapCollection: SetAlgebra where Collection: SetAlgebra {

    public init() {
        _buffer = .init()
    }
    public func contains(_ member: Element) -> Bool {
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
    
    public mutating func insert(_ newMember: __owned Element) -> (inserted: Bool, memberAfterInsert: Element) {
        let flag = _buffer.insert(Container(newMember))
        return (flag.inserted, flag.memberAfterInsert.wrapValue)
    }
    public mutating func remove(_ member: Element) -> Element? {
        _buffer.remove(Container(member))?.wrapValue
    }
    public mutating func update(with newMember: __owned Element) -> Element? {
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
    
    public init<S>(_ sequence: __owned S) where S : Sequence, Element == S.Element {
        _buffer = Collection(sequence.map(Container.init))
    }
    
    public mutating func subtract(_ other: WrapCollection<Collection>) {
        _buffer.subtract(other._buffer)
    }
}
 
 

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
public typealias WeakArray<O: AnyObject> = WrapCollection<ContiguousArray<WeakBox<O>>>
public typealias WeakSet<O: AnyObject> = WrapCollection<Set<WeakBox<O>>>

*/
