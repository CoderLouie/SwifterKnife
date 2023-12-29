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
//public extension WrapContainerType where WrapType: OptionalType {
//    init(someVal: WrapType.Wrapped) {
//        self.init(WrapType(someVal))
//    }
//}


// MARK: - WrapCollection

public struct WrapCollection<W: WrapContainerType> {
    private var _buffer: ContiguousArray<W>
    
    public init() {
        _buffer = .init()
    }
}
extension WrapCollection: CustomStringConvertible {
    public var description: String {
        _buffer.map(\.wrapValue).description
    }
}
extension WrapCollection: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: W.WrapType...) {
        self.init(elements)
    }
}
extension WrapCollection: Sequence {
    public typealias Element = W.WrapType
    
    public func makeIterator() -> IndexingIterator<[W.WrapType]> {
        _buffer.map(\.wrapValue).makeIterator()
    }
}
extension WrapCollection: MutableCollection {
    public func index(after i: Int) -> Int {
        _buffer.index(after: i)
    }
    public subscript(position: Int) -> W.WrapType {
        get { _buffer[position].wrapValue }
        set {
            _buffer[position] = W(newValue)
        }
    }
//    public subscript(position: Int) -> W.WrapType where W.WrapType: OptionalType {
//        get { _buffer[position].wrapValue }
//        set {
//            if let val = newValue.value {
//                _buffer[position] = W(someVal: val)
//            } else {
//                _buffer.remove(at: position)
//            }
//        }
//    }
    public var startIndex: Int {
        _buffer.startIndex
    }
    
    public var endIndex: Int {
        _buffer.endIndex
    }
}
extension WrapCollection: RandomAccessCollection {}
extension WrapCollection: RangeReplaceableCollection {
    public mutating func replaceSubrange<C>(_ subrange: Range<Int>, with newElements: C) where C : Collection, W.WrapType == C.Element {
        _buffer.replaceSubrange(subrange, with: newElements.map(W.init))
    }
    
    public mutating func reserveCapacity(_ n: Int) {
        _buffer.reserveCapacity(n)
    }
    public init(repeating repeatedValue: W.WrapType, count: Int) {
        let val = W(repeatedValue)
        _buffer = .init(repeating: val, count: count)
    }
    public init<S>(_ elements: S) where S : Sequence, W.WrapType == S.Element {
        _buffer = .init(elements.map(W.init))
    }
    public mutating func append(_ newElement: W.WrapType) {
        _buffer.append(W(newElement))
    }
    public mutating func append<S>(contentsOf newElements: S) where S : Sequence, W.WrapType == S.Element {
        _buffer.append(contentsOf: newElements.map(W.init))
    }
    public mutating func insert(_ newElement: W.WrapType, at i: Int) {
        _buffer.insert(W(newElement), at: i)
    }
    public mutating func insert<S>(contentsOf newElements: S, at i: Int) where S : Collection, W.WrapType == S.Element {
        _buffer.insert(contentsOf: newElements.map(W.init), at: i)
    }
    public mutating func remove(at i: Int) -> W.WrapType {
        _buffer.remove(at: i).wrapValue
    }
    public mutating func removeSubrange(_ bounds: Range<Int>) {
        _buffer.removeSubrange(bounds)
    }
    public mutating func removeAll(keepingCapacity keepCapacity: Bool) {
        _buffer.removeAll(keepingCapacity: keepCapacity)
    }
}
extension WrapCollection: LazyCollectionProtocol { }

public extension WrapCollection where W.WrapType: OptionalType {
    
    mutating func compact() {
        _buffer = _buffer.filter { $0.wrapValue.value != nil }
    }
    var compacted: [W.WrapType.Wrapped] {
        _buffer.compactMap(\.wrapValue.value)
    }
}


public struct WeakBox<O: AnyObject>: WrapContainerType {
    public private(set) weak var wrapValue: O?
    public init(_ wrapValue: O?) {
        self.wrapValue = wrapValue
    }
}

public typealias WeakArray<O: AnyObject> = WrapCollection<WeakBox<O>>
