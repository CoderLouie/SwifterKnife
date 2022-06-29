//
//  PaddingLabel.swift
//  SwifterKnife
//
//  Created by liyang on 2021/10/19.
//

import UIKit

public class PaddingLabel: UILabel {
    public enum TextPosition: CaseIterable {
        case leftTop, leftCenter, leftBottom
        case topCenter, center, bottomCenter
        case rightTop, rightCenter, rightBottom
    }
    public var textInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10) {
        didSet {
            guard textInsets != oldValue else { return }
            setNeedsDisplay()
        }
    }
    public var textPosition: TextPosition = .leftCenter {
        didSet {
            guard textPosition != oldValue else { return }
            setNeedsDisplay()
        }
    }
    
    public override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        let bounds = bounds.inset(by: textInsets)
        var rect = super.textRect(forBounds: bounds, limitedToNumberOfLines: numberOfLines)
        switch textPosition {
        case .leftTop:
            rect.origin = bounds.origin
        case .leftCenter:
            rect.origin = CGPoint(x: bounds.minX, y: (bounds.height - rect.height) * 0.5 + bounds.minY)
        case .leftBottom:
            rect.origin = CGPoint(x: bounds.minX, y: (bounds.maxY - rect.height))
        case .topCenter:
            rect.origin = CGPoint(x: (bounds.width - rect.width) * 0.5 + bounds.minX, y: bounds.minY)
        case .center:
            rect.origin = CGPoint(x: (bounds.width - rect.width) * 0.5 + bounds.minX, y: (bounds.height - rect.height) * 0.5 + bounds.minY)
        case .bottomCenter:
            rect.origin = CGPoint(x: (bounds.width - rect.width) * 0.5 + bounds.minX, y: bounds.maxY - rect.height)
        case .rightTop:
            rect.origin = CGPoint(x: (bounds.maxX - rect.width), y: bounds.minY)
        case .rightCenter:
            rect.origin = CGPoint(x: (bounds.maxX - rect.width), y: (bounds.height - rect.height) * 0.5 + bounds.minY)
        case .rightBottom:
            rect.origin = CGPoint(x: (bounds.maxX - rect.width), y: (bounds.maxY - rect.height))
        }
        return rect
    }
    
    public override func drawText(in rect: CGRect) {
        super.drawText(in: textRect(forBounds: rect, limitedToNumberOfLines: numberOfLines))
    }

    public override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        let inset = textInsets
        return CGSize(width: size.width + inset.left + inset.right, height: size.height + inset.top + inset.bottom)
    }
} 
