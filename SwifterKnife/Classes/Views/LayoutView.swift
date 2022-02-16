//
//  LayoutView.swift
//  SwifterKnife
//
//  Created by liyang on 2021/10/19.
//

import UIKit
import SnapKit
 
// 只用做布局，不做渲染，类似UIStackView
open class VirtualView: UIView {
    private class VirtualLayer: CATransformLayer {
        override var backgroundColor: CGColor? {
            set {}
            get{ return nil }
        }
        override var isOpaque: Bool {
            set {}
            get { return false }
        }
    }
    public override class var layerClass: AnyClass {
        return VirtualLayer.self
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    open func setup() {}
    
    open override func didMoveToSuperview() {
        if let _ = superview {
            self.snp.makeConstraints { make in
                make.width.height.equalTo(1).priority(100)
            }
        }
    }
}

/**
 九宫格布局
 
 对该试图做好宽高度约束，根据warpCount，对其管理的子视图  固定宽高可以做等行列间距布局 / 固定行列间距可以做等宽高布局
 */
final public class SudokuView: VirtualView {
    public enum FixedBehaviour {
        case itemLength(_ width: CGFloat, _ height: CGFloat)
        case spacing(_ lineSpacing: CGFloat, _ InteritemSpacing: CGFloat)
    }
    public var contentInsets: UIEdgeInsets = .zero
    public var behaviour: FixedBehaviour = .spacing(10.fit, 10.fit)
    public var warpCount: Int = 3
    
    private var arrangedViews: [UIView] = []
    public var arrangedViewsCount: Int { return arrangedViews.count }
    
    public func addArrangedView(_ view: UIView) {
        insertArrangedView(view, at: arrangedViewsCount)
    }
    public func removeArrangedView(_ view: UIView) {
        arrangedViews.removeAll { $0 === view }
    }
    public func removeArrangedViewAt(_ index: Int) {
        arrangedViews.remove(at: index)
    }
    
    public func insertArrangedView(_ view: UIView, at index: Int) {
        insertSubview(view, at: index)
        arrangedViews.insert(view, at: index)
    }
    
    public func replaceArrangedViews() {
        arrangedViews.forEach { $0.snp.removeConstraints() }
        placeArrangedViews()
    }
    public func placeArrangedViews() {
        let views = arrangedViews
        let n = views.count
        guard n > 1, warpCount >= 0 else {
            return
        }
        
        let inset = contentInsets
        
        let remainder = n % warpCount
        let quotient = n / warpCount
        let rowCount = (remainder == 0) ? quotient : (quotient + 1)
        let columnCount = rowCount == 1 ? n : warpCount
        
        switch behaviour {
        case let .itemLength(width, height):
            for (i,v) in views.enumerated() {
                
                let currentRow = i / warpCount
                let currentColumn = i % warpCount
                
                v.snp.makeConstraints { make in
                    make.width.equalTo(width)
                    make.height.equalTo(height)
                    if currentRow == 0 {//fisrt row
                        make.top.equalTo(inset.top)
                    }
                    if currentRow == rowCount - 1 {//last row
                        make.bottom.equalTo(-inset.bottom)
                    }
                    
                    if currentRow != 0,
                       currentRow != rowCount - 1 {//other row
                        let offset = (CGFloat(1) - CGFloat(currentRow) / CGFloat(rowCount - 1)) *
                            (height + inset.top) -
                            CGFloat(currentRow) * inset.bottom / CGFloat(rowCount - 1)
                        make.bottom.equalTo(self).multipliedBy(CGFloat(currentRow) / CGFloat(rowCount - 1)).offset(offset)
                    }
                    
                    if currentColumn == 0 {//first col
                        make.leading.equalTo(inset.left)
                    }
                    if currentColumn == columnCount - 1 {//last col
                        make.trailing.equalTo(-inset.right)
                    }
                    
                    if currentColumn != 0,
                       currentColumn != columnCount - 1 {//other col
                        let offset = (CGFloat(1) - CGFloat(currentColumn) / CGFloat(columnCount - 1)) *
                            (width + inset.left) -
                            CGFloat(currentColumn) * inset.right / CGFloat(columnCount - 1)
                        make.trailing.equalTo(self).multipliedBy(CGFloat(currentColumn) / CGFloat(columnCount - 1)).offset(offset)
                    }
                }
            }
        case let .spacing(line, interitem):
            
            var prev: UIView!
            
            for (i, v) in views.enumerated() {
                
                let currentRow = i / warpCount
                let currentColumn = i % warpCount
                
                v.snp.makeConstraints { make in
                    if i > 0 { make.width.height.equalTo(views[0]) }
                    
                    if currentRow == 0 {
                        make.top.equalTo(inset.top)
                    } else {
                        make.top.equalTo(views[i-columnCount].snp.bottom).offset(line)
                    }
                    if currentRow == rowCount - 1 {
                        make.bottom.equalTo(-inset.bottom)
                    }
                    
                    if currentColumn == 0 {
                        make.leading.equalTo(inset.left)
                    } else {
                        make.leading.equalTo(prev.snp.trailing).offset(interitem)
                    }
                    if currentColumn == columnCount - 1 {
                        make.trailing.equalTo(-inset.right)
                    }
                }
                prev = v
            }
        }
    }
}
 

open class LayoutView: VirtualView {
    public enum Alignment {
        /// 左/上
        case start
        /// 中
        case center
        /// 右/下
        case end
    }
    
