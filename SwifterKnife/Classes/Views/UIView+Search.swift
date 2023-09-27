//
//  UIView+Search.swift
//  SwifterKnife
//
//  Created by liyang on 2023/3/9.
//

import UIKit

public extension UIView {
    /// 前序遍历
    func searchInPreorder<T: UIView>(where condition: (T) -> Bool) -> T? {
        let stack: Stack<UIView> = [self]
        while let top = stack.pop() {
            if let t = top as? T, condition(t) {
                return t
            }
            for subview in top.subviews.reversed() {
                stack.push(subview)
            }
        }
        return nil
    }
    /// 后序遍历
    func searchInPostorder<T: UIView>(where condition: (T) -> Bool) -> T? {
        let stack: Stack<UIView> = [self]
        let res: Stack<UIView> = .init()
        while let top = stack.pop() {
            res.push(top)
            for subview in top.subviews {
                stack.push(subview)
            }
        }
        for view in res {
            if let t = view as? T, condition(t) {
                return t
            }
        }
        return nil
    }
    /// 层序遍历
    func searchInLevelOrder<T: UIView>(where condition: (T, (level: Int, index: Int)) -> Bool) -> T? {
        let queue: Queue<UIView> = [self]
        var pair: (Int, Int) = (0, 0)
        while !queue.isEmpty {
            for _ in 0..<queue.count {
                let first = queue.pollFirst()!
                if let t = first as? T, condition(t, pair) {
                    return t
                }
                pair.1 += 1
                for subview in first.subviews {
                    queue.offerLast(subview)
                }
            }
            pair.0 += 1
            pair.1 = 0
        }
        return nil
    }
}
