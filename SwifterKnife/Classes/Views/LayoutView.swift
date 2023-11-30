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
 2. 已知该视图宽度和高度，列个数，水平间距，垂直间距，行个数，
    可确定每个cell的大小
 
 */
public final class SudokuView: UIView {
    public var columnWidthRatios: [CGFloat] = [1, 1, 1]
    public var marginX: CGFloat = 8
    public var marginY: CGFloat = 8
    public var contentEdgeInset: UIEdgeInsets = .zero
    
    public enum Alignment {
        public enum Inline {
            case top, center, bottom
        }
        case inline(Inline)
        case fixedMargin
        case waterflow
    }
    public enum LayoutBehavior {
        case autoSelfHeight(_ cellAlignment: Alignment = .inline(.center),
                            _ cellHeightWay: ((_ view: UIView, _ index: Int, _ width: CGFloat) -> CGFloat)? = nil)
        case autoCellSize(_ rowHeightRatios: [CGFloat]? = nil)
    }
    public var layoutBehavior: LayoutBehavior = .autoSelfHeight()
    
    private var insHeight = UIView.noIntrinsicMetric
    
    public override var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize
        if case .autoSelfHeight = layoutBehavior {
            size.height = insHeight
        }
        return size
    }
    
    
    private func systemHeight(of view: UIView, limitW w: CGFloat) -> CGFloat {
        let height = view.intrinsicContentSize.height
        return height > 0 ? height : view.systemLayoutSizeFitting(
            CGSize(width: w, height: 0),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel).height.pixCeil
    }
    public override func layoutSubviews() {
        super.layoutSubviews()
        guard !columnWidthRatios.isEmpty,
                !subviews.isEmpty else { return }
        
        let bounds = bounds
        let width = bounds.width
        let height = bounds.height
        guard width > 0 else { return }
        let inset = contentEdgeInset
        
        let sumW = columnWidthRatios.reduce(0, +)
        let columnCount = columnWidthRatios.count
        let totoalW = (width - inset.left - inset.right - CGFloat(columnCount - 1) * marginX)
        let itemWs = columnWidthRatios.map { (totoalW * ($0 / sumW)).pixFloor }
        var x: CGFloat = inset.left, y: CGFloat = inset.top
        
        switch layoutBehavior {
        case .autoCellSize(let ratios):
            guard height > 0 else { return }
            let rowHeightRatios: [CGFloat]
            if let r = ratios, !r.isEmpty {
                rowHeightRatios = r
            } else {
                rowHeightRatios = .init(repeating: 1, count: Int((subviews.count + columnCount - 1) / columnCount))
            }
            let sumH = rowHeightRatios.reduce(0, +)
            let rowCount = rowHeightRatios.count
            let totoalH = (height - inset.top - inset.bottom - CGFloat(rowCount - 1) * marginY)
            let itemHs = rowHeightRatios.map { (totoalH * ($0 / sumH)).pixCeil }
            for (i, subview) in subviews.enumerated() {
                let left = i % columnCount
                let w = itemWs[left]
                let h = itemHs[Int(i / columnCount)]
                subview.frame = CGRect(x: x, y: y, width: w, height: h)
                x += w + marginX
                if left == columnCount - 1 {
                    x = inset.left; y += h + marginY
                }
            }
        case let .autoSelfHeight(cellAlignment, cellHeight):
            switch cellAlignment {
            case .fixedMargin:
                var columnHeights: [CGFloat] = .init(repeating: inset.top, count: columnCount)
                for (i, subview) in subviews.enumerated() {
                    let left = i % columnCount
                    let w = itemWs[left]
                    let h = cellHeight?(subview, i, w) ?? systemHeight(of: subview, limitW: w)
                    y = columnHeights[left]
                    subview.frame = CGRect(x: x, y: y, width: w, height: h)
                    x += w + marginX
                    y += h + marginY
                    columnHeights[left] = y
                    if left == columnCount - 1 {
                        x = inset.left
                    }
                }
                insHeight = (columnHeights.max() ?? y) - marginY
            case .waterflow:
                var columnHeights: [CGFloat] = .init(repeating: inset.top, count: columnCount)
                var columnLefts: [CGFloat] = []
                do {
                    var x = inset.left
                    for i in (0..<columnCount) {
                        columnLefts.append(x)
                        x += itemWs[i] + marginX
                    }
                }
                for (i, subview) in subviews.enumerated() {
                    guard let (idx, height) = columnHeights.enumerated().min(by: { $0.element < $1.element
                    }) else { return }
                    let w = itemWs[idx]
                    let h = cellHeight?(subview, i, w) ?? systemHeight(of: subview, limitW: w)
                    y = height
                    x = columnLefts[idx]
                    
                    subview.frame = CGRect(x: x, y: y, width: w, height: h)
                    columnHeights[idx] += h + marginY
                    insHeight = max(columnHeights[idx], insHeight)
                }
                insHeight -= marginY
            case .inline(let inline):
                var rowViews: [UIView] = []
                var rowMaxH: CGFloat = 0
                var rowHeights: [CGFloat] = []
                let subviewsCount = subviews.count
                for (i, subview) in subviews.enumerated() {
                    rowViews.append(subview)
                    let left = i % columnCount
                    let w = itemWs[left]
                    let h = cellHeight?(subview, i, w) ?? systemHeight(of: subview, limitW: w)
                    rowMaxH = max(rowMaxH, h)
                    rowHeights.append(h)
                    if left == columnCount - 1 ||
                        i == subviewsCount - 1 {// 最后一列
                        for (j, cell) in rowViews.enumerated() {
                            let h = rowHeights[j]
                            let space: CGFloat
                            switch inline {
                            case .top: space = 0
                            case .center: space = (rowMaxH - h) * 0.5
                            case .bottom: space = rowMaxH - h
                            }
                            cell.frame = CGRect(x: x, y: y + space, width: itemWs[j], height: h)
                            x += itemWs[j] + marginX
                        }
                        x = inset.left
                        y += rowMaxH + marginY
                        rowHeights.removeAll()
                        rowViews.removeAll()
                        rowMaxH = 0
                    }
                }
                insHeight = y - marginY
            }
            insHeight += inset.bottom
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
