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
            get { return nil }
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
 

 

 
