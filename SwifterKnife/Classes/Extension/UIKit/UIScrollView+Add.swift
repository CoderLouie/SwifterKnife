//
//  UIScrollView+Add.swift
//  SwifterKnife
//
//  Created by liyang on 2021/10/19.
//

import UIKit

// MARK: - Methods

public extension UIScrollView {
    /// Takes a snapshot of an entire ScrollView.
    ///
    ///    AnySubclassOfUIScrollView().snapshot
    ///    UITableView().snapshot
    ///
    /// - Returns: Snapshot as UIImage for rendered ScrollView.
    var snapshot: UIImage? {
        // Original Source: https://gist.github.com/thestoics/1204051
        UIGraphicsBeginImageContextWithOptions(contentSize, false, 0)
        defer {
            UIGraphicsEndImageContext()
        }
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        let prevFrame = frame
        let prevOffset = contentOffset
        let prevBounds = layer.bounds
        
        let contentSize = contentSize
        if #available(iOS 13, *) {
            layer.bounds = CGRect(origin: .zero, size: contentSize)
        }
        contentOffset = .zero
        frame = CGRect(origin: .zero, size: contentSize)
        layer.render(in: context)
        frame = prevFrame
        contentOffset = prevOffset
        if #available(iOS 13, *) {
            layer.bounds = prevBounds
        }
        return UIGraphicsGetImageFromCurrentImageContext()
    }

    /// The currently visible region of the scroll view.
    var currentVisibleRect: CGRect {
        let contentS = contentSize
        let offset = contentOffset
        let bounds = bounds
        let w = min(bounds.width, contentS.width)
        let width = min(w, contentS.width - offset.x)
        let h = min(bounds.height, contentS.height)
        let height = min(h, contentS.height - offset.y)
        return CGRect(origin: offset, size: CGSize(width: width, height: height))
    }
}

public extension UIScrollView {
    /// Scroll to the top-most content offset.
    /// - Parameter animated: `true` to animate the transition at a constant velocity to the new offset, `false` to make the transition immediate.
    func scrollToTop(animated: Bool = true) {
        setContentOffset(CGPoint(x: contentOffset.x, y: -contentInset.top), animated: animated)
    }

    /// Scroll to the left-most content offset.
    /// - Parameter animated: `true` to animate the transition at a constant velocity to the new offset, `false` to make the transition immediate.
    func scrollToLeft(animated: Bool = true) {
        setContentOffset(CGPoint(x: -contentInset.left, y: contentOffset.y), animated: animated)
    }

    /// Scroll to the bottom-most content offset.
    /// - Parameter animated: `true` to animate the transition at a constant velocity to the new offset, `false` to make the transition immediate.
    func scrollToBottom(animated: Bool = true) {
        let inset = contentInset
        let bounds = bounds
        let contentS = contentSize
        if bounds.height > contentS.height + inset.bottom { return }
        
        var off = contentOffset
        off.y = max(0, contentS.height - bounds.height) + inset.bottom
        setContentOffset(off, animated: animated)
    }

    /// Scroll to the right-most content offset.
    /// - Parameter animated: `true` to animate the transition at a constant velocity to the new offset, `false` to make the transition immediate.
    func scrollToRight(animated: Bool = true) {  
        let inset = contentInset
        let bounds = bounds
        let contentS = contentSize
        if bounds.width > contentS.width + inset.right { return }
        
        var off = contentOffset
        off.y = max(0, contentS.width - bounds.width) + inset.right
        setContentOffset(off, animated: animated)
    }

    /// Scroll up one page of the scroll view.
    /// If `isPagingEnabled` is `true`, the previous page location is used.
    /// - Parameter animated: `true` to animate the transition at a constant velocity to the new offset, `false` to make the transition immediate.
    func scrollUp(animated: Bool = true) {
        let minY = -contentInset.top
        var y = max(minY, contentOffset.y - bounds.height)
        if isPagingEnabled,
            bounds.height != 0 {
            let page = max(0, ((y + contentInset.top) / bounds.height).rounded(.down))
            y = max(minY, page * bounds.height - contentInset.top)
        }
        setContentOffset(CGPoint(x: contentOffset.x, y: y), animated: animated)
    }

