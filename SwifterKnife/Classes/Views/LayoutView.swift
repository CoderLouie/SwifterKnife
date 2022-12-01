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
    
    open override func didMoveToSuperview() {
        if let _ = superview {
            self.snp.makeConstraints { make in
                make.width.height.equalTo(1).priority(100)
            }
        }
    }
}

open class QueueView: LayoutView { }

/// 垂直方向会自动根据对齐方式布局
final public class QueueVView: QueueView {
    var vAutoSize: Bool = true
    
    public func makeHorizontalSizeToFit() {
        let inset = contentInsets
        if let view = arrangedViews.first {
            view.snp.makeConstraints { make in
                make.leading.equalTo(inset.left)
            }
        }
        if let view = arrangedViews.last {
            view.snp.makeConstraints { make in
                make.trailing.equalTo(-inset.right)
            }
        }
    }
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
        guard vAutoSize else { return }
        view.snp.makeConstraints { make in
            switch align {
            case .start:
                make.bottom.lessThanOrEqualTo(-inset.bottom)
            case .center:
                make.top.greaterThanOrEqualTo(inset.top)
                make.bottom.lessThanOrEqualTo(-inset.bottom)
            case .end:
                make.top.greaterThanOrEqualTo(inset.top)
            }
        }
    }
}

/// 水平方向会自动根据对齐方式布局
final public class QueueHView: QueueView {
    var hAutoSize: Bool = true
    public func makeVerticalSizeToFit() {
        let inset = contentInsets
        if let view = arrangedViews.first {
            view.snp.makeConstraints { make in
                make.top.equalTo(inset.top)
            }
        }
        if let view = arrangedViews.last {
            view.snp.makeConstraints { make in
                make.bottom.equalTo(-inset.bottom)
            }
        }
    }
    
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
        guard hAutoSize else { return }
        view.snp.makeConstraints { make in
            switch align {
            case .start:
                make.trailing.lessThanOrEqualTo(-inset.right)
            case .center:
                make.leading.greaterThanOrEqualTo(inset.left)
                make.trailing.lessThanOrEqualTo(-inset.right)
            case .end:
                make.leading.greaterThanOrEqualTo(inset.left)
            }
        }
    }
}


open class SequenceView: LayoutView {
    public enum FixedBehaviour {
        case itemLength(_ length: CGFloat)
        case spacing(_ spacing: CGFloat)
    }
    public var behaviour: FixedBehaviour = .spacing(10.fit)
    
    fileprivate final class SequenceItem {
        let alignment: LayoutView.Alignment
        unowned let view: UIView
        init(view: UIView, alignment: LayoutView.Alignment) {
            self.view = view
            self.alignment = alignment
        }
    }
    
    fileprivate var items: [SequenceItem] = []
    public override var arrangedViews: [UIView] { items.map(\.view) }
    
    public func addArrangedViews(_ views: [UIView]) {
        items.append(contentsOf: views.map {
            addSubview($0)
            return SequenceItem(view: $0, alignment: alignment)
        })
    }
    public func addArrangedViews(_ views: UIView...) {
        addArrangedViews(views)
    }
    
    public func removeArrangedView(_ view: UIView) {
        items.removeAll {
            let flag = $0.view === view
            if flag { $0.view.removeFromSuperview() }
            return flag
        }
    }
    public func removeArrangedViewAt(_ index: Int) {
        let item = items[index]
        item.view.removeFromSuperview()
        items.remove(at: index)
    }
    
    public func replaceArrangedViews() {
        items.forEach { $0.view.snp.removeConstraints() }
        placeArrangedViews()
    }
    
    public override func insertArrangedView(_ view: UIView, at index: Int, alignment: LayoutView.Alignment? = nil) {
        insertSubview(view, at: index)
        let align = alignment ?? self.alignment
        items.insert(.init(view: view, alignment: align), at: index)
    }
    open func placeArrangedViews() {}
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
            for (i, v) in views.enumerated() {
                
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
 

 

 
