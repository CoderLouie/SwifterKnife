//
//  AspectImageView.swift
//  SwifterKnife
//
//  Created by 李阳 on 2022/8/23.
//

import UIKit

/*
/*
 适用场景：
 适用于使用图片作为背景，在背景图的标注位置上创建其他视图
 */
public class AspectImageView: UIImageView {
    private lazy var aspectSize: CGSize = .zero
    
    public private(set) var ratio: CGFloat = 1
    
    private func _min(_ x: CGFloat, _ y: CGFloat) -> (CGFloat, Bool) {
        if x < y { return (x, true) }
        return (y, false)
    }
    private func _max(_ x: CGFloat, _ y: CGFloat) -> (CGFloat, Bool) {
        if x > y { return (x, true) }
        return (y, false)
    }
    
    public enum LimitDirection {
        case horizontal
        case vertical
    }
    /// 返回值表示受限制的方向
    @discardableResult
    public func aspectFit(_ image: UIImage, boundingSize: CGSize) -> LimitDirection {
        contentMode = .scaleAspectFit
        self.image = image
        let imgS = image.size
        let info = _min(boundingSize.width / imgS.width, boundingSize.height / imgS.height)
        let minRatio = info.0
        ratio = minRatio
        aspectSize = CGSize(width: imgS.width * minRatio, height: imgS.height * minRatio)
        invalidateIntrinsicContentSize()
        return info.1 ? .horizontal : .vertical
    }
    @discardableResult
    public func aspectFill(_ image: UIImage, boundingSize: CGSize) -> LimitDirection {
        contentMode = .scaleAspectFill
        self.image = image
        let imgS = image.size
        let info = _max(boundingSize.width / imgS.width, boundingSize.height / imgS.height)
        let minRatio = info.0
        ratio = minRatio
        
        let aWidth = min(imgS.width * minRatio, boundingSize.width)
        let aHeight = min(imgS.height * minRatio, boundingSize.height)
        aspectSize = CGSize(width: aWidth, height: aHeight)
        invalidateIntrinsicContentSize()
        return info.1 ? .vertical : .horizontal
    }
    public override var intrinsicContentSize: CGSize {
        if aspectSize.width > 0,
           aspectSize.height > 0 {
            return aspectSize
        }
        return super.intrinsicContentSize
    }
}
*/
open class BaseImageView: UIImageView {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    public convenience init() {
        self.init(frame: .zero)
    }
    open func setup() {
        contentMode = .scaleAspectFit
    }
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    open override var image: UIImage? {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    private var firstLayout = true
    open override func layoutSubviews() {
        super.layoutSubviews()
        if firstLayout, !bounds.isEmpty {
            invalidateIntrinsicContentSize()
            firstLayout = false
        }
    }
}
open class HImageView: BaseImageView {
    open var maxHeight: CGFloat = -1
    open override func setup() {
        super.setup()
        // 水平方向可以拉伸
        setContentHuggingPriority(UILayoutPriority(rawValue: 249), for: .horizontal)
        // 垂直方向尽量不要拉伸
        setContentHuggingPriority(UILayoutPriority(rawValue: 251), for: .vertical)
        
        // 水平方向可以压缩
        setContentCompressionResistancePriority(UILayoutPriority(rawValue: 749), for: .horizontal)
        // 垂直方向尽量不要压缩
        setContentCompressionResistancePriority(UILayoutPriority(rawValue: 751), for: .vertical)
    }
    open override var intrinsicContentSize: CGSize {
        let bounds = bounds
        guard !bounds.isEmpty,
            let imgS = image?.size,
            !imgS.isEmpty else {
            return super.intrinsicContentSize
        }
        var size = bounds.size
        var aspectH = (size.width * imgS.height / imgS.width)
        if maxHeight > 0 {
            aspectH = min(aspectH, maxHeight)
        }
        size.height = aspectH.pix
        return size
    }
    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        intrinsicContentSize
    }
}
open class VImageView: BaseImageView {
    open var maxWidth: CGFloat = -1
    open override func setup() {
        super.setup()
        // 垂直方向可以拉伸
        setContentHuggingPriority(UILayoutPriority(rawValue: 249), for: .vertical)
        // 水平方向尽量不要拉伸
        setContentHuggingPriority(UILayoutPriority(rawValue: 251), for: .horizontal)
        
        // 垂直方向可以压缩
        setContentCompressionResistancePriority(UILayoutPriority(rawValue: 749), for: .vertical)
        // 水平方向尽量不要压缩
        setContentCompressionResistancePriority(UILayoutPriority(rawValue: 751), for: .horizontal)
    }
    
    open override var intrinsicContentSize: CGSize {
        let bounds = bounds
        guard !bounds.isEmpty,
            let imgS = image?.size,
            !imgS.isEmpty else {
            return super.intrinsicContentSize
        }
        var size = bounds.size
        var aspectW = (size.height * imgS.width / imgS.height)
        if maxWidth > 0 {
            aspectW = min(aspectW, maxWidth)
        }
        size.width = aspectW.pix
        return size
    }
    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        intrinsicContentSize
    }
}
