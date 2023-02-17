//
//  UIStackView+Add.swift
//  SwifterKnife
//
//  Created by liyang on 2023/2/17.
//

import UIKit

public extension UIStackView {
    static var vertical: UIStackView {
        return UIStackView(axis: .vertical, alignment: .center)
    }
    static var horizontal: UIStackView {
        return UIStackView(axis: .horizontal, alignment: .center)
    }
    
    /// Initialize an UIStackView with an array of UIView and common parameters.
    ///
    /// - Parameters:
    ///   - axis: The axis along which the arranged views are laid out.
    ///   - spacing: The distance in points between the adjacent edges of the stack view’s arranged views (default: 0.0).
    ///   - alignment: The alignment of the arranged subviews perpendicular to the stack view’s axis (default: .fill).
    ///   - distribution: The distribution of the arranged views along the stack view’s axis (default: .fill).
    convenience init(
        axis: NSLayoutConstraint.Axis,
        spacing: CGFloat = 0.0,
        alignment: UIStackView.Alignment = .fill,
        distribution: UIStackView.Distribution = .fill) {
        self.init(frame: .zero)
        self.axis = axis
        self.spacing = spacing
        self.alignment = alignment
        self.distribution = distribution
    }
    /// Adds array of views to the end of the arrangedSubviews array.
    ///
    /// - Parameter views: views array.
    func addArrangedSubviews(_ views: [UIView]) {
        for view in views {
            addArrangedSubview(view)
        }
    }

    /// Removes all views in stack’s array of arranged subviews.
    func removeArrangedSubviews() {
        for view in arrangedSubviews {
            removeArrangedSubview(view)
        }
    }
    
    /// Exchanges two views of the arranged subviews.
    /// - Parameters:
    ///   - view1: first view to swap.
    ///   - view2: second view to swap.
    ///   - animated: set true to animate swap (default is true).
    ///   - duration: animation duration in seconds (default is 1 second).
    ///   - delay: animation delay in seconds (default is 1 second).
    ///   - options: animation options (default is AnimationOptions.curveLinear).
    ///   - completion: optional completion handler to run with animation finishes (default is nil).
    func swap(_ view1: UIView, _ view2: UIView,
              animated: Bool = false,
              duration: TimeInterval = 0.25,
              delay: TimeInterval = 0,
              options: UIView.AnimationOptions = .curveLinear,
              completion: ((Bool) -> Void)? = nil) {
        func swapViews(_ view1: UIView, _ view2: UIView) {
            guard let view1Index = arrangedSubviews.firstIndex(of: view1),
                  let view2Index = arrangedSubviews.firstIndex(of: view2)
            else { return }
            removeArrangedSubview(view1)
            insertArrangedSubview(view1, at: view2Index)

            removeArrangedSubview(view2)
            insertArrangedSubview(view2, at: view1Index)
        }
        if animated {
            UIView.animate(withDuration: duration, delay: delay, options: options, animations: {
                swapViews(view1, view2)
                self.layoutIfNeeded()
            }, completion: completion)
        } else {
            swapViews(view1, view2)
        }
    }
}