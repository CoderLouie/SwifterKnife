//
//  WeakTable.swift
//  SwifterKnife
//
//  Created by liyang on 2021/10/19.
//

import Foundation

// http://www.cocoachina.com/articles/179477

/**
 var table: WeakTable<Person> = .init()
 do {
     for i in 1...5 {
         let p = Person(name: "xiaoming\(i)")
         table.append(p)
         if i == 5 {
             debugPrint("1 ", table)
         }
     }
     DispatchQueue.main.after(1) {
         debugPrint("3 ", table)
         table.compact()
         debugPrint("4 ", table)
         print("5")
     }
 }
 debugPrint("2 ", table)
 for case let p? in table {
     print(p)
 }
 */

/// Swift 弱引用表
public final class WeakTable<E: AnyObject> {
    
    public static var weak: Self {
        .init(pointerArray: .weakObjects())
    }
    public static var strong: Self {
        .init(pointerArray: .strongObjects())
    }
    public convenience init() {
        self.init(pointerArray: .weakObjects())
    }
    private let ptrs: NSPointerArray
    
    private init(pointerArray: NSPointerArray) {
        ptrs = pointerArray
    }
    
    public func compact() {
        /*
         经过测试如果直接compact是无法清空NULL,
         需要在compact之前,调用一次ptrs.addPointer(nil),
         才可以清空
         */
        ptrs.addPointer(nil)
        ptrs.compact()
    }
    
    public subscript(safe index: Int) -> E? {
        get {
            guard (0..<count).contains(index) else { return nil }
            return self[index]
        }
        set {
            guard (0..<count).contains(index) else { return }
            self[index] = newValue
        }
    }
    
    
    public func every(_ body: (E) throws -> Void) rethrows {
        for case let item? in self {
            try body(item)
        }
    }
    
    private func ptr(of element: E?) -> UnsafeMutableRawPointer? {
        guard let val = element else { return nil }
        // 获取一个指向其val的原始指针
        return Unmanaged<E>.passUnretained(val).toOpaque()
    }
}

extension WeakTable {

    @discardableResult
    public func append(_ element: E?) -> Bool {
        guard let ptr = ptr(of: element) else { return false }
        ptrs.addPointer(ptr)
        return true
    }
    public var count: Int {
        get { ptrs.count }
//        set { ptrs.count = newValue }
    }
    public var isEmpty: Bool {
        compact()
        return ptrs.count == 0
    }

    @discardableResult
    public func insert(_ newElement: E?, at i: Int) -> Bool {
        guard let ptr = ptr(of: newElement) else { return false }
        ptrs.insertPointer(ptr, at: i)
        return true
    }

    public var first: E? {
        guard ptrs.count > 0 else { return nil }
        compact()
        return self[0]
    }
    public var last: E? {
        let n = ptrs.count
        guard n > 0 else { return nil }
        compact()
        return self[n - 1]
    }

    public func remove(at index: Int) {
        ptrs.removePointer(at: index)
    }
}

extension WeakTable: CustomStringConvertible {
    public var description: String {
        map { item in
            item.map { "\($0)" } ?? "nil"
        }.description
    }
}
extension WeakTable: CustomDebugStringConvertible {
    public var debugDescription: String {
        "count: \(count), \(description)\n table:\(ptrs.debugDescription)"
    }
}

extension WeakTable: ExpressibleByArrayLiteral {
    
    public convenience init(arrayLiteral elements: E?...) {
        self.init(pointerArray: .weakObjects())
        for element in elements { append(element) }
    }
}

public struct WeakTableIterator<Item: AnyObject>: IteratorProtocol {
    private let table: WeakTable<Item>
    private var index: Int = 0
    public init(table: WeakTable<Item>) {
        table.compact()
        self.table = table
    }
    public mutating func next() -> Item?? {
        guard index < table.count else { return nil }
        let item = table[index]
        index += 1
        return item
    }
}

extension WeakTable: Sequence {

    public func makeIterator() -> WeakTableIterator<E> {
        WeakTableIterator(table: self)
    }
}

extension WeakTable: MutableCollection {
    public func index(after i: Int) -> Int { i + 1 }
    public var startIndex: Int { 0 }
    public var endIndex: Int { count }
    
    public subscript(index: Int) -> E? {
        get {
            guard let ptr = ptrs.pointer(at: index) else { return nil }
            return Unmanaged<E>.fromOpaque(ptr).takeUnretainedValue()
        }
        set {
            ptrs.replacePointer(at: index, withPointer: ptr(of: newValue))
        }
    }
}


extension WeakTable: RandomAccessCollection { }

extension WeakTable: RangeReplaceableCollection {
    
    public func replaceSubrange<C>(_ subrange: Range<Int>, with newElements: C) where C : Collection, C.Iterator.Element == E? {
        guard !subrange.isEmpty, !newElements.isEmpty else { return }
        
        let start = subrange.lowerBound
        for (i, element) in newElements.enumerated() {
            let index = start + i
            guard subrange.contains(index) else { return }
            ptrs.replacePointer(at: index, withPointer: ptr(of: element))
        }
    }
}

extension WeakTable: LazyCollectionProtocol { }


/*
public protocol WeakContainer {
    associatedtype Wrapped: AnyObject
    var wrapped: Wrapped? { get }
    init(_ value: Wrapped)
}
public final class WeakBox<Wrapped: AnyObject>: WeakContainer, Hashable {
    public static func == (lhs: WeakBox<Wrapped>, rhs: WeakBox<Wrapped>) -> Bool {
        lhs === rhs
    }
    public func hash(into hasher: inout Hasher) {
        let ptr = unsafeBitCast(self, to: UInt.self)
        hasher.combine(ptr)
    }
    
    public private(set) weak var wrapped: Wrapped?
    public init(_ value: Wrapped) { wrapped = value }
}
public typealias WeakArray<Wrapped: AnyObject> = Array<WeakBox<Wrapped>>
//public typealias WeakSet<Wrapped: AnyObject> = Set<WeakBox<Wrapped>>


//public extension RangeReplaceableCollection where Self: MutableCollection, Element: WeakContainer {
public extension Array where Element: WeakContainer {
    init<S>(_ objects: S) where Element.Wrapped == S.Element, S : Sequence {
        self.init(objects.map(Element.init))
    }
    init(_ objects: Element.Wrapped...) {
        self.init(objects)
    }
    
    mutating func append(_ object: Element.Wrapped) {
        append(.init(object))
    }
    mutating func append<S>(contentsOf objects: S) where Element.Wrapped == S.Element, S : Sequence {
        append(contentsOf: objects.map(Element.init))
    }
    subscript(weak index: Index) -> Element.Wrapped? {
        get {
            indices.contains(index) ? self[index].wrapped : nil
        }
        set {
            guard indices.contains(index) else { return }
            if let val = newValue {
                self[index] = Element(val)
            } else {
                remove(at: index)
            }
        }
    }
    mutating func compact() {
        removeAll { $0.wrapped == nil }
    }
}
*/
