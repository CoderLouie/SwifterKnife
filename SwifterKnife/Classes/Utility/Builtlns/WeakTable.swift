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

fileprivate extension NSPointerArray {
    var my_clone: NSPointerArray {
        if let new = copy() as? NSPointerArray {
            print("Clone PointerArray")
            return new
        }
        return self
    }
}


/// Swift 弱引用表
public struct WeakTable<E: AnyObject> {
    
    public static var weak: Self {
        .init(pointerArray: .weakObjects())
    }
    public static var strong: Self {
        .init(pointerArray: .strongObjects())
    }
    public init() {
        self.init(pointerArray: .weakObjects())
    }
    
    public init(options: NSPointerFunctions.Options = []) {
        self.init(pointerArray: .init(options: options))
    }
    public init(pointerFunctions functions: NSPointerFunctions) {
        self.init(pointerArray: .init(pointerFunctions: functions))
    }
    
    private var _ptrs: NSPointerArray
    
    private init(pointerArray: NSPointerArray) {
        _ptrs = pointerArray
    }
    private var mutablePtrs: NSPointerArray {
        mutating get {
            if !isKnownUniquelyReferenced(&_ptrs) {
                print("!UniquelyReference PointerArray")
                _ptrs = _ptrs.my_clone
            }
            return _ptrs
        }
    }
    
    public mutating func compact() {
        /*
         经过测试如果直接compact是无法清空NULL,
         需要在compact之前,调用一次ptrs.addPointer(nil),
         才可以清空
         */
        mutablePtrs.addPointer(nil)
        mutablePtrs.compact()
    }
    
    private func ptr(of element: E?) -> UnsafeMutableRawPointer? {
        guard let val = element else { return nil }
        // 获取一个指向其val的原始指针
        return Unmanaged<E>.passUnretained(val).toOpaque()
    }
}

extension WeakTable {
    public var compacted: [E] {
        _ptrs.allObjects.compactMap { $0 as? E }
    }
    
    public var count: Int {
        get { _ptrs.count }
        mutating set {
            mutablePtrs.count = newValue
        }
    }
    public var wFirst: E? {
        guard _ptrs.count > 0 else { return nil }
        return self[0]
    }
    public var wLast: E? {
        let n = _ptrs.count
        guard n > 0 else { return nil }
        return self[n - 1]
    }
}

extension WeakTable: CustomStringConvertible {
    public var description: String {
        map { $0.map(String.init(describing:)) ?? "nil" }.description
    }
}

extension WeakTable: ExpressibleByArrayLiteral {
    
    public init(arrayLiteral elements: E?...) {
        self.init(pointerArray: .weakObjects())
        for element in elements {
            _ptrs.addPointer(ptr(of: element))
        }
    }
}

extension WeakTable: Sequence {
    public struct Iterator: IteratorProtocol {
        private let ptrs: NSPointerArray
        private var index: Int = 0
        fileprivate init(ptrs: NSPointerArray) {
            self.ptrs = ptrs
        }
        public mutating func next() -> E?? {
            guard index < ptrs.count else { return nil }
            defer { index += 1 }
            guard let ptr = ptrs.pointer(at: index) else {
                return .some(nil)
            }
            let obj = Unmanaged<E>.fromOpaque(ptr).takeUnretainedValue()
            return .some(.some(obj))
        }
    }
    public func makeIterator() -> Iterator {
        Iterator(ptrs: _ptrs.my_clone)
    }
}

extension WeakTable: MutableCollection {
    public func index(after i: Int) -> Int { i + 1 }
    public var startIndex: Int { 0 }
    public var endIndex: Int { _ptrs.count }
    
    public subscript(index: Int) -> E? {
        get {
            guard let ptr = _ptrs.pointer(at: index) else { return nil }
            return Unmanaged<E>.fromOpaque(ptr).takeUnretainedValue()
        }
        mutating set {
            mutablePtrs.replacePointer(at: index, withPointer: ptr(of: newValue))
        }
    }
}
extension WeakTable: RandomAccessCollection { }

extension WeakTable: RangeReplaceableCollection {
    /// 看苹果官方文档对此方法说明
    public mutating func replaceSubrange<C>(_ subrange: Range<Int>, with newElements: C) where C : Collection, C.Iterator.Element == E? {
        let ptrs = mutablePtrs
        
        var index = subrange.lowerBound 
        for element in newElements {
            let ptr = ptr(of: element)
            if subrange.contains(index) {
                ptrs.replacePointer(at: index, withPointer: ptr)
            } else {
                ptrs.insertPointer(ptr, at: index)
            }
            index += 1
        }
        guard index < subrange.endIndex else { return }
        let idx = index
        guard idx < ptrs.count else {
            fatalError("WeakTable replace: subrange extends past the end")
        }
        while index < subrange.endIndex {
            ptrs.removePointer(at: idx)
            index += 1
        }
    }
}

extension WeakTable: LazyCollectionProtocol { }
 
