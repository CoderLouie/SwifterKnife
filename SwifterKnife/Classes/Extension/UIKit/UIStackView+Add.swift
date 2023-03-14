//
//  UIStackView+Add.swift
//  SwifterKnife
//
//  Created by liyang on 2023/2/17.
//

import UIKit

open class NormalStackView: UIStackView {
    open override class var layerClass: AnyClass {
        UIView.layerClass
    }
}

public extension UIStackView {
    static var vertical: Self {
        return .create(axis: .vertical, alignment: .center)
    }
    static var horizontal: Self {
        return .create(axis: .horizontal, alignment: .center)
    }
    
    /// Create an UIStackView with an array of UIView and common parameters.
    ///
    /// - Parameters:
    ///   - arrangedSubviews: The UIViews to add to the stack.
    ///   - axis: The axis along which the arranged views are laid out.
    ///   - spacing: The distance in points between the adjacent edges of the stack view’s arranged views (default: 0.0).
    ///   - alignment: The alignment of the arranged subviews perpendicular to the stack view’s axis (default: .fill).
    ///   - distribution: The distribution of the arranged views along the stack view’s axis (default: .fill).
    static func create(
        axis: NSLayoutConstraint.Axis,
        arrangedSubviews: [UIView] = [],
        spacing: CGFloat = 0.0,
        alignment: UIStackView.Alignment = .fill,
        distribution: UIStackView.Distribution = .fill) -> Self {
        let view = Self(arrangedSubviews: arrangedSubviews)
        view.axis = axis
        view.spacing = spacing
        view.alignment = alignment
        view.distribution = distribution
        return view
    }
    
    func addArrangedSubviews(_ views: UIView...) {
        addArrangedSubviews(views)
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
    
    func prependArrangedSubview(_ view: UIView) {
        insertArrangedSubview(view, at: 0)
    }
    
    func firstArrangedSubview<T: UIView>(as type: T.Type = T.self) -> T? {
        arrangedSubviews.first { $0 is T } as? T
    }
    func lastArrangedSubview<T: UIView>(as type: T.Type = T.self) -> T? {
        arrangedSubviews.last { $0 is T } as? T
    }
    
    func arrangedIndex(of view: UIView) -> Int? {
        return arrangedSubviews.firstIndex(of: view)
    }
    
    func addArrangedSubview(_ view: UIView, spaceToPrevious space: CGFloat) {
        insertArrangedSubview(view, at: arrangedSubviews.count, spaceToPrevious: space)
    }
    func insertArrangedSubview(_ view: UIView, at index: Int, spaceToPrevious space: CGFloat) {
        let subviews = arrangedSubviews
        if subviews.count >= index, index > 0 {
            setCustomSpacing(space, after: subviews[index - 1])
        }
        addArrangedSubview(view)
    }
    
    @discardableResult
    func margin(_ margins: UIEdgeInsets) -> UIStackView {
        layoutMargins = margins
        isLayoutMarginsRelativeArrangement = true
        return self
    }

    @discardableResult
    func alignment(_ alignment: UIStackView.Alignment) -> UIStackView {
        self.alignment = alignment
        return self
    }
    
    @discardableResult
    func spacing(_ spacing: CGFloat) -> UIStackView {
        self.spacing = spacing
        return self
    }

    @discardableResult
    func distribution(_ distribution: UIStackView.Distribution) -> UIStackView {
        self.distribution = distribution
        return self
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


@resultBuilder
public enum ArrayBuilder<I> {

    public typealias Expression = I
    public typealias Component = [I]

    public static func buildExpression(_ expression: Expression) -> Component {
        return [expression]
    }

    public static func buildExpression(_ expression: Component) -> Component {
        return expression
    }

    public static func buildExpression(_ expression: Expression?) -> Component {
        guard let expression = expression else { return [] }
        return [expression]
    }

    public static func buildBlock(_ children: Component...) -> Component {
        return children.flatMap { $0 }
    }

    public static func buildBlock(_ component: Component) -> Component {
        return component
    }

    public static func buildOptional(_ children: Component?) -> Component {
        return children ?? []
    }

    public static func buildEither(first child: Component) -> Component {
        return child
    }

    public static func buildEither(second child: Component) -> Component {
        return child
    }

    public static func buildArray(_ components: [Component]) -> Component {
        return components.flatMap { $0 }
    }
}

public typealias ViewsBuilder = ArrayBuilder<UIView>

public func hStack(normalized: Bool = false,
                   @ViewsBuilder views: () -> [UIView]) -> UIStackView {
    (normalized ? NormalStackView.self : UIStackView.self).create(axis: .horizontal, arrangedSubviews: views())
}
public func vStack(normalized: Bool = false,
                   @ViewsBuilder views: () -> [UIView]) -> UIStackView {
    (normalized ? NormalStackView.self : UIStackView.self).create(axis: .vertical, arrangedSubviews: views())
}
