//
//  PaddingLabel.swift
//  SwifterKnife
//
//  Created by liyang on 2021/10/19.
//

import UIKit

public class PaddingLabel: UILabel {
    public var textContainerInset = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
 
    public override func drawText(in rect: CGRect) {
        return super.drawText(in: rect.inset(by: textContainerInset))
    }

    public override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        let inset = textContainerInset
        return CGSize(width: size.width + inset.left + inset.right, height: size.height + inset.top + inset.bottom)
    }
} 