    public var contentInsets: UIEdgeInsets = .zero
    public let alignment: Alignment
    
    public init(_ alignment: Alignment = .center, frame: CGRect = .zero) {
        self.alignment = alignment
        super.init(frame: frame)
    }
     
    public override convenience init(frame: CGRect) {
        self.init(.center, frame: frame)
    }
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open var arrangedViews: [UIView] { subviews }
    public var arrangedViewsCount: Int { return arrangedViews.count }
    
    public func addArrangedView(_ view: UIView, alignment: Alignment? = nil) {
        insertArrangedView(view, at: arrangedViewsCount, alignment: alignment)
    }
    
    open func insertArrangedView(_ view: UIView, at index: Int, alignment: Alignment? = nil) { }
}

open class SequenceView: LayoutView {
    public enum FixedBehaviour {
        case itemLength(_ length: CGFloat)
        case spacing(_ spacing: CGFloat)
    }
    public var behaviour: FixedBehaviour = .spacing(10.fit)
    
    open func addArrangedViews(_ views: [UIView]) {}
    public func addArrangedViews(_ views: UIView...) {
        addArrangedViews(views)
    }
    
    fileprivate final class SequenceItem {
        let alignment: LayoutView.Alignment
        unowned let view: UIView
        init(view: UIView, alignment: LayoutView.Alignment) {
            self.view = view
            self.alignment = alignment
        }
    }
    
    fileprivate var items: [SequenceItem] = []
    open override var arrangedViews: [UIView] { items.map(\.view) }
    
    open override func insertArrangedView(_ view: UIView, at index: Int, alignment: LayoutView.Alignment? = nil) {
        insertSubview(view, at: index)
        let align = alignment ?? self.alignment
        items.insert(.init(view: view, alignment: align), at: index)
    }
    
    public func removeArrangedView(_ view: UIView) {
        items.removeAll { $0.view === view }
    }
    public func removeArrangedViewAt(_ index: Int) {
        items.remove(at: index)
    }
    
