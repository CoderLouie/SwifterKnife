//
//  PriorityQueue.swift
//  SwifterKnife
//
//  Created by liyang on 2021/10/19.
//

import Foundation

/// Swift 优先级队列
public final class PriorityQueue<Element> {
    private var items: [[Element]] = []
    private let comparator: (Element, Element) -> Bool
    
    public enum Position {
        case front
        case first(idx: Int)
        case tail
        case last(idx: Int)
    }
    /// comparator 需要实现为 >= 或者是 <=逻辑关系, 实现为 > 或者 < 逻辑关系是不够的
    public init(by comparator: @escaping (Element, Element) -> Bool) {
        self.comparator = comparator
    }
    public convenience init<T: Collection>(elements: T, by comparator: @escaping (Element, Element) -> Bool) where T.Element == Element {
        self.init(by: comparator)
        items = divideItems(elements)
    }
    private func divideItems<T: Collection>(_ elements: T) -> [[T.Element]] where T.Element == Element {
        let count = elements.count
        guard count > 0 else { return [] }
        let elements = elements.sorted { return comparator($0, $1) ? !comparator($1, $0) : false }
        var res = [[elements[0]]]
        var i = 1;
        var j = 0
        while i < count {
            let element = elements[i]
            if !comparator(element, elements[i - 1]) {
                res.append([element])
                j += 1
            } else {
                res[j].append(element)
            }
            i += 1
        }
        return res
    }
    public func offer(_ newElement: Element, at position: Position = .tail) {
        var li = 0, ri = items.count
        while li < ri {
            let mi = (li + ri) >> 1
            let mItem = items[mi][0]
            if comparator(mItem, newElement) {
                if comparator(newElement, mItem) { // ==
                    let targetIdx = items[mi].index(of: position)
                    items[mi].insert(newElement, at: targetIdx)
                    return
                } else { li = mi + 1 /* > */}
            } else { ri = mi /* < */}
        }
        items.insert([newElement], at: li)
    }
    public func offer<T: Collection>(contentsOf elements: T, at position: Position = .tail) where T.Element == Element {
        let count = elements.count
        guard count > 0 else { return }
        let division = divideItems(elements)
        var i1 = items.count - 1, i2 = division.count - 1
        while i2 >= 0 {
            let addes = division[i2]
            if i1 < 0 {
                items.insert(addes, at: 0)
                i2 -= 1; continue;
            }
            let v1 = items[i1][0]
            let v2 = addes[0]
            if comparator(v2, v1) {
                if comparator(v1, v2) {// v2 == v1
                    let targetIdx = items[i1].index(of: position)
                    items[i1].insert(contentsOf: addes, at: targetIdx)
                    i1 -= 1; i2 -= 1;
                } else {// v2 > v1 
                    i1 -= 1
                }
            } else { // v2 < v1
                items.insert(addes, at: i1 + 1)
                i2 -= 1
            }
        }
    }
    public func replace(_ newElement: Element, at position: Position = .tail) -> Element? {
        if items.count == 0 {
            items.append([newElement])
            return nil
        } else {
            let top = poll()
            offer(newElement, at: position);
            return top
        }
    }
    
    public var peek: Element {
        guard !items.isEmpty else { fatalError("PriorityQueue is empty") }
        return items[0][0]
    }
    public func poll() -> Element {
        guard !items.isEmpty else { fatalError("PriorityQueue is empty") }
        let top = items[0].removeFirst()
        if (items[0].isEmpty) { items.removeFirst() }
        return top
    }
    public func clear() {
        items = []
    }
    
    public func contains(where predicate: (Element) throws -> Bool) rethrows -> Bool {
        return try items.flatMap { $0 }.contains(where: predicate)
    }
    @discardableResult
    public func place(where predicate: (Element) throws -> Bool, at position: Position) rethrows -> Element? {
        var i = 0
        var idx: Int? = nil
        while i < items.count {
            idx = try items[i].firstIndex(where: predicate)
            if idx != nil { break }
            i += 1
        }
        guard let j = idx else { return nil }
        let targetIdx = items[i].index(of: position)
        let val = items[i].remove(at: j)
        items[i].insert(val, at: targetIdx)
        return val
    }
    
    public var count: Int {
        items.reduce(0) { $0 + $1.count }
    }
    public var isEmpty: Bool { return items.count == 0 }
}


private extension PriorityQueue.Position {
    var isFront: Bool {
        switch self {
        case .front, .first(idx: _): return true
        default: return false
        }
    }
    var offset: Int {
        switch self {
        case .front, .tail: return 0
        case .first(idx: let pos), .last(idx: let pos): return pos
        }
    }
}

extension PriorityQueue where Element: Comparable {
    public convenience init<T: Collection>(items: T) where T.Element == Element {
        self.init(elements: items, by: >=)
    }
    public convenience init() { self.init(by: >=) }
    static var maximum: PriorityQueue { return .init(by: >=) }
    static var minimum: PriorityQueue { return .init(by: <=) }
}
extension PriorityQueue where Element: Equatable {
    @discardableResult
    public func place(element: Element, at position: Position) -> Element? {
        return place(where: { $0 == element }, at: position)
    }
    public func contains(_ element: Element) -> Bool {
        return contains { $0 == element }
    }
}

extension PriorityQueue: ExpressibleByArrayLiteral where Element: Comparable {
    public convenience init(arrayLiteral elements: Element...) {
        self.init(items: elements)
    }
}

extension PriorityQueue: CustomStringConvertible {
    public var description: String {
//        return items.flatMap { $0 }.description
        return items.description
    }
}


private extension Array {
    func index(of position: PriorityQueue<Element>.Position) -> Index {
        let offset = position.offset
        return position.isFront ?
            index(0, offsetBy: offset, limitedBy: endIndex) ?? endIndex :
            index(endIndex, offsetBy: -offset, limitedBy: 0) ?? 0
    }
}
