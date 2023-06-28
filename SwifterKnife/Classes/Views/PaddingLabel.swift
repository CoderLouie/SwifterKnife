//
//  PaddingLabel.swift
//  SwifterKnife
//
//  Created by liyang on 2021/10/19.
//

import UIKit

open class PaddingLabel: UILabel {
    open var textInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10) {
        didSet {
            guard textInsets != oldValue else { return }
            setNeedsDisplay()
        }
    }
    open var textPosition: Position = .leftCenter {
        didSet {
            guard textPosition != oldValue else { return }
            setNeedsDisplay()
        }
    }
    
    open override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        let bounds = bounds.inset(by: textInsets)
        var rect = super.textRect(forBounds: bounds, limitedToNumberOfLines: numberOfLines)
        rect.origin = CGPoint(x: (bounds.width - rect.width) * textPosition.x + bounds.minX, y: (bounds.height - rect.height) * textPosition.y + bounds.minY)
        return rect
    }
    
    open override func drawText(in rect: CGRect) {
        super.drawText(in: textRect(forBounds: rect, limitedToNumberOfLines: numberOfLines))
    }

    open override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        let inset = textInsets
        return CGSize(width: size.width + inset.left + inset.right, height: size.height + inset.top + inset.bottom)
    }
} 