    open func placeArrangedViews() {}
    public func replaceArrangedViews() {
        items.forEach { $0.view.snp.removeConstraints() }
        placeArrangedViews()
    }
}


/// 对该试图做好宽度约束，可以对其管理的子视图 做固定宽度等间距布局 / 固定间距等宽度布局
final public class SequenceHView: SequenceView {
    public override func placeArrangedViews() {
        guard items.count > 1 else { return }
        
        let inset = contentInsets
        for item in items {
            item.view.snp.makeConstraints { make in
                switch item.alignment {
                case .start:
                    make.top.equalTo(inset.top)
                    make.bottom.lessThanOrEqualTo(-inset.bottom)
                case .center:
                    make.top.greaterThanOrEqualTo(inset.top)
                    make.bottom.lessThanOrEqualTo(-inset.bottom)
                    make.centerY.equalToSuperview()
                case .end:
                    make.top.greaterThanOrEqualTo(inset.top)
                    make.bottom.equalTo(-inset.bottom)
                }
            }
        }
        
        switch behaviour {
        case let .spacing(spacing):
            var prev: UIView?
            for view in arrangedViews {
                view.snp.makeConstraints { make in
                    guard let prev = prev else {//first one
                        make.leading.equalTo(inset.left)
                        return
                    }
                    make.width.equalTo(prev)
                    make.leading.equalTo(prev.snp.trailing).offset(spacing)
                }
                prev = view;
            }
            prev?.snp.makeConstraints { make in
                make.trailing.equalTo(-inset.right)
            }
        case let .itemLength(itemLength):
            let n = CGFloat(items.count - 1)
            var prev: UIView?
            for (i, v) in arrangedViews.enumerated() {
                v.snp.makeConstraints { make in
                    make.width.equalTo(itemLength)
                    if prev != nil {
                        let offset = (CGFloat(1) - (CGFloat(i) / n)) *
                            (itemLength + inset.left) -
                            CGFloat(i) * inset.right / n
                        make.trailing.equalTo(self).multipliedBy(CGFloat(i) / n).offset(offset)
                    } else {//first one
                        make.leading.equalTo(inset.left);
                    }
                     
                }
                prev = v;
            }
            prev?.snp.makeConstraints { make in
                make.trailing.equalTo(-inset.right);
            }
        }
    }
}

/// 对该试图做好高度约束，可以对其管理的子视图 做固定高度等间距布局 / 固定间距等高度布局
final public class SequenceVView: SequenceView {
    public override func placeArrangedViews() {
        guard items.count > 1 else { return }
        
        let inset = contentInsets
        for item in items {
            item.view.snp.makeConstraints { make in
                switch item.alignment {
                
                case .start:
                    make.leading.equalTo(inset.left)
                    make.trailing.lessThanOrEqualTo(-inset.right)
                case .center:
                    make.leading.greaterThanOrEqualTo(inset.left)
                    make.trailing.lessThanOrEqualTo(-inset.right)
                    make.centerX.equalToSuperview()
                case .end:
                    make.leading.greaterThanOrEqualTo(inset.left)
                    make.trailing.equalTo(-inset.right)
                }
            }
        }
        
        switch behaviour {
        case let .spacing(spacing):
            var prev: UIView?
            for view in arrangedViews {
                view.snp.makeConstraints { make in
                    guard let prev = prev else {//first one
                        make.top.equalTo(inset.top)
                        return
                    }
                    make.height.equalTo(prev)
                    make.top.equalTo(prev.snp.bottom).offset(spacing)
                }
                prev = view;
            }
            prev?.snp.makeConstraints { make in
                make.bottom.equalTo(-inset.bottom)
            }
        case let .itemLength(itemLength):
            let n = CGFloat(items.count - 1)
            var prev: UIView?
            for (i, v) in arrangedViews.enumerated() {
                v.snp.makeConstraints { make in
                    make.height.equalTo(itemLength)
                    if prev != nil {
                        let offset = (CGFloat(1) - (CGFloat(i) / n)) *
                            (itemLength + inset.top) -
                            CGFloat(i) * inset.bottom / n
                        make.bottom.equalTo(self).multipliedBy(CGFloat(i) / n).offset(offset)
                    } else {//first one
                        make.top.equalTo(inset.left);
                    }
                     
                }
                prev = v;
            }
            prev?.snp.makeConstraints { make in
                make.bottom.equalTo(-inset.right);
            }
        }
    }
}


open class QueueView: LayoutView { }

/// 垂直方向会自动根据对齐方式布局
final public class QueueVView: QueueView {
    
    public override func insertArrangedView(_ view: UIView, at index: Int, alignment: LayoutView.Alignment? = nil) {
        insertSubview(view, at: index)
        let inset = contentInsets
        let align = alignment ?? self.alignment
        
        view.snp.makeConstraints { make in
            switch align {
            case .start:
                make.top.equalTo(inset.top)
            case .center:
                make.centerY.equalToSuperview()
            case .end:
                make.bottom.equalTo(-inset.bottom)
            }
        }
    }
}

/// 水平方向会自动根据对齐方式布局
final public class QueueHView: QueueView {
    
    public override func insertArrangedView(_ view: UIView, at index: Int, alignment: LayoutView.Alignment? = nil) {
        insertSubview(view, at: index)
        let inset = contentInsets
        let align = alignment ?? self.alignment
        
        view.snp.makeConstraints { make in
            switch align {
                
            case .start:
                make.leading.equalTo(inset.left)
            case .center:
                make.centerX.equalToSuperview()
            case .end:
                make.trailing.equalTo(-inset.right)
            }
        }
    }
}


open class FlexView: LayoutView { }

/// 垂直方向会自动根据内容大小布局，开发者只需做好水平方向上的布局
final public class FlexVView: FlexView {
    
