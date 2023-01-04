//
//  UnionFind.swift
//  SwifterKnife
//
//  Created by liyang on 2021/10/19.
//

import Foundation

/// Swift 并查集
public final class UnionFind<Element: Hashable> {
    private class Node: Equatable {
        let val: Element
        var rank: Int = 1
        lazy var parent: Node = self
        init(_ val: Element) {
            self.val = val
        }
        static func == (lhs: Node, rhs: Node) -> Bool {
            if lhs === rhs { return true }
            return lhs.val == rhs.val
        }
    }
    private var size: Int = 0
    private var map: [Element: Node] = [:]
    
    public init() {}
    
    public func makeSet<T: Collection>(_ elements: T) where T.Element == Element {
        for element in elements {
            if let _ = map[element] { continue }
            map[element] = Node(element)
            size += 1
        }
    }
    public func makeSet(_ element: Element) {
        guard let _ = map[element] else { return }
        map[element] = Node(element)
        size += 1
    }
    
    public func find(_ element: Element) -> Element? {
        return findNode(element)?.val
    }
    
    public func union(_ element1: Element, _ element2: Element) {
        guard let p1 = findNode(element1) else { return }
        guard let p2 = findNode(element2) else { return }
        if p1 == p2 { return }
        
        if p1.rank < p2.rank {
            p1.parent = p2
        } else if p1.rank > p2.rank {
            p2.parent = p1
        } else {
            p1.parent = p2
            p2.rank += 1
        }
        size -= 1
    }
    
    public func isConnected(_ element1: Element, _ element2: Element) -> Bool {
        return findNode(element1) == findNode(element2)
    }
    
    public var count: Int { return size }
    public var isEmpty: Bool { return size == 0 }
    
    private func findNode(_ element: Element) -> Node? {
        guard var node = map[element] else { return nil }
        while node != node.parent {
            // 查找的过程中路径减半
            node.parent = node.parent.parent
            node = node.parent
        }
        return node
    }
}

extension UnionFind: ExpressibleByArrayLiteral {
    public convenience init(arrayLiteral elements: Element...) {
        self.init()
        self.makeSet(elements)
    }
}


public final class IntUnionFind {
    // 表示有多少集合（帮派），连通分量
    private var size: Int
    private var elements: [Int]
    // 基于rank的优化：矮的树 嫁接到 高的树
    private var ranks: [Int]
    public init(capacity: Int) {
        size = capacity
        elements = Array(repeating: 0, count: capacity)
        for i in 0..<capacity { elements[i] = i }
        ranks = Array(repeating: 1, count: capacity)
    }
    public var count: Int { return size }
    public var isEmpty: Bool { return size == 0 }
    public func find(_ element: Int) -> Int? {
        guard contains(element) else { return nil }
        var v = element
        while v != elements[v] {
            // 路径减半：使路径上每隔一个节点就指向其祖父节点（parent的parent）
            elements[v] = elements[elements[v]]
            v = elements[v]
        }
        return v
    }
    
    public func union(_ element1: Int, _ element2: Int) {
        guard let p1 = find(element1) else { return }
        guard let p2 = find(element2) else { return }
        if p1 == p2 { return }
        if ranks[p1] < ranks[p2] {
            elements[p1] = p2
        } else if ranks[p1] > ranks[p2] {
            elements[p2] = p1
        } else {
            elements[p1] = p2
            ranks[p2] += 1
        }
        size -= 1
    }
    public func isConnected(_ element1: Int, _ element2: Int) -> Bool {
        return find(element1) == find(element2)
    }
    
    private func contains(_ element: Int) -> Bool {
        return element >= 0 && element < elements.count
    }
}
