//
//  UISwitch+Add.swift
//  SwifterKnife
//
//  Created by liyang on 2021/10/19.
//

import UIKit

// MARK: - Methods

public extension UISwitch {
    /// Toggle a UISwitch.
    ///
    /// - Parameter animated: set true to animate the change (default is true).
    func toggle(animated: Bool = true) {
        setOn(!isOn, animated: animated)
    }
}