    public override func insertArrangedView(_ view: UIView, at index: Int, alignment: LayoutView.Alignment? = nil) {
        insertSubview(view, at: index)
        let inset = contentInsets
        let align = alignment ?? self.alignment
        
        view.snp.makeConstraints { make in
            switch align {
                
            case .start:
                make.top.equalTo(inset.top)
                make.bottom.lessThanOrEqualTo(-inset.bottom)
            case .center:
                make.top.greaterThanOrEqualTo(inset.top)
                make.bottom.lessThanOrEqualTo(-inset.bottom)
                make.centerY.equalToSuperview()
            case .end:
                make.top.greaterThanOrEqualTo(inset.top)
                make.bottom.equalTo(-inset.bottom)
            }
        }
    }
}

/// 水平方向会自动根据内容大小布局，开发者只需做好垂直方向上的布局
final public class FlexHView: FlexView {
    public override func insertArrangedView(_ view: UIView, at index: Int, alignment: LayoutView.Alignment? = nil) {
        insertSubview(view, at: index)
        let inset = contentInsets
        let align = alignment ?? self.alignment
        
        view.snp.makeConstraints { make in
            switch align {
                
            case .start:
                make.leading.equalTo(inset.left)
                make.trailing.lessThanOrEqualTo(-inset.right)
            case .center:
                make.leading.greaterThanOrEqualTo(inset.left)
                make.trailing.lessThanOrEqualTo(-inset.right)
                make.centerX.equalToSuperview()
            case .end:
                make.leading.greaterThanOrEqualTo(inset.left)
                make.trailing.equalTo(-inset.right)
            }
        }
    }
}


open class BoxView: LayoutView {
    public var spacing: CGFloat = .zero
    
    public func addArrangedView(_ view: UIView, spacing: CGFloat? = nil, alignment: LayoutView.Alignment? = nil) {
        insertArrangedView(view, at: arrangedViewsCount, spacing: spacing, alignment: alignment)
    }
    public override func insertArrangedView(_ view: UIView, at index: Int, alignment: LayoutView.Alignment? = nil) {
        insertArrangedView(view, at: index, spacing: spacing, alignment: alignment)
    }
    
    open func insertArrangedView(_ view: UIView,
                                 at index: Int,
                                 spacing: CGFloat? = nil,
                                 alignment: LayoutView.Alignment? = nil) { }
    
    
    @discardableResult
    public func showArrangedView<View: UIView>(_ view: View) -> View? {
        guard let idx = indexOfArrangedView(view) else { return nil }
        return showArrangedView(at: idx)
    }
    @discardableResult
    open func showArrangedView<View: UIView>(at index: Int) -> View {
        return subviews[index] as! View
    }
    
    @discardableResult
    public func hiddenArrangedView<View: UIView>(_ view: View) -> View? {
        guard let idx = indexOfArrangedView(view) else { return nil }
        return hiddenArrangedView(at: idx)
    }
    @discardableResult
    open func hiddenArrangedView<View: UIView>(at index: Int) -> View {
        return subviews[index] as! View
    }
    
    @discardableResult
    public func removeArrangedView<View: UIView>(_ view: View) -> View? {
        guard let idx = indexOfArrangedView(view) else { return nil }
        return removeArrangedView(at: idx)
    }
    @discardableResult
    open func removeArrangedView<View: UIView>(at index: Int) -> View? {
        let view = arrangedViews[index]
        view.removeFromSuperview()
        return view as? View
    }
    
    open func indexOfArrangedView<View>(_ view: View) -> Int? where View : UIView {
        return arrangedViews.firstIndex(of: view)
    }
}

final public class BoxHView: BoxView {
    private var items: [BoxHItem] = []
    private var rightConstraint: Constraint?
    
    public override var arrangedViews: [UIView] {
        return items.map { $0.view }
    }
    public override var arrangedViewsCount: Int {
        return items.count
    }
    public override func indexOfArrangedView<View>(_ view: View) -> Int? where View : UIView {
        items.firstIndex { $0.view === view }
    }
    
