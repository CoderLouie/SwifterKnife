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


public final class Animations {
    public typealias Work = () -> Void
    
    public let work: Work
    public let duration: TimeInterval
    private var next: Animations?
    
    public init(_ duration: TimeInterval, work: @escaping Work) {
        self.duration = duration
        self.work = work
    }
    
    @discardableResult
    public func append(_ duration: TimeInterval, work: @escaping Work) -> Animations {
        var last = self
        while let next = last.next { last = next }
        last.next = Animations(duration, work: work)
        return self
    }
    
    public func run() {
        UIView.animate(withDuration: duration, animations: work) { [weak self] finished in
            guard finished, let next = self?.next else { return }
            next.run()
        }
    }
}

/*

fileprivate var my_animate_key: UInt8 = 0
fileprivate var my_inset_key: UInt8 = 0
public extension UIView {
    enum PresentDirection: Int {
        case top, bottom, leading, traing
        fileprivate var isHorizontal: Bool {
            switch self {
            case .leading, .traing: return true
            case .top, .bottom: return false
            }
        }
    }
    
    private var myPresentDirection: PresentDirection? {
        get {
            guard let v = objc_getAssociatedObject(self, &my_animate_key) as? Int else { return nil }
            return .init(rawValue: v)
        }
        set {
            objc_setAssociatedObject(self, &my_animate_key, newValue?.rawValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    private var myPresentionInset: UIEdgeInsets? {
        get {
            objc_getAssociatedObject(self, &my_inset_key) as? UIEdgeInsets
        }
        set {
            objc_setAssociatedObject(self, &my_inset_key, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    private func doBeforeDismiss(view: UIView,
                                 from direction: PresentDirection,
                                 inset: UIEdgeInsets) {
        view.snp.remakeConstraints { make in
            switch direction {
            case .top:
                make.bottom.equalTo(self.snp.top)
                make.leading.equalTo(inset.left)
                make.trailing.equalTo(-inset.right)
            case .bottom:
                make.top.equalTo(self.snp.bottom)
                make.leading.equalTo(inset.left)
                make.trailing.equalTo(-inset.right)
            case .leading:
                make.trailing.equalTo(self.snp.leading)
                make.top.equalTo(inset.top)
                make.bottom.equalTo(-inset.bottom)
            case .traing:
                make.leading.equalTo(self.snp.trailing)
                make.top.equalTo(inset.top)
                make.bottom.equalTo(-inset.bottom)
            }
        }
    }
    func present(_ view: UIView,
                 from direction: PresentDirection,
                 inset: UIEdgeInsets = .zero,
                 duration interval: TimeInterval = 0.25,
                 animations: (() -> Void)? = nil,
                 completion: ((Bool) -> Void)? = nil) { 
        if view.myPresentDirection != direction ||
            view.myPresentionInset != inset {
            addSubview(view)
            view.myPresentDirection = direction
            view.myPresentionInset = inset
            self.doBeforeDismiss(view: view, from: direction, inset: inset)
            layoutIfNeeded()
        }
        
        view.snp.remakeConstraints { make in
            switch direction {
            case .top:
                make.top.equalTo(inset.top)
                make.leading.equalTo(inset.left)
                make.trailing.equalTo(-inset.right)
            case .bottom:
                make.bottom.equalTo(-inset.bottom)
                make.leading.equalTo(inset.left)
                make.trailing.equalTo(-inset.right)
            case .leading:
                make.leading.equalTo(inset.left)
                make.top.equalTo(inset.top)
                make.bottom.equalTo(-inset.bottom)
            case .traing:
                make.trailing.equalTo(-inset.right)
                make.top.equalTo(inset.top)
                make.bottom.equalTo(-inset.bottom)
            }
        }
        let animation = {
            self.layoutIfNeeded()
            animations?()
        }
        UIView.animate(withDuration: interval, animations: animation, completion: completion)
    }
    
    func dismiss(duration interval: TimeInterval = 0.25,
                 animations: (() -> Void)? = nil,
                 completion: ((Bool) -> Void)? = nil) {
        guard let direction = myPresentDirection,
                let inset = myPresentionInset,
                let superv = superview else { return }
        superv.doBeforeDismiss(view: self, from: direction, inset: inset)
        let animation = {
            superv.layoutIfNeeded()
            animations?()
        }
        UIView.animate(withDuration: interval, animations: animation, completion: completion)
    }
}
*/

