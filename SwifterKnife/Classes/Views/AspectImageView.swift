//
//  AspectImageView.swift
//  SwifterKnife
//
//  Created by 李阳 on 2022/8/23.
//

import UIKit

/*
 适用场景：
 适用于使用图片作为背景，在背景图的标注位置上创建其他视图
 */
public class AspectImageView: UIImageView {
    private lazy var aspectSize = image?.size ?? CGSize(width: UIView.noIntrinsicMetric, height: UIView.noIntrinsicMetric)
    
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
        return aspectSize
    }
}
