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
    public override class var layerClass: AnyClass {
        return CATransformLayer.self
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    @available(*, unavailable)
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    open func setup() {}
}

/*
 1. 已知该视图宽度，列个数，水平间距，垂直间距，每个cell的固有高度
    求该是图高度
 2. 已知该视图宽度和高度，列个数，行个数，水平间距，垂直间距，
    可确定每个cell的大小
 
 */
public final class SudokuView: VirtualView {
    public var columnCount = 3
    public var rowCount: Int? = nil
    public var marginX: CGFloat = 8
    public var marginY: CGFloat = 8
    
    public var cellHeight: ((_ view: UIView, _ index: Int, _ width: CGFloat) -> CGFloat)?
    
    public enum Alignment {
        case top, center, bottom
    }
    public var cellAlignment: Alignment = .center
    
    private var insHeight = UIView.noIntrinsicMetric
    
    public override var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize
        if rowCount == nil {
            size.height = insHeight
        }
        return size
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        guard columnCount > 0, !subviews.isEmpty else { return }
        
        let bounds = bounds
        let width = bounds.width
        let height = bounds.height
        guard width > 0 else { return }
        
        let colN = CGFloat(columnCount)
        let w = ((width - (colN - 1) * marginX) / colN).pixFloor
        var x: CGFloat = 0, y: CGFloat = 0
        if let n = rowCount {
            let rowN = CGFloat(n)
            guard height > 0 else { return }
            let h = ((height - (rowN - 1) * marginY) / rowN).pixFloor
            for (i, subview) in subviews.enumerated() {
                if i != 0, i % columnCount == 0 {
                    x = 0; y += marginY + h
                }
                subview.frame = CGRect(x: x, y: y, width: w, height: h)
                x += w + marginX
            }
        } else {
            var rowViews: [UIView] = []
            var rowMaxH: CGFloat = 0
            var rowHeights: [CGFloat] = []
            for (i, subview) in subviews.enumerated() {
                if i != 0, i % columnCount == 0 {
                    for (j, cell) in rowViews.enumerated() {
                        let h = rowHeights[j]
                        let space: CGFloat
                        switch cellAlignment {
                        case .top: space = 0
                        case .center: space = (rowMaxH - h) * 0.5
                        case .bottom: space = rowMaxH - h
                        }
                        cell.frame = CGRect(x: x, y: y + space, width: w, height: h)
                        x += w + marginX
                    }
                    x = 0
                    y += rowMaxH + marginY
                    rowHeights.removeAll()
                    rowViews.removeAll()
                    rowMaxH = 0
                }
                rowViews.append(subview)
                let h: CGFloat
                if let closure = cellHeight {
                    h = closure(subview, i, w)
                } else {
                    let subVH = subview.frame.height
                    h = subVH > 0 ? subVH : subview.systemLayoutSizeFitting(
                        CGSize(width: w, height: 0),
                        withHorizontalFittingPriority: .required,
                        verticalFittingPriority: .fittingSizeLevel).height.pixCeil
                }
                rowMaxH = max(rowMaxH, h)
                rowHeights.append(h)
            }
            for (j, cell) in rowViews.enumerated() {
                let h = rowHeights[j]
                let space: CGFloat
                switch cellAlignment {
                case .top: space = 0
                case .center: space = (rowMaxH - h) * 0.5
                case .bottom: space = rowMaxH - h
                }
                cell.frame = CGRect(x: x, y: y + space, width: w, height: h)
                x += w + marginX
            }
            insHeight = y + rowMaxH
            invalidateIntrinsicContentSize()
        }
    }
}



public extension ConstraintMaker {
    func horizontalSpace(_ space: CGFloat) {
        leading.equalTo(space)
        trailing.equalTo(-space)
    }
    func verticalSpace(_ space: CGFloat) {
        top.equalTo(space)
        bottom.equalTo(-space)
    }
}
