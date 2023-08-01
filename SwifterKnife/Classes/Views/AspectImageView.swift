//
//  AspectImageView.swift
//  SwifterKnife
//
//  Created by liyang on 2022/8/23.
//

import UIKit

fileprivate extension CGRect {
    var pixelate: CGRect {
        CGRect(x: origin.x.pixFloor, y: origin.y.pixFloor, width: size.width.pixCeil, height: size.height.pixCeil)
    }
}

open class AspectFitView: UIView {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open var contentInset: UIEdgeInsets = .zero {
        didSet {
            guard oldValue != contentInset else { return }
            setNeedsLayout()
        }
    }
    public var image: UIImage? {
        get { imgView.image }
        set {
            imgView.image = newValue
            setNeedsLayout()
        }
    }
    open func setup() {
        imgView = UIImageView().then {
            $0.contentMode = .scaleAspectFit
            addSubview($0)
        }
    }
    open var imageContentModel: UIView.ContentMode = .top
    open override func layoutSubviews() {
        super.layoutSubviews()
        let bounds = bounds
        let inset = contentInset
        let rect = bounds.inset(by: inset)
        guard let ratio = imgView.image?.size.whRatio else { return }
        let size: CGSize
        if ratio < 1 {
            size = CGSize(width: rect.height * ratio, height: rect.height)
        } else {
            size = CGSize(width: rect.width, height: rect.width / ratio)
        }
        imgView.contentMode = .scaleAspectFit
        var frame = rect.resizing(to: size, model: .scaleAspectFit).pixelate
        switch imageContentModel {
        case .top:
            frame.origin.y = inset.top
        case .left:
            frame.origin.x = inset.left
        case .right:
            frame.origin.x = rect.maxX - frame.size.width
        case .bottom:
            frame.origin.y = rect.maxY - frame.size.height
        default: break
        }
        imgView.frame = frame
    }
    private(set) public unowned var imgView: UIImageView!
}


open class FitVImageView: UIImageView {
    open override var image: UIImage? {
        didSet {
            if bounds.width > 0 {
                invalidateIntrinsicContentSize()
            }
        }
    }
    public var ratioMap: ((CGFloat, CGFloat, UIImage) -> CGFloat)?
    open override var intrinsicContentSize: CGSize {
        guard let img = image else {
            return super.intrinsicContentSize
        }
        let imgSize = img.size
        if imgSize.width == 0 {
            return super.intrinsicContentSize
        }
        let size = bounds.size
        if size.width == 0 {
            return super.intrinsicContentSize
        }
        let w = size.width
        let imgRatio = imgSize.width / imgSize.height
        let ratio = ratioMap?(imgRatio, w, img) ?? imgRatio
        let h = w / ratio
        return CGSize(width: w, height: h.pixCeil)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        guard let img = image else { return }
        let size = bounds.size
        let imgS = img.size
        if Int(imgS.width) == Int(size.width) {
            return // 没有设置宽约束
        }
        if size.width > 0,
            Int(imgS.height) == Int(size.height) {
            invalidateIntrinsicContentSize()
        }
    }
}
open class FitHImageView: UIImageView {
    open override var image: UIImage? {
        didSet {
            if bounds.height > 0 {
                invalidateIntrinsicContentSize()
            }
        }
    }
    public var ratioMap: ((CGFloat, CGFloat, UIImage) -> CGFloat)?
    open override var intrinsicContentSize: CGSize {
        guard let img = image else {
            return super.intrinsicContentSize
        }
        let imgSize = img.size
        if imgSize.height == 0 {
            return super.intrinsicContentSize
        }
        let size = bounds.size
        if size.height == 0 {
            return super.intrinsicContentSize
        }
        let h = size.height
        let imgRatio = imgSize.width / imgSize.height
        let ratio = ratioMap?(imgRatio, h, img) ?? imgRatio
        let w = h * ratio
        return CGSize(width: w.pixCeil, height: h)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        guard let img = image else { return }
        let size = bounds.size
        let imgS = img.size
        if Int(imgS.height) == Int(size.height) {
            return // 没有设置高度约束
        }
        if size.height > 0,
           Int(imgS.width) == Int(size.width) {// 第一次进入此方法
            invalidateIntrinsicContentSize()
        }
    }
}
/*
open class FitImageView: UIImageView {
    public enum FitDirection {
        case horizontal, vertical
    }
    public var fitDirection: FitDirection = .vertical
    open override var intrinsicContentSize: CGSize {
        let bounds = bounds
        guard let img = image, !bounds.isEmpty else {
            return super.intrinsicContentSize
        }
        let imgSize = img.size
        if imgSize.width == 0 || imgSize.height == 0 {
            return super.intrinsicContentSize
        }
        switch fitDirection {
        case .horizontal:
            let h = bounds.height
            let w = imgSize.width * h / imgSize.height
            return CGSize(width: w.pixCeil, height: h)
        case .vertical:
            let w = bounds.width
            let h = imgSize.height * w / imgSize.width
            return CGSize(width: w, height: h.pixCeil)
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        let bounds = bounds
        guard let img = image, !bounds.isEmpty else {
            return
        }
        let imgS = img.size
        let size = bounds.size
        if Int(imgS.width) == Int(size.width),
           Int(imgS.height) == Int(size.height) {
            return // 没有设置宽/高约束
        }
        invalidateIntrinsicContentSize()
    }
}
*/
