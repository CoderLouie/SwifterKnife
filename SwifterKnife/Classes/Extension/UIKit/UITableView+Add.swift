//
//  UITableView+Add.swift
//  SwifterKnife
//
//  Created by liyang on 2021/10/19.
//

import UIKit
import SnapKit

public extension UITableView {
    func cellIsVisibleAt(_ indexPath: IndexPath) -> Bool {
        bounds.intersects(rectForRow(at: indexPath))
    }
    
    func tableHeaderViewSizeToFit() {
        tableHeaderOrFooterViewSizeToFit(\.tableHeaderView)
    }
    
    func tableFooterViewSizeToFit() {
        tableHeaderOrFooterViewSizeToFit(\.tableFooterView)
    }
    
    private func tableHeaderOrFooterViewSizeToFit(_ keyPath: ReferenceWritableKeyPath<UITableView, UIView?>) {
        guard let componentView = self[keyPath: keyPath] else { return }
        let height = componentView
            .systemLayoutSizeFitting(
                CGSize(width: frame.width, height: 0),
                withHorizontalFittingPriority: .required,
                verticalFittingPriority: .fittingSizeLevel)
            .height
        guard componentView.frame.height != height else { return }
        componentView.frame.size.height = height
        self[keyPath: keyPath] = componentView
    }
}