    /// Scroll left one page of the scroll view.
    /// If `isPagingEnabled` is `true`, the previous page location is used.
    /// - Parameter animated: `true` to animate the transition at a constant velocity to the new offset, `false` to make the transition immediate.
    func scrollLeft(animated: Bool = true) {
        let minX = -contentInset.left
        var x = max(minX, contentOffset.x - bounds.width)
        if isPagingEnabled,
            bounds.width != 0 {
            let page = ((x + contentInset.left) / bounds.width).rounded(.down)
            x = max(minX, page * bounds.width - contentInset.left)
        }
        setContentOffset(CGPoint(x: x, y: contentOffset.y), animated: animated)
    }

    /// Scroll down one page of the scroll view.
    /// If `isPagingEnabled` is `true`, the next page location is used.
    /// - Parameter animated: `true` to animate the transition at a constant velocity to the new offset, `false` to make the transition immediate.
    func scrollDown(animated: Bool = true) {
        let maxY = max(0, contentSize.height - bounds.height) + contentInset.bottom
        var y = min(maxY, contentOffset.y + bounds.height)
        if isPagingEnabled,
            bounds.height != 0 {
            let page = ((y + contentInset.top) / bounds.height).rounded(.down)
            y = min(maxY, page * bounds.height - contentInset.top)
        }
        setContentOffset(CGPoint(x: contentOffset.x, y: y), animated: animated)
    }

    /// Scroll right one page of the scroll view.
    /// If `isPagingEnabled` is `true`, the next page location is used.
    /// - Parameter animated: `true` to animate the transition at a constant velocity to the new offset, `false` to make the transition immediate.
    func scrollRight(animated: Bool = true) {
        let maxX = max(0, contentSize.width - bounds.width) + contentInset.right
        var x = min(maxX, contentOffset.x + bounds.width)
        if isPagingEnabled,
            bounds.width != 0 {
            let page = ((x + contentInset.left) / bounds.width).rounded(.down)
            x = min(maxX, page * bounds.width - contentInset.left)
        }
        setContentOffset(CGPoint(x: x, y: contentOffset.y), animated: animated)
    }
}



public extension UIScrollView {
    var insetT: CGFloat {
        get { contentInset.top }
        set { contentInset.top = newValue }
    }
    var insetB: CGFloat {
        get { contentInset.bottom }
        set { contentInset.bottom = newValue }
    }
    var insetL: CGFloat {
        get { contentInset.left }
        set { contentInset.left = newValue }
    }
    var insetR: CGFloat {
        get { contentInset.right }
        set { contentInset.right = newValue }
    }
    
    
    var offsetT: CGFloat {
        get { contentOffset.y }
        set { contentOffset.y = newValue }
    }
    var offsetB: CGFloat {
        get { contentOffset.y + bounds.size.height }
        set { contentOffset.y = newValue - bounds.size.height }
    }
    var offsetL: CGFloat {
        get { contentOffset.x }
        set { contentOffset.x = newValue }
    }
    var offsetR: CGFloat {
        get { contentOffset.x + bounds.size.width }
        set { contentOffset.x = newValue - bounds.size.width }
    }
    
    
    var contentW: CGFloat {
        get { contentSize.width }
        set { contentSize.width = newValue }
    }
    var contentH: CGFloat {
        get { contentSize.height }
        set { contentSize.height = newValue }
    }
    
    var scrollableW: CGFloat {
        contentInset.left + contentSize.width + contentInset.right
    }
    var scrollableH: CGFloat {
        contentInset.top + contentSize.height + contentInset.bottom
    }
    