    public override func insertArrangedView(_ view: UIView,
                                            at index: Int,
                                            spacing: CGFloat? = nil,
                                            alignment: LayoutView.Alignment? = nil) {
        let count = items.count
        precondition(index <= count)
        insertSubview(view, at: index)
        
        let inset = contentInsets
        let align = alignment ?? self.alignment
        let space = spacing ?? self.spacing
        
        let item = BoxHItem(view: view)
        item.makeVCons(alignment: align, inset: inset)
        item.margin = index == 0 ? 0 : space
        
        if view.isHidden {
            let prevView: UIView? = index == 0 ? nil : items[index - 1].view
            view.snp.makeConstraints { make in
                if let prevView = prevView {
                    item.leading = make.leading.equalTo(prevView.snp.trailing).offset(space).constraint
                } else {
                    item.leading = make.leading.equalTo(inset.left).constraint
                }
            }
            item.uninstall()
        } else {
            let next = _firstNoHiddenItem(from: index)
            if next?.margin == 0 { next?.margin = space }
            
            let prev = _lastNoHiddenItem(from: index - 1)
            _reconnect(from: next, to: prev, through: item)
        }
        items.insert(item, at: index)
    }
    
    public override func removeArrangedView<View>(at index: Int) -> View? where View : UIView {
        let count = items.count
        precondition(index < count)
        
        let item = items[index]
        item.uninstall()
        
        let view = item.view
        view.removeFromSuperview()
        items.remove(at: index)

        let next = _firstNoHiddenItem(from: index)
        
        let prev = _lastNoHiddenItem(from: index - 1)
        _reconnect(from: next, to: prev, skipOver: item)
        
        return view as? View
    }
    
    public override func hiddenArrangedView<View>(at index: Int) -> View where View : UIView {
        let count = items.count
        precondition(index < count)
        
        let item = items[index]
        
        let view = item.view
        if view.isHidden { return view as! View }
        
        view.isHidden = true
        item.uninstall()
        
        let next = _firstNoHiddenItem(from: index + 1)
        let prev = _lastNoHiddenItem(from: index - 1)
        _reconnect(from: next, to: prev, skipOver: item)
        
        return view as! View
    }
    
    public override func showArrangedView<View>(at index: Int) -> View where View : UIView {
        let count = items.count
        precondition(index < count)
        
        let item = items[index]
        
        let view = item.view
        if !view.isHidden { return view as! View }
        
        view.isHidden = false
        item.installVCons()
        
        let next = _firstNoHiddenItem(from: index + 1)
        let prev = _lastNoHiddenItem(from: index - 1)
        _reconnect(from: next, to: prev, through: item)
        
        return view as! View
    }
    /*
    before: prevItem <- nextItem
    after: prevItem <- item <- nextItem
    */
    private func _reconnect(from nextItem: BoxHItem?, to prevItem: BoxHItem?, through item: BoxHItem) {
        let inset = contentInsets
        let view = item.view
        if let nextItem = nextItem {
            nextItem.leading?.deactivate()
            let nextView = nextItem.view
            nextView.snp.makeConstraints { make in
                nextItem.leading = make.leading.equalTo(view.snp.trailing).offset(nextItem.margin).constraint
            }
            view.snp.makeConstraints { make in
                if let prevView = prevItem?.view {
                    item.leading = make.leading.equalTo(prevView.snp.trailing).offset(item.margin).constraint
                } else {
                    item.leading = make.leading.equalTo(inset.left).constraint
                }
            }
        } else {
            let prevView = prevItem?.view
            rightConstraint?.deactivate()
            
            view.snp.makeConstraints { make in
                if let prevView = prevView {
                    item.leading = make.leading.equalTo(prevView.snp.trailing).offset(item.margin).constraint
                } else {
                    item.leading = make.leading.equalTo(inset.left).constraint
                }
                rightConstraint = make.trailing.equalTo(-inset.right).constraint
            }
        }
    }
    /*
    before: prevItem <- item <- nextItem
    after: prevItem <- nextItem
    */
    private func _reconnect(from nextItem: BoxHItem?, to prevItem: BoxHItem?, skipOver item: BoxHItem) {
        let inset = contentInsets
        if let nextItem = nextItem {
            nextItem.leading?.deactivate()
            nextItem.view.snp.makeConstraints { make in
                if let prevView = prevItem?.view {
                    nextItem.leading = make.leading.equalTo(prevView.snp.trailing).offset(nextItem.margin).constraint
                } else {
                    nextItem.leading = make.leading.equalTo(inset.left).constraint
                }
            }
        } else {
            rightConstraint?.deactivate()
            if let prevView = prevItem?.view {
                prevView.snp.makeConstraints { make in
                    rightConstraint = make.trailing.equalTo(-inset.right).constraint
                }
            } else {
                rightConstraint = nil
            }
        }
    }
    
