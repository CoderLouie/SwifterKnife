//
//  UITableView+Add.swift
//  SwifterKnife
//
//  Created by liyang on 2021/10/19.
//

import UIKit

public extension UITableView {
    var lastSection: Int? {
        let section = numberOfSections
        return section > 0 ? section - 1 : nil
    }
    
    func indexPathForLastRow(inSection section: Int) -> IndexPath? {
        let section = numberOfSections
        guard (0...section).contains(section) else { return nil }
        let row = numberOfRows(inSection: section)
        guard row > 0 else { return nil }
        return IndexPath(row: row - 1, section: section)
    }
    var indexPathForLastRow: IndexPath? {
        let section = numberOfSections - 1
        guard section >= 0 else { return nil }
        let row = numberOfRows(inSection: section) - 1
        guard row >= 0 else { return nil }
        return IndexPath(row: row, section: section)
    }
    
    func at_reloadData(_ completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0) {
            self.reloadData()
        } completion: { _ in
            completion()
        }
    }
    /// Gets the currently visibleCells of a section.
    ///
    /// - Parameter section: The section to filter the cells.
    /// - Returns: Array of visible UITableViewCell in the argument section.
    func visibleCells(in section: Int) -> [UITableViewCell] {
        return visibleCells.filter { indexPath(for: $0)?.section == section }
    }
    
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
