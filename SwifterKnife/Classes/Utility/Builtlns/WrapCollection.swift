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
public struct WeakBox<O: AnyObject>: WrapContainerType, Hashable, CustomStringConvertible {
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
    
    public var description: String {
        if let val = wrapValue {
            return String(describing: val)
        }
        return "nil"
    }
}


// MARK: - WrapCollection

public struct WrapCollection<Collection: Swift.Collection> where Collection.Element: WrapContainerType {
    public typealias Container = Collection.Element
    
    private var _buffer: Collection
    public init(collection: Collection) {
        _buffer = collection
    }
}
extension WrapCollection: CustomStringConvertible where Collection: CustomStringConvertible {
    public var description: String {
        _buffer.description
    }
}
extension WrapCollection: Sequence {
    public func makeIterator() -> IndexingIterator<[Collection.Element.WrapType]> {
        _buffer.map(\.wrapValue).makeIterator()
    }
}

extension WrapCollection: Swift.Collection {
    public var startIndex: Collection.Index {
        _buffer.startIndex
    }
    public var endIndex: Collection.Index {
        _buffer.endIndex
    }
    public func index(after i: Collection.Index) -> Collection.Index {
        _buffer.index(after: i)
    }
    public subscript(position: Collection.Index) -> Collection.Element.WrapType {
        _buffer[position].wrapValue
    }
}
extension WrapCollection: MutableCollection where Collection: MutableCollection {
    public subscript(position: Collection.Index) -> Collection.Element.WrapType {
        get { _buffer[position].wrapValue }
        set {
            _buffer[position] = Container(newValue)
        }
    }
}
extension WrapCollection: BidirectionalCollection where Collection: BidirectionalCollection {
    public func index(before i: Collection.Index) -> Collection.Index {
        _buffer.index(before: i)
    }
}

