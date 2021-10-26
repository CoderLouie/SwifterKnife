//
//  Stack.swift
//  SwifterKnife
//
//  Created by liyang on 2021/10/19.
//

import Foundation

/// Swift 栈数据结构
public final class Stack<Element> {
    fileprivate class Node {
        let value: Element
        let next: Node?
        init(_ value: Element, _ next: Node? = nil) {
            self.value = value
            self.next = next
        }
    }
    private var size = 0
    fileprivate var head: Node? = nil
    
    public func push(_ element: Element) {
        let node = Node(element, head)
        head = node
        size += 1
    }
    
    @discardableResult
    public func pop() -> Element? {
        guard let first = head else { return nil }
        head = first.next
        size -= 1
        return first.value
    }
    public var top: Element? {
        return head?.value
    }
    public var count: Int { return size }
    public var isEmpty: Bool { return size == 0 }
}

public extension Stack {
    @discardableResult
    func pop(while predicate: (Element) throws -> Bool) rethrows -> [Element]  {
        var res: [Element] = []
        while let node = head {
            if try predicate(node.value) { break }
            res.append(node.value)
            head = node.next
            size -= 1
        }
        return res
    } 
}

public struct StackIterator<Item>: IteratorProtocol {
    private var node: Stack<Item>.Node?
    public init(stack: Stack<Item>) {
        self.node = stack.head
    }
    public mutating func next() -> Item? {
        guard let tmp = node else { return nil }
        node = node?.next
        return tmp.value
    }
}
extension Stack: Sequence {
    public func makeIterator() -> StackIterator<Element> {
        StackIterator(stack: self)
    }
}

extension Stack: ExpressibleByArrayLiteral {
    public convenience init(arrayLiteral elements: Element...) {
        self.init()
        for element in elements { push(element) }
    }
}
