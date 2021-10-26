//
//  Queue.swift
//  SwifterKnife
//
//  Created by liyang on 2021/10/19.
//

import Foundation

/// Swift 队列
public final class Queue<Element> {
    fileprivate class Node {
        let value: Element
        var next: Node?
        init(_ value: Element, _ next: Node? = nil) {
            self.value = value
            self.next = next
        }
    }
    private var size = 0
    fileprivate var head: Node? = nil
    private var tail: Node? = nil
    
    /// 尾部入队
    public func offerLast(_ element: Element) {
        let node = Node(element)
        if head == nil { head = node }
        else { tail?.next = node }
        tail = node
        size += 1
    }
    /// 头部入队
    public func offerFirst(_ element: Element) {
        let node = Node(element, head)
        if tail == nil { tail = node }
        head = node
        size += 1
    }
    /// 头部出队
    @discardableResult
    public func pollFirst() -> Element? {
        guard let first = head else { return nil }
        head = first.next
        if head == nil { tail = nil }
        size -= 1
        return first.value
    }
    /// 头部元素
    public var peekFirst: Element? {
        return head?.value
    }
    /// 尾部元素
    public var peekLast: Element? {
        return tail?.value
    }
    public var count: Int { return size }
    public var isEmpty: Bool { return size == 0 }
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


public struct QueueIterator<Item>: IteratorProtocol {
    private var node: Queue<Item>.Node?
    public init(queue: Queue<Item>) {
        self.node = queue.head
    }
    public mutating func next() -> Item? {
        guard let tmp = node else { return nil }
        node = node?.next
        return tmp.value
    }
}
extension Queue: Sequence {
    public func makeIterator() -> QueueIterator<Element> {
        QueueIterator(queue: self)
    }
}

extension Queue: ExpressibleByArrayLiteral {
    public convenience init(arrayLiteral elements: Element...) {
        self.init()
        for element in elements { offerLast(element) }
    }
}
