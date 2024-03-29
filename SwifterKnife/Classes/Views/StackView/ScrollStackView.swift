//
//  ScrollStackView.swift
//  SwifterKnife
//
//  Created by liyang on 2023/2/17.
//

import UIKit
import SnapKit

/*
-   axis(轴向) 属性决定了 stack 的朝向，只有垂直或水平
-   distribution(分布) 属性决定了其管理的视图在沿着其轴向上的布局
-   alignment(对齐) 属性决定了其管理的视图在垂直于其轴向上的布局；
-   spacing(空隙) 属性决定了其管理的视图间的最小间隙；
 
 其中distribution(分布)：
     Fill : 铺满
     Fill Equal ： 等宽铺满
     Fill Proportionally : 等比例铺满
     Equal Spacing ：等距离放置
     Equal Centering ：各个试图的中心距离保持一致，不够放置则压缩后面的试图距离；
 
 
 其中 alignment(对齐)：
     Fill : 垂直方向上铺满
     Top : 沿顶端对齐
     Center : 沿中心线对其
     Bottom : 沿底部对齐
     First Baseline : 按照第一个子视图的文字的第一行对齐，同时保证高度最大的子视图底部对齐（只在axis为水平方向有效）
     Last Baseline : 按照最后一个子视图的文字的最后一行对齐，同时保证高度最大的子视图顶部对齐（只在axis为水平方向有效）
 
 */
public final class ScrollStackView: UIScrollView {
    
    public init(normalized: Bool, frame: CGRect = .zero, arrangedSubviews: [UIView] = []) {
        super.init(frame: frame)
        
        keyboardDismissMode = .onDrag
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        contentInsetAdjustmentBehavior = .never
        backgroundColor = .clear
        
        container = normalized ? NormalStackView(arrangedSubviews: arrangedSubviews) : UIStackView(arrangedSubviews: arrangedSubviews)
        container.axis = .vertical
        addSubview(container)
        
        alwaysBounceVertical = true
        alwaysBounceHorizontal = false
        insetsLayoutMarginsFromSafeArea = false
        
        super.layoutMargins = .zero
        container.snp.remakeConstraints { make in
//            make.edges.equalToSuperview()
            make.edges.equalTo(self.snp.margins)
            stackWidthCons = make.width.equalToSuperview().constraint
            stackHeightCons = make.height.equalToSuperview().constraint
        }
        stackHeightCons.deactivate()
    }
    
    public convenience override init(frame: CGRect) {
        self.init(normalized: false, frame: frame)
    }
    public convenience init() {
        self.init(normalized: false, frame: .zero)
    }
    public static var normalized: ScrollStackView {
        .init(normalized: true, frame: .zero)
    }
    
    public var isVertical: Bool {
        container.axis == .vertical
    }
    
    public var axis: NSLayoutConstraint.Axis {
        get { container.axis }
        set {
            guard container.axis != newValue else { return }
            let isVertical = newValue == .vertical
            alwaysBounceVertical = isVertical
            alwaysBounceHorizontal = !isVertical
            if isVertical {
                stackHeightCons.deactivate()
                stackWidthCons.activate()
            } else {
                stackHeightCons.activate()
                stackWidthCons.deactivate()
            }
            container.axis = newValue
        }
    }
    public func axis(_ axis: NSLayoutConstraint.Axis) -> Self {
        self.axis = axis
        return self
    }
    
    public override var layoutMargins: UIEdgeInsets {
        didSet {
            guard layoutMargins != oldValue else {
                return
            }
            let inset = layoutMargins
            stackWidthCons.update(offset: -(inset.left + inset.right))
            stackHeightCons.update(offset: -(inset.top + inset.bottom))
        }
    }
    public override var contentInset: UIEdgeInsets {
        didSet {
            guard contentInset != oldValue else {
                return
            }
            let inset = contentInset
            stackWidthCons.update(offset: -(inset.left + inset.right))
            stackHeightCons.update(offset: -(inset.top + inset.bottom))
        }
    }
    public func contentInset(_ inset: UIEdgeInsets) -> Self {
        self.contentInset = inset
        return self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public static var vertical: ScrollStackView {
        .init(normalized: false, frame: .zero, arrangedSubviews: [])
    }
    public static var horizontal: ScrollStackView {
        .init(normalized: false, frame: .zero, arrangedSubviews: []).axis(.horizontal)
    }
    
    public private(set) var container: UIStackView!
    private var stackHeightCons: Constraint!
    private var stackWidthCons: Constraint!
}



public func hScrollStack(normalized: Bool = false,
                   @ViewsBuilder views: () -> [UIView]) -> ScrollStackView {
    .init(normalized: normalized, frame: .zero, arrangedSubviews: views()).axis(.horizontal)
}
public func vScrollStack(normalized: Bool = false,
                   @ViewsBuilder views: () -> [UIView]) -> ScrollStackView {
    .init(normalized: normalized, frame: .zero, arrangedSubviews: views())
}
