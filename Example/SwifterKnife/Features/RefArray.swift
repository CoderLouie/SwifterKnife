//
//  RefArray.swift
//  SwifterKnife
//
//  Created by liyang on 2021/10/19.
//

import Foundation

// http://www.cocoachina.com/articles/179477

/**
 var table: RefArray<Person> = .init()
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


/// Swift 引用数组，可以指定内存管理方式
@frozen
public struct RefArray<E: AnyObject> {
    
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
        /*
         toOpaque()
         unsafeBitCast(_value, to: UnsafeMutableRawPointer.self)
         */
//        return Unmanaged<E>.passUnretained(val).toOpaque()
        return unsafeBitCast(val, to: UnsafeMutableRawPointer.self)
    }
    private func checkIndex(_ index: Int, isInsert: Bool = false) {
        guard index >= 0 else {
            fatalError("RefArray index is out of range")
        }
        let n = _ptrs.count
        let max = isInsert ? n + 1 : n
        guard index < max else {
            fatalError("RefArray index is out of range")
        }
    }
    private func checkRange(_ range: Range<Int>) {
        guard range.lowerBound >= 0 else {
            fatalError("RefArray subrange lowerBound is invalid")
        }
        guard range.upperBound <= _ptrs.count else {
            fatalError("RefArray subrange extends past the end")
        }
    }
}

extension RefArray {
    public var compacted: [E] {
        _ptrs.allObjects.compactMap { $0 as? E }
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

extension RefArray: CustomStringConvertible {
    public var description: String {
        map { $0.map(String.init(describing:)) ?? "nil" }.description
    }
}

extension RefArray: ExpressibleByArrayLiteral {
    
    public init(arrayLiteral elements: E?...) {
        self.init(elements)
    }
}

extension RefArray: Sequence {
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
//            let obj = Unmanaged<E>.fromOpaque(ptr).takeUnretainedValue()
            let obj = unsafeBitCast(ptr, to: E.self)
            return .some(.some(obj))
        }
    }
    public func makeIterator() -> Iterator {
        Iterator(ptrs: _ptrs.my_clone)
    }
}

extension RefArray: MutableCollection {
    public func index(after i: Int) -> Int { i + 1 }
    public var startIndex: Int { 0 }
    public var endIndex: Int { _ptrs.count }
    
    public subscript(index: Int) -> E? {
        get {
            checkIndex(index)
            guard let ptr = _ptrs.pointer(at: index) else { return nil }
//            return Unmanaged<E>.fromOpaque(ptr).takeUnretainedValue()
            return unsafeBitCast(ptr, to: E.self)
        }
        mutating set {
            checkIndex(index)
            mutablePtrs.replacePointer(at: index, withPointer: ptr(of: newValue))
        }
    }
    
    // 可以不实现
    public var count: Int {
        get { _ptrs.count }
        mutating set {
            mutablePtrs.count = newValue
        }
    }
}
extension RefArray: RandomAccessCollection { }

extension RefArray: RangeReplaceableCollection {
    /// 看苹果官方文档对此方法说明
    public mutating func replaceSubrange<C>(_ subrange: Range<Int>, with newElements: C) where C : Collection, E? == C.Element {
        checkRange(subrange)
        
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
        while index < subrange.endIndex {
            ptrs.removePointer(at: idx)
            index += 1
        }
    }
    
    // 下面的方法可以不用实现，但为了提高执行效率还是实现一下
    public mutating func reserveCapacity(_ n: Int) {
        mutablePtrs.count = n
    }
    
    public init(repeating repeatedValue: E?, count: Int) {
        self.init(pointerArray: .weakObjects())
        guard let value = repeatedValue else {
            _ptrs.count = count
            return
        }
        let ptr = self.ptr(of: value)
        for _ in 0..<count {
            _ptrs.addPointer(ptr)
        }
    }
    public init<S>(_ elements: S) where S : Sequence, E? == S.Element {
        self.init(pointerArray: .weakObjects())
        for element in elements {
            _ptrs.addPointer(ptr(of: element))
        }
    }
    