    // bingo
    var offsetTMin: CGFloat {
        -contentInset.top
    }
    // bingo
    var offsetTMax: CGFloat {
        max(0, contentSize.height - bounds.height) + contentInset.bottom
    }
    // bingo
    var offsetBMin: CGFloat {
        offsetTMin + bounds.size.height
    }
    // bingo
    var offsetBMax: CGFloat {
        offsetTMax + bounds.height
    }
    // bingo
    var offsetLMin: CGFloat {
        -contentInset.left
    }
    // bingo
    var offsetLMax: CGFloat {
        max(0, contentSize.width - bounds.width) + contentInset.right
    }
    // bingo
    var offsetMinR: CGFloat {
        offsetLMin + bounds.size.width
    }
    // bingo
    var offsetMaxR: CGFloat {
        offsetLMax + bounds.size.width
    }
    
    var atTopPosition: Bool {
        offsetT == offsetTMin
    }
    var atBottomPosition: Bool {
        offsetT == offsetTMax
    }
    var atLeftPosition: Bool {
        offsetL == offsetLMin
    }
    var atRightPosition: Bool {
        offsetL == offsetLMax
    }
}

public extension UIScrollView {
    enum ScrollDirection {
        case horizontal
        case vertical
    }
    
    func pageIndex(at direction: ScrollDirection = .horizontal) -> Int {
        switch direction {
        case .horizontal:
            let width = bounds.size.width
            return Int((contentOffset.x + width * 0.5) / width)
        case .vertical:
            let height = bounds.size.height
            return Int((contentOffset.y + height * 0.5) / height)
        }
    }
    
    func roll(distance: CGFloat, at direction: ScrollDirection = .horizontal,  animated: Bool = true) {
        var offset = contentOffset
        switch direction {
        case .horizontal:
            offset.x += distance
        case .vertical:
            offset.y += distance
        }
        setContentOffset(offset, animated: animated)
    }
    func roll(toPageIndex index: Int, at direction: ScrollDirection = .horizontal, animated: Bool = true) {
        let size = bounds.size
        var offset: CGPoint = .zero
        switch direction {
        case .horizontal:
            offset.x = size.width * CGFloat(index)
        case .vertical:
            offset.y = size.height * CGFloat(index)
        }
        setContentOffset(offset, animated: animated)
    }
    
    struct PanDirection: OptionSet {
        public let rawValue: Int
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
        public static var unknown: PanDirection { .init(rawValue: 0) }
        public static var up: PanDirection { .init(rawValue: 1 << 0) }
        public static var down: PanDirection { .init(rawValue: 1 << 1) }
        public static var left: PanDirection { .init(rawValue: 1 << 2) }
        public static var right: PanDirection { .init(rawValue: 1 << 3) }
    }
    
    var panDirection: PanDirection {
        var directions: PanDirection = .unknown
        let point = panGestureRecognizer.translation(in: superview)
        if point.y > 0 {
            directions.formUnion(.up)
        }
        if point.y < 0 {
            directions.formUnion(.down)
        }
        if point.x < 0 {
            directions.formUnion(.left)
        }
        if point.x > 0 {
            directions.formUnion(.right)
        }
        return directions
    }
}

@available(iOS 11.0, *)
public protocol BatchUpdatable {
    func performBatchUpdates(_ updates: (() -> Void)?, completion: ((Bool) -> Void)?)
}
extension UITableView: BatchUpdatable {}
extension UICollectionView: BatchUpdatable {}

@available(iOS 11.0, *)
extension BatchUpdatable {
    public func batchUpdates(withDuration duration: TimeInterval, _ updates: (() -> Void)?, completion: ((Bool) -> Void)? = nil) {
        if duration > 0 {
            UIView.animate(
                withDuration: duration,
                delay: 0,
                usingSpringWithDamping: 1,
                initialSpringVelocity: 0,
                options: [
                    .beginFromCurrentState,
                    .allowUserInteraction,
                    .overrideInheritedCurve,
                    .overrideInheritedOptions,
                    .overrideInheritedDuration
                ]) {
                    self.performBatchUpdates(updates, completion: completion)
                }
        } else {
            UIView.performWithoutAnimation {
                self.performBatchUpdates(updates, completion: completion)
            }
        }
    }
}
