//
//  UICollectionView+Add.swift
//  SwifterKnife
//
//  Created by liyang on 2022/8/8.
//

import UIKit

public extension UICollectionView {
    convenience init(configLayout: (UICollectionViewFlowLayout) -> Void) {
        let layout = UICollectionViewFlowLayout()
        configLayout(layout)
        self.init(frame: .zero, collectionViewLayout: layout)        
    }
}
