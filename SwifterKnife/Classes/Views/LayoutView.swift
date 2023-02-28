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
        return UIStackView.layerClass
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

open class SpaceView: UIView {
    public convenience init(width: CGFloat) {
        self.init(frame: .zero)
        intrinsicSize.width = width
    }
    public convenience init(height: CGFloat) {
        self.init(frame: .zero)
        intrinsicSize.height = height
    }
    
    open var intrinsicSize = CGSize(width: UIView.noIntrinsicMetric, height: UIView.noIntrinsicMetric) {
        didSet {
            guard intrinsicSize != oldValue else { return }
            invalidateIntrinsicContentSize()
        }
    }
    
    open override var intrinsicContentSize: CGSize {
        return intrinsicSize
    }
}


public final class SudokuView: VirtualView {
    public var columnCount = 3
    public var rowCount: Int? = nil
    public var marginX: CGFloat = 8
    public var marginY: CGFloat = 8
    
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
                let subVH = subview.frame.height
                let h = subVH > 0 ? subVH : subview.systemLayoutSizeFitting(
                    CGSize(width: w, height: 0),
                    withHorizontalFittingPriority: .required,
                    verticalFittingPriority: .fittingSizeLevel).height.pixCeil
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
