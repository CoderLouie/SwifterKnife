//
//  SeparatorView.swift
//  SwifterKnife
//
//  Created by liyang on 2023/3/8.
//

import UIKit

extension UIColor {
    public static var systemSeparatorLine: UIColor {
        UIColor(red: 0.24, green: 0.24, blue: 0.26, alpha: 0.29)
    }
}
open class SeparatorView: UIView {
    open var axis: NSLayoutConstraint.Axis = .horizontal {
        didSet {
            guard axis != oldValue else { return }
            invalidateIntrinsicContentSize()
        }
    }
    
    open var thickness = SeparatorView.amount {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
    open var color: UIColor? {
        get { backgroundColor }
        set { backgroundColor = newValue }
    }
    
    open override var intrinsicContentSize: CGSize {
        let amount = thickness
        if axis == .horizontal {
            return CGSize(width: -1, height: amount)
        } else {
            return CGSize(width: amount, height: -1)
        }
    }
    
    public static var amount: CGFloat {
        1 / UIScreen.main.scale
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func setup() {
        backgroundColor = .systemSeparatorLine
        
        // 容易被拉伸
        setContentHuggingPriority(.defaultLow, for: .horizontal)
        setContentHuggingPriority(.defaultLow, for: .vertical)
        
        // 容易被压缩
        setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        setContentCompressionResistancePriority(.defaultLow, for: .vertical)
    }
}
