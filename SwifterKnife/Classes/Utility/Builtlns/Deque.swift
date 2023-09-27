//
//  Deque.swift
//  SwifterKnife
//
//  Created by liyang on 2021/10/19.
//

import Foundation

/// Swift 双端队列
public final class Deque<Element> {
    fileprivate class Node {
        let value: Element?
        var next: Node?
        unowned var prev: Node?
        init(_ value: Element? = nil, next: Node? = nil, prev: Node? = nil) {
            self.value = value
            self.next = next
            self.prev = prev
        }
    }
    
    private var size = 0
    /// next 指向头节点，prev指向尾节点
    fileprivate let root = Node()
    
    public init() {}
    
    /// 头部入队
    public func offerFirst(_ element: Element) {
        let node = Node(element, next: root.next)
        root.next?.prev = node
        root.next = node
        if root.prev == nil { root.prev = node }
        size += 1
    }
    
    /// 尾部入队
    public func offerLast(_ element: Element) {
        let node = Node(element, prev: root.prev)
        root.prev?.next = node
        root.prev = node
        if root.next == nil { root.next = node }
        size += 1
    }
    
    /// 头部出队
    @discardableResult
    public func pollFirst() -> Element? {
        guard let node = root.next else { return nil }
        node.next?.prev = nil
        root.next = node.next
        if root.next == nil { root.prev = nil }
        size -= 1
        return node.value
    }
    
    /// 尾部出队
    @discardableResult
    public func pollLast() -> Element? {
        guard let node = root.prev else { return nil }
        node.prev?.next = nil
        root.prev = node.prev
        if root.prev == nil { root.next = nil }
        size -= 1
        return node.value
    }
    
    public var peekFirst: Element? {
        return root.next?.value
    }
    public var peekLast: Element? {
        return root.prev?.value
    }
    
    public var count: Int { return size }
    public var isEmpty: Bool { return size == 0 }
}
 

public struct DequeIterator<Item>: IteratorProtocol {
    private var node: Deque<Item>.Node?
    public init(queue: Deque<Item>) {
        self.node = queue.root
    }
    public mutating func next() -> Item? {
        guard let tmp = node else { return nil }
        node = node?.next
        return tmp.value
    }
}
extension Deque: Sequence {
    public func makeIterator() -> DequeIterator<Element> {
        DequeIterator(queue: self)
    }
}

extension Deque: ExpressibleByArrayLiteral {
    public convenience init(arrayLiteral elements: Element...) {
        self.init()
        for element in elements { offerLast(element) }
    }
}
