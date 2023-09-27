//
//  FoldButton.swift
//  SwifterKnife_Example
//
//  Created by 李阳 on 2023/9/19.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import SwifterKnife

class FoldButton: NewButton {
    var onClicked: ((FoldButton) -> Void)?
    override func setup() {
        super.setup()
        imagePosition = .right
        spacing = 4
        setImage(UIImage(named: "ic_unfold"), for: .normal)
        setTitle("", for: .normal)
//        titleLabel?.font = .regular12
//        setTitleColor(.primary, for: .normal)
        addTouchUpInside(self, #selector(tapSelf))
    }
    @objc private func tapSelf() {
        isSelected.toggle()
        onClicked?(self)
    }
    override var isSelected: Bool {
        didSet {
            guard isSelected != oldValue,
                  let imgView = imageView  else { return }
            if isSelected {
                UIView.animate(withDuration: 0.25) {
                    imgView.transform = CGAffineTransform(rotationAngle: .pi)
                }
            } else {
                UIView.animate(withDuration: 0.25) {
                    imgView.transform = .identity
                }
            }
        }
    }
}