    private func _firstNoHiddenItem(from index: Int) -> BoxHItem? {
        return items[index...].first { !$0.view.isHidden }
    }
    private func _lastNoHiddenItem(from index: Int) -> BoxHItem? {
        return items[...index].last { !$0.view.isHidden }
    }
    
    private final class BoxHItem {
        var margin: CGFloat = .zero
        var leading: Constraint?
        var top: Constraint?
        var centerY: Constraint?
        var bottom: Constraint?
        
        unowned let view: UIView
        init(view: UIView) {
            self.view = view
        }
        func installCons() {
            leading?.activate()
            installVCons()
        }
        func installVCons() {
            top?.activate()
            centerY?.activate()
            bottom?.activate()
        }
        func uninstall() {
            leading?.deactivate()
            top?.deactivate()
            centerY?.deactivate()
            bottom?.deactivate()
        }
        func makeVCons(alignment: LayoutView.Alignment, inset: UIEdgeInsets) {
            view.snp.makeConstraints { make in
                switch(alignment) {
                    
                case .start:
                    top = make.top.equalTo(inset.top).constraint
                    bottom = make.bottom.lessThanOrEqualTo(-inset.bottom).constraint
                case .center:
                    top = make.top.greaterThanOrEqualTo(inset.top).constraint
                    bottom = make.bottom.lessThanOrEqualTo(-inset.bottom).constraint
                    centerY = make.centerY.equalTo(view.superview!).constraint
                case .end:
                    top = make.top.greaterThanOrEqualTo(inset.top).constraint
                    bottom = make.bottom.equalTo(-inset.bottom).constraint
                }
            }
        }
    }
}


final public class BoxVView: BoxView {
    private var items: [BoxVItem] = []
    private var bottomConstraint: Constraint?
    
    public override var arrangedViews: [UIView] {
        return items.map { $0.view }
    }
    public override var arrangedViewsCount: Int {
        return items.count
    }
    public override func indexOfArrangedView<View>(_ view: View) -> Int? where View : UIView {
        items.firstIndex { $0.view === view }
    }
    
    public override func insertArrangedView(_ view: UIView,
                                            at index: Int,
                                            spacing: CGFloat? = nil,
                                            alignment: LayoutView.Alignment? = nil) {
        let count = items.count
        precondition(index <= count)
        insertSubview(view, at: index)
        
        let inset = contentInsets
        let align = alignment ?? self.alignment
        let space = spacing ?? self.spacing
        
        let item = BoxVItem(view: view)
        item.makeHCons(alignment: align, inset: inset)
        item.margin = index == 0 ? 0 : space
        
        if view.isHidden {
            let prevView: UIView? = index == 0 ? nil : items[index - 1].view
            view.snp.makeConstraints { make in
                if let prevView = prevView {
                    item.top = make.top.equalTo(prevView.snp.bottom).offset(space).constraint
                } else {
                    item.top = make.leading.equalTo(inset.top).constraint
                }
            }
            item.uninstall()
        } else {
            let next = _firstNoHiddenItem(from: index)
            if next?.margin == 0 { next?.margin = space }
            
            let prev = _lastNoHiddenItem(from: index - 1)
            _reconnect(from: next, to: prev, through: item)
        }
        items.insert(item, at: index)
    }
    
    public override func removeArrangedView<View>(at index: Int) -> View? where View : UIView {
        let count = items.count
        precondition(index < count)
        
        let item = items[index]
        item.uninstall()
        
        let view = item.view
        view.removeFromSuperview()
        items.remove(at: index)

        let next = _firstNoHiddenItem(from: index)
        
        let prev = _lastNoHiddenItem(from: index - 1)
        _reconnect(from: next, to: prev, skipOver: item)
        
        return view as? View
    }
    
    public override func hiddenArrangedView<View>(at index: Int) -> View where View : UIView {
        let count = items.count
        precondition(index < count)
        
        let item = items[index]
        
        let view = item.view
        if view.isHidden { return view as! View }
        
        view.isHidden = true
        item.uninstall()
        
        let next = _firstNoHiddenItem(from: index + 1)
        let prev = _lastNoHiddenItem(from: index - 1)
        _reconnect(from: next, to: prev, skipOver: item)
        
        return view as! View
    }
    
