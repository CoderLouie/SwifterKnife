//
//  UIBarButtonItem+Add.swift
//  SwifterKnife
//
//  Created by liyang on 2021/10/19.
//

import UIKit

// MARK: - Properties

public extension UIBarButtonItem {
    /// Creates a flexible space UIBarButtonItem.
    static var flexibleSpace: UIBarButtonItem {
        return UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    }
}

// MARK: - Methods

public extension UIBarButtonItem {
    /// Add Target to UIBarButtonItem.
    ///
    /// - Parameters:
    ///   - target: target.
    ///   - action: selector to run when button is tapped.
    func addTarget(_ target: AnyObject, action: Selector) {
        self.target = target
        self.action = action
    }

    /// Creates a fixed space UIBarButtonItem with a specific width.
    ///
    /// - Parameter width: Width of the UIBarButtonItem.
    static func fixedSpace(width: CGFloat) -> UIBarButtonItem {
        let barButtonItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        barButtonItem.width = width
        return barButtonItem
    }
}
