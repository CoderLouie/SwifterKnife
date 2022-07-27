//
//  Heap.swift
//  SwifterKnife
//
//  Created by liyang on 2021/10/19.
//

import Foundation

/// Swift 堆
public final class Heap<Element> {
    private var items: [Element] = []
    private let comparator: (Element, Element) -> Bool
    
    public init(by comparator: @escaping (Element, Element) -> Bool) {
        self.comparator = comparator
    }
    public convenience init<T: Collection>(items: T, by comparator: @escaping (Element, Element) -> Bool) where T.Element == Element {
        self.init(by: comparator)
        offer(items)
    }
    public func offer(_ newElement: Element) {
        items.append(newElement)
        if items.count == 1 { return }
        siftUp(items.count - 1)
    }
    public func offer<T: Collection>(_ elements: T) where T.Element == Element {
        let count = elements.count
        guard count > 0 else { return }
        let half = items.count >> 1
        if count > half {
            items.append(contentsOf: elements)
            stride(from: (items.count >> 1) - 1, through: 0, by: -1).forEach(siftDown(_:))
        } else {
            for item in elements { offer(item) }
        }
    }
    @discardableResult
    public func replace(_ newElement: Element) -> Element? {
        if items.count == 0 {
            offer(newElement)
            return nil
        } else {
            let top = items.first!
            items[0] = newElement
            siftDown(0)
            return top
        }
    }
    public var peek: Element {
        guard let top = items.first else { fatalError("Heap is empty") }
        return top
    }
    @discardableResult
    public func poll() -> Element {
        guard items.first != nil else { fatalError("Heap is empty") }
        return remove(at: 0)
    }
    public func clear() {
        items.removeAll()
    }
    public var count: Int { return items.count }
    public var isEmpty: Bool { return items.count == 0 }
}

private extension Heap {
    // 自上而下的上滤
    private func siftUp(_ idx: Int) {
        var idx = idx
        let item = items[idx]
        while idx > 0 {
            let parentIdx = (idx - 1) >> 1
            let parentItem = items[parentIdx]
            // item <= parentItem
            if !comparator(item, parentItem) { break }
            items[idx] = parentItem
            idx = parentIdx
        }
        items[idx] = item
    }
    // 自下而上的下滤
    private func siftDown(_ idx: Int) {
        var idx = idx
        let count = items.count
        let half = count >> 1
        let item = items[idx]
        while idx < half {
            // 左子节点
            var childIdx = (idx << 1) + 1
            var childItem = items[childIdx]
            let rightChildIdx = childIdx + 1
            // 右子节点大于左子节点
            if rightChildIdx < count, comparator(items[rightChildIdx], childItem) {
                childIdx = rightChildIdx
                childItem = items[rightChildIdx]
            }
            // childItem <= parentItem
            if !comparator(childItem, item) { break }
            items[idx] = childItem
            idx = childIdx
        }
        items[idx] = item
    }
    @discardableResult
    private func remove(at idx: Int) -> Element {
        let value = items[idx]
        items[idx] = items.last!
        items.removeLast()
        // 移除的是最后一个，不用调整
        if idx == items.count { return value }
        siftDown(idx)
        return value
    }
}

extension Heap where Element: Comparable {
    public convenience init<T: Collection>(items: T) where T.Element == Element {
        self.init()
        offer(items)
    }
    public convenience init() { self.init(by: >) }
    static var maximum: Heap { return .init(by: >) }
    static var minimum: Heap { return .init(by: <) }
    
    @discardableResult
    public func erase(_ element: Element) -> Bool {
        if let idx = items.firstIndex(where: { $0 == element }) {
            remove(at: idx)
            return true
        }
        return false
    }
}


extension Heap: Sequence {
    public struct Iterator: IteratorProtocol {
        let heap: Heap<Element>
        public mutating func next() -> Element? {
            if heap.isEmpty { return nil }
            return heap.poll()
        }
    }
    public func makeIterator() -> Heap.Iterator {
        return Iterator(heap: self)
    }
}

extension Heap: ExpressibleByArrayLiteral where Element: Comparable {
    public convenience init(arrayLiteral elements: Element...) {
        self.init(items: elements)
    }
}

extension Heap: CustomStringConvertible {
    public var description: String {
        return items.description
    }
}
