//
//  PaddingLabel.swift
//  SwifterKnife
//
//  Created by liyang on 2021/10/19.
//

import UIKit 

open class PaddingButton: UIButton {
    open var containerInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    
    open override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        let inset = containerInset
        return CGSize(width: size.width + inset.left + inset.right, height: size.height + inset.top + inset.bottom)
    }
    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        intrinsicContentSize
    }
}