    public override func showArrangedView<View>(at index: Int) -> View where View : UIView {
        let count = items.count
        precondition(index < count)
        
        let item = items[index]
        
        let view = item.view
        if !view.isHidden { return view as! View }
        
        view.isHidden = false
        item.installHCons()
        
        let next = _firstNoHiddenItem(from: index + 1)
        let prev = _lastNoHiddenItem(from: index - 1)
        _reconnect(from: next, to: prev, through: item)
        
        return view as! View
    }
    /*
    before: prevItem <- nextItem
    after: prevItem <- item <- nextItem
    */
    private func _reconnect(from nextItem: BoxVItem?, to prevItem: BoxVItem?, through item: BoxVItem) {
        let inset = contentInsets
        let view = item.view
        if let nextItem = nextItem {
            nextItem.top?.deactivate()
            let nextView = nextItem.view
            nextView.snp.makeConstraints { make in
                nextItem.top = make.top.equalTo(view.snp.bottom).offset(nextItem.margin).constraint
            }
            view.snp.makeConstraints { make in
                if let prevView = prevItem?.view {
                    item.top = make.top.equalTo(prevView.snp.bottom).offset(item.margin).constraint
                } else {
                    item.top = make.leading.equalTo(inset.top).constraint
                }
            }
        } else {
            let prevView = prevItem?.view
            bottomConstraint?.deactivate()
            
            view.snp.makeConstraints { make in
                if let prevView = prevView {
                    item.top = make.top.equalTo(prevView.snp.bottom).offset(item.margin).constraint
                } else {
                    item.top = make.top.equalTo(inset.top).constraint
                }
                bottomConstraint = make.bottom.equalTo(-inset.bottom).constraint
            }
        }
    }
    /*
    before: prevItem <- item <- nextItem
    after: prevItem <- nextItem
    */
    private func _reconnect(from nextItem: BoxVItem?, to prevItem: BoxVItem?, skipOver item: BoxVItem) {
        let inset = contentInsets
        if let nextItem = nextItem {
            nextItem.top?.deactivate()
            nextItem.view.snp.makeConstraints { make in
                if let prevView = prevItem?.view {
                    nextItem.top = make.top.equalTo(prevView.snp.bottom).offset(nextItem.margin).constraint
                } else {
                    nextItem.top = make.top.equalTo(inset.top).constraint
                }
            }
        } else {
            bottomConstraint?.deactivate()
            if let prevView = prevItem?.view {
                prevView.snp.makeConstraints { make in
                    bottomConstraint = make.bottom.equalTo(-inset.bottom).constraint
                }
            } else {
                bottomConstraint = nil
            }
        }
    }
    
    private func _firstNoHiddenItem(from index: Int) -> BoxVItem? {
        return items[index...].first { !$0.view.isHidden }
    }
    private func _lastNoHiddenItem(from index: Int) -> BoxVItem? {
        return items[...index].last { !$0.view.isHidden }
    }
    
    private final class BoxVItem {
        var margin: CGFloat = .zero
        var top: Constraint?
        var leading: Constraint?
        var centerX: Constraint?
        var trailing: Constraint?
        
        unowned let view: UIView
        init(view: UIView) {
            self.view = view
        }
        func installCons() {
            top?.activate()
            installHCons()
        }
        func installHCons() {
            leading?.activate()
            centerX?.activate()
            trailing?.activate()
        }
        func uninstall() {
            top?.deactivate()
            leading?.deactivate()
            centerX?.deactivate()
            trailing?.deactivate()
        }
        func makeHCons(alignment: LayoutView.Alignment, inset: UIEdgeInsets) {
            view.snp.makeConstraints { make in
                
                switch(alignment) {
                
                case .start:
                    leading = make.leading.equalTo(inset.left).constraint
                    trailing = make.trailing.lessThanOrEqualTo(-inset.right).constraint
                case .center:
                    leading = make.leading.greaterThanOrEqualTo(inset.left).constraint
                    trailing = make.trailing.lessThanOrEqualTo(-inset.right).constraint
                    centerX = make.centerX.equalTo(view.superview!).constraint
                case .end:
                    leading = make.leading.greaterThanOrEqualTo(inset.left).constraint
                    trailing = make.trailing.equalTo(-inset.right).constraint
                }
            }
        }
    }
}
