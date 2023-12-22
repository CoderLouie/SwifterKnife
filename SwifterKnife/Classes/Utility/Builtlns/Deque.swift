//
//  Deque.swift
//  SwifterKnife
//
//  Created by liyang on 2021/10/19.
//

import Foundation

/// Swift 双端队列
public final class Deque<Element> {
    fileprivate final class Node {
        var value: Element?
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
    
    fileprivate var head: Node? {
        get { root.next }
        set { root.next = newValue }
    }
    private var tail: Node? {
        get { root.prev }
        set { root.prev = newValue }
    }
    public init() {}
    
    /// 头部入队
    public func offerFirst(_ element: Element) {
        let node = Node(element, next: head)
        head?.prev = node
        head = node
        if tail == nil { tail = node }
        size += 1
    }
    /// 尾部入队
    public func offerLast(_ element: Element) {
        let node = Node(element, prev: tail)
        tail?.next = node
        tail = node
        if head == nil { head = node }
        size += 1
    }
    
    /// 头部出队
    @discardableResult
    public func pollFirst() -> Element? {
        guard let node = head else { return nil }
        node.next?.prev = nil
        head = node.next
        if head == nil { tail = nil }
        size -= 1
        return node.value
    }
    
    /// 尾部出队
    @discardableResult
    public func pollLast() -> Element? {
        guard let node = tail else { return nil }
        tail?.next = nil
        tail = node.prev
        if tail == nil { head = nil }
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
    public var last: Element? {
        get { tail?.value }
        set {
            if let val = newValue {
                tail?.value = val
            } else {
                pollLast()
            }
        }
    }
    
    public var count: Int { size }
    public var isEmpty: Bool { size == 0 }
}
 

extension Deque: Sequence {
    public struct Iterator: IteratorProtocol {
        private var node: Deque.Node?
        fileprivate init(queue: Deque) {
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

extension Deque: ExpressibleByArrayLiteral {
    public convenience init(arrayLiteral elements: Element...) {
        self.init()
        for element in elements { offerLast(element) }
    }
}
