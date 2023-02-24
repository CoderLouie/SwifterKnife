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
 