extension WrapCollection: RandomAccessCollection where Collection: RandomAccessCollection {}
extension WrapCollection: RangeReplaceableCollection where Collection: RangeReplaceableCollection {
    public init() {
        _buffer = .init()
    }
    public mutating func replaceSubrange<C>(_ subrange: Range<Index>, with newElements: C) where C: Swift.Collection, Collection.Element.WrapType == C.Element {
        _buffer.replaceSubrange(subrange, with: newElements.map(Container.init))
    }
    public mutating func reserveCapacity(_ n: Int) {
        _buffer.reserveCapacity(n)
    }
    public init(repeating repeatedValue: Collection.Element.WrapType, count: Int) {
        let val = Container(repeatedValue)
        _buffer = .init(repeating: val, count: count)
    }
    public init<S>(_ elements: S) where S : Sequence, Collection.Element.WrapType == S.Element {
        _buffer = .init(elements.map(Container.init))
    }
    public mutating func append(_ newElement: Collection.Element.WrapType) {
        _buffer.append(Container(newElement))
    }
    public mutating func append<S>(contentsOf newElements: S) where S : Sequence, Collection.Element.WrapType == S.Element {
        _buffer.append(contentsOf: newElements.map(Container.init))
    }
    public mutating func insert(_ newElement: Collection.Element.WrapType, at i: Collection.Index) {
        _buffer.insert(Container(newElement), at: i)
    }
    public mutating func insert<S>(contentsOf newElements: S, at i: Collection.Index) where S: Swift.Collection, Collection.Element.WrapType == S.Element {
        _buffer.insert(contentsOf: newElements.map(Container.init), at: i)
    }
    public mutating func remove(at i: Collection.Index) -> Collection.Element.WrapType {
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

public extension WrapCollection where Collection.Element.WrapType: OptionalType {
    var compacted: [Collection.Element.WrapType.Wrapped] {
        _buffer.compactMap(\.wrapValue.value)
    }
}
public extension WrapCollection where Collection.Element.WrapType: OptionalType, Collection: ExpressibleByArrayLiteral {
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
    public init(arrayLiteral elements: Collection.Element.WrapType...) {
        self.init(containers: elements.map(Container.init))
    }
}

// MARK: - Set
extension WrapCollection: Equatable where Collection: Equatable {}

extension WrapCollection: SetAlgebra where Collection: SetAlgebra {

    public init() {
        _buffer = .init()
    }
    public func contains(_ member: Collection.Element.WrapType) -> Bool {
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
    @discardableResult
    public mutating func insert(_ newMember: __owned Collection.Element.WrapType) -> (inserted: Bool, memberAfterInsert: Collection.Element.WrapType) {
        let flag = _buffer.insert(Container(newMember))
        return (flag.inserted, flag.memberAfterInsert.wrapValue)
    }
    @discardableResult
    public mutating func remove(_ member: Collection.Element.WrapType) -> Collection.Element.WrapType? {
        _buffer.remove(Container(member))?.wrapValue
    }
    @discardableResult
    public mutating func update(with newMember: __owned Collection.Element.WrapType) -> Collection.Element.WrapType? {
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
    
    public init<S>(_ sequence: __owned S) where S : Sequence, Collection.Element.WrapType == S.Element {
        _buffer = Collection(sequence.map(Container.init))
    }
    
    public mutating func subtract(_ other: WrapCollection<Collection>) {
        _buffer.subtract(other._buffer)
    }
}

 
  
public typealias WeakArray<O: AnyObject> = WrapCollection<ContiguousArray<WeakBox<O>>>
public typealias WeakSet<O: AnyObject> = WrapCollection<Set<WeakBox<O>>>




// MARK: - Dictionary

public struct WrapDictionary<Key: Hashable, Container: WrapContainerType> {
    private var _buffer: Dictionary<Key, Container>
    fileprivate init(buffer: Dictionary<Key, Container>) {
        _buffer = buffer
    }
    public init() {
        _buffer = .init()
    }
    public init(minimumCapacity: Int) {
        _buffer = .init(minimumCapacity: minimumCapacity)
    }
}
extension WrapDictionary: Sequence { }

extension WrapDictionary: Collection {
    
    public func index(after i: Dictionary<Key, Container>.Index) -> Dictionary<Key, Container>.Index {
        _buffer.index(after: i)
    }
    public subscript(position: Dictionary<Key, Container>.Index) -> (Key, Container.WrapType) {
        let pair = _buffer[position]
        return (pair.key, pair.value.wrapValue)
    }
    public var startIndex: Dictionary<Key, Container>.Index {
        _buffer.startIndex
    }
    public var endIndex: Dictionary<Key, Container>.Index {
        _buffer.endIndex
    }
}
extension WrapDictionary: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (Key, Container.WrapType)...) {
        _buffer = .init(uniqueKeysWithValues: elements.map { ($0.0, Container($0.1)) })
    }
}
extension WrapDictionary {
    public subscript(key: Key) -> Container.WrapType? {
        get { _buffer[key]?.wrapValue }
        set {
            if let val = newValue {
                _buffer[key] = Container(val)
            } else {
                _buffer.removeValue(forKey: key)
            }
        }
    }
    @discardableResult
    public mutating func removeValue(forKey key: Key) -> Container.WrapType? {
        _buffer.removeValue(forKey: key)?.wrapValue
    }
    
    public mutating func removeAll(keepingCapacity keepCapacity: Bool = false) {
        _buffer.removeAll(keepingCapacity: keepCapacity)
    }
    
    @discardableResult
    public mutating func updateValue(_ value: Container.WrapType, forKey key: Key) -> Container.WrapType? {
        _buffer.updateValue(Container(value), forKey: key)?.wrapValue
    }
    
    public mutating func merge<S>(_ other: S, uniquingKeysWith combine: (Container.WrapType, Container.WrapType) throws -> Container.WrapType) rethrows where S : Sequence, S.Element == (Key, Container.WrapType) {
        try _buffer.merge(other.map { ($0.0, Container($0.1)) }) {
            try Container(combine($0.wrapValue, $1.wrapValue))
        }
    }
}

public extension WrapDictionary where Container.WrapType: OptionalType {
    mutating func compact() {
        _buffer = _buffer.filter { $0.value.wrapValue.value != nil }
    }
    var compacted: [Container.WrapType.Wrapped] {
        Array(_buffer.compactMapValues(\.wrapValue.value).values)
    }
}
public typealias WeakDictionary<Key: Hashable, O: AnyObject> = WrapDictionary<Key, WeakBox<O>>
