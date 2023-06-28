//
//  UITableView+Add.swift
//  SwifterKnife
//
//  Created by liyang on 2021/10/19.
//

import UIKit

public extension UITableView {
    
    @discardableResult
    func scrollToFirstRow(at position: UITableView.ScrollPosition = .top,
                          animated: Bool = true) -> Bool {
        guard numberOfSections > 0 else { return false }
        guard numberOfRows(inSection: 0) > 0 else { return false }
        let indexPath = IndexPath(row: 0, section: 0)
        scrollToRow(at: indexPath, at: position, animated: animated)
        return true
    }
    @discardableResult
    func scrollToLastRow(at position: UITableView.ScrollPosition = .bottom,
                         animated: Bool = true) -> Bool {
        let section = numberOfSections
        guard section > 0 else { return false }
        let row = numberOfRows(inSection: section - 1)
        guard row > 0 else { return false }
        let indexPath = IndexPath(row: row - 1, section: section - 1)
        scrollToRow(at: indexPath, at: position, animated: animated)
        return true
    }
    
    
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
