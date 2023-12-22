//
//  Stack.swift
//  SwifterKnife
//
//  Created by liyang on 2021/10/19.
//

import Foundation

/// Swift 栈数据结构
public final class Stack<Element> {
    fileprivate final class Node {
        var value: Element
        let next: Node?
        init(_ value: Element, _ next: Node? = nil) {
            self.value = value
            self.next = next
        }
    }
    private var size = 0
    fileprivate var head: Node? = nil
    
    public init() {}
    
    public func push(_ element: Element) {
        let node = Node(element, head)
        head = node
        size += 1
    }
    
    public func popAll() {
        head = nil
        size = 0
    }
    public func popToKeepCount(_ n: Int) {
        if n >= size || n < 0 { return }
        while size != n {
            head = head?.next
            size -= 1
        }
    }

    @discardableResult
    public func pop() -> Element? {
        guard let node = head else { return nil }
        head = node.next
        size -= 1
        return node.value
    }
    
    public var top: Element? {
        get { head?.value }
        set {
            if let val = newValue {
                head?.value = val
            } else {
                pop()
            }
        }
    }
    /// 只是为了和其他API统一
    public var first: Element? {
        get { top }
        set {
            top = newValue
        }
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


extension Stack: Sequence {
    public struct Iterator: IteratorProtocol {
        private var node: Stack.Node?
        fileprivate init(stack: Stack) {
            self.node = stack.head
        }
        public mutating func next() -> Element? {
            guard let tmp = node else { return nil }
            node = node?.next
            return tmp.value
        }
    }
    public func makeIterator() -> Iterator {
        Iterator(stack: self)
    }
}

extension Stack: ExpressibleByArrayLiteral {
    public convenience init(arrayLiteral elements: Element...) {
        self.init()
        for element in elements { push(element) }
    }
}
