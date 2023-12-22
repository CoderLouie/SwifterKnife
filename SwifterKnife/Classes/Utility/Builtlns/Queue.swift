//
//  Queue.swift
//  SwifterKnife
//
//  Created by liyang on 2021/10/19.
//

import Foundation

/// Swift 队列
public final class Queue<Element> {
    fileprivate final class Node {
        var value: Element
        var next: Node?
        init(_ value: Element, _ next: Node? = nil) {
            self.value = value
            self.next = next
        }
    }
    private var size = 0
    private var head: Node? = nil
    private var tail: Node? = nil
    
    public init() {}
    /// 头部入队
    public func offerFirst(_ element: Element) {
        let node = Node(element, head)
        head = node
        if tail == nil { tail = node }
        size += 1
    }
    /// 尾部入队
    public func offerLast(_ element: Element) {
        let node = Node(element)
        tail?.next = node
        tail = node
        if head == nil { head = node }
        size += 1
    }
    /// 头部出队
    @discardableResult
    public func pollFirst() -> Element? {
        guard let node = head else { return nil }
        head = node.next
        if head == nil { tail = nil }
        size -= 1
        return node.value
    }
    /// 头部元素
    public var first: Element? {
        get { head?.value }
        set {
            if let val = newValue {
                head?.value = val
            } else {
                pollFirst()
            }
        }
    }
    /// 尾部元素
    public var last: Element? {
        tail?.value
    }
    public var count: Int { size }
    public var isEmpty: Bool { size == 0 }
}

public extension Queue {
    func poll(while predicate: (Element) throws -> Bool) rethrows -> [Element]  {
        var res: [Element] = []
        while let node = head {
            if try predicate(node.value) { break }
            res.append(node.value)
            head = node.next
            size -= 1
        }
        if head == nil { tail = nil }
        return res
    }
}



extension Queue: Sequence {
    public struct Iterator: IteratorProtocol {
        private var node: Queue.Node?
        fileprivate init(queue: Queue) {
            self.node = queue.head
        }
        public mutating func next() -> Element? {
            guard let tmp = node else { return nil }
            node = node?.next
            return tmp.value
        }
    }
    public func makeIterator() -> Iterator {
        Iterator(queue: self)
    }
}

extension Queue: ExpressibleByArrayLiteral {
    public convenience init(arrayLiteral elements: Element...) {
        self.init()
        for element in elements { offerLast(element) }
    }
}