    public mutating func append(_ newElement: E?) {
        mutablePtrs.addPointer(ptr(of: newElement))
    }
    public mutating func append<S>(contentsOf newElements: S) where S : Sequence, E? == S.Element {
        let ptrs = mutablePtrs
        for element in newElements {
            ptrs.addPointer(ptr(of: element))
        }
    }
    public mutating func insert(_ newElement: E?, at i: Int) {
        checkIndex(i, isInsert: true)
        mutablePtrs.insertPointer(ptr(of: newElement), at: i)
    }
    public mutating func insert<S>(contentsOf newElements: S, at i: Int) where S : Collection, E? == S.Element {
        checkIndex(i, isInsert: true)
        var index = i
        let ptrs = mutablePtrs
        for element in newElements {
            ptrs.insertPointer(ptr(of: element), at: index)
            index += 1
        }
    }
    public mutating func remove(at i: Int) -> E? {
        let obj = self[i]
        mutablePtrs.removePointer(at: i)
        return obj
    }
    public mutating func removeSubrange(_ bounds: Range<Int>) {
        if bounds.isEmpty { return }
        checkRange(bounds)
        let index = bounds.lowerBound
        let ptrs = mutablePtrs
        for _ in bounds {
            ptrs.removePointer(at: index)
        }
    }
    public mutating func removeAll(keepingCapacity keepCapacity: Bool) {
        let count = _ptrs.count
        _ptrs = NSPointerArray(pointerFunctions: _ptrs.pointerFunctions)
        if keepCapacity {
            _ptrs.count = count
        }
    }
}

extension RefArray: LazyCollectionProtocol { }
 
/*

// MARK: - WeakArray

public struct WeakArray<O: AnyObject> {
    private struct Box {
        weak var object: O?
        fileprivate init(_ obj: O?) {
            self.object = obj
        }
        fileprivate var isValid: Bool {
            object != nil
        }
    }
    private var _buffer: ContiguousArray<Box>
    
    public init() {
        _buffer = .init()
    }
    public mutating func compact() {
        _buffer = _buffer.filter(\.isValid)
    }
    public var compacted: [O] {
        _buffer.compactMap(\.object)
    }
}
extension WeakArray: CustomStringConvertible {
    public var description: String {
        map { $0.map(String.init(describing:)) ?? "nil" }.description
    }
}
extension WeakArray: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: O?...) {
        self.init(elements)
    }
}
extension WeakArray: Sequence {
    public typealias Element = O?
    
    public func makeIterator() -> IndexingIterator<[O?]> {
        _buffer.map(\.object).makeIterator()
    }
}
extension WeakArray: MutableCollection {
    public func index(after i: Int) -> Int {
        _buffer.index(after: i)
    }
    public subscript(position: Int) -> O? {
        get { _buffer[position].object }
        set {
            if let val = newValue {
                _buffer[position].object = val
            } else {
                _buffer.remove(at: position)
            }
        }
    }
    public var startIndex: Int {
        _buffer.startIndex
    }
    
    public var endIndex: Int {
        _buffer.endIndex
    }
}
extension WeakArray: RandomAccessCollection {}
extension WeakArray: RangeReplaceableCollection {
    public mutating func replaceSubrange<C>(_ subrange: Range<Int>, with newElements: C) where C : Collection, O? == C.Element {
        _buffer.replaceSubrange(subrange, with: newElements.map(Box.init))
    }
    
    public mutating func reserveCapacity(_ n: Int) {
        _buffer.reserveCapacity(n)
    }
    public init(repeating repeatedValue: O?, count: Int) {
        let val = Box(repeatedValue)
        _buffer = .init(repeating: val, count: count)
    }
    public init<S>(_ elements: S) where S : Sequence, O? == S.Element {
        _buffer = .init(elements.map(Box.init))
    }
    public mutating func append(_ newElement: O?) {
        _buffer.append(Box(newElement))
    }
    public mutating func append<S>(contentsOf newElements: S) where S : Sequence, O? == S.Element {
        _buffer.append(contentsOf: newElements.map(Box.init))
    }
    public mutating func insert(_ newElement: O?, at i: Int) {
        _buffer.insert(Box(newElement), at: i)
    }
    public mutating func insert<S>(contentsOf newElements: S, at i: Int) where S : Collection, O? == S.Element {
        _buffer.insert(contentsOf: newElements.map(Box.init), at: i)
    }
    public mutating func remove(at i: Int) -> O? {
        _buffer.remove(at: i).object
    }
    public mutating func removeSubrange(_ bounds: Range<Int>) {
        _buffer.removeSubrange(bounds)
    }
    public mutating func removeAll(keepingCapacity keepCapacity: Bool) {
        _buffer.removeAll(keepingCapacity: keepCapacity)
    }
}
extension WeakArray: LazyCollectionProtocol { }
*/
