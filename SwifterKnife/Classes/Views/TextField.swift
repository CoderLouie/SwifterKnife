//
//  TextField.swift
//  SwifterKnife
//
//  Created by 李阳 on 2022/6/29.
//

import UIKit

open class TextField: UITextField {
    public var insets: UIEdgeInsets = .zero {
        didSet {
            guard insets != oldValue else { return }
            setNeedsDisplay()
        }
    }
    
    open override func textRect(forBounds bounds: CGRect) -> CGRect {
        calculateTextRect(forRect: bounds)
    }
    open override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        calculateTextRect(forRect: bounds)
    }
    open override func editingRect(forBounds bounds: CGRect) -> CGRect {
        calculateTextRect(forRect: bounds)
    }
    
    private func calculateTextRect(forRect rect: CGRect) -> CGRect {
        var paddedRect = rect.inset(by: insets)
        if rightViewMode == .always ||
            rightViewMode == .whileEditing,
           let rightV = rightView {
            paddedRect.size.width -= rightV.frame.width
        }
        return paddedRect
    }
}
