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
    
    private let ptrs = NSPointerArray.weakObjects()
    
    public init() { }
    
    public func append(_ element: E?) {
        ptrs.addPointer(ptr(of: element))
    }
    public var count: Int {
        get { ptrs.count }
        set { ptrs.count = newValue }
    }
    public var isEmpty: Bool { ptrs.count == 0 }
    
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
    
    public func remove(at index: Int) {
        ptrs.removePointer(at: index)
    }
    
    public func insert(_ newElement: E?, at i: Int) {
        ptrs.insertPointer(ptr(of: newElement), at: i)
    }
    
    public var first: E? {
        guard ptrs.count > 0 else { return nil }
        return self[0]
    }
    public var last: E? {
        let n = ptrs.count
        guard n > 0 else { return nil }
        return self[n - 1]
    }
    public func every(_ body: (E) throws -> Void) rethrows {
        for case let item? in self {
            try body(item)
        }
    }
    
    private func ptr(of element: E?) -> UnsafeMutableRawPointer? {
        guard let val = element else { return nil }
        // 获取一个指向其val的原始指针
        return Unmanaged<AnyObject>.passUnretained(val).toOpaque()
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
        self.init()
        for element in elements { append(element) }
    }
}

public struct WeakTableIterator<Item: AnyObject>: IteratorProtocol {
    private let table: WeakTable<Item>
    private var index: Int = 0
    public init(table: WeakTable<Item>) {
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
            return Unmanaged<AnyObject>.fromOpaque(ptr).takeUnretainedValue() as? E
        }
        set {
            ptrs.replacePointer(at: index, withPointer: ptr(of: newValue))
        }
    }
}


//extension WeakTable: RandomAccessCollection { }
//
//extension WeakTable: RangeReplaceableCollection { }
//
//extension WeakTable: LazyCollectionProtocol { }
