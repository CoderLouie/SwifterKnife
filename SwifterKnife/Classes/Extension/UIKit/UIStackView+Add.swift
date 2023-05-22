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
    
    static func vertical(spacing: CGFloat = 0,
                         alignment: UIStackView.Alignment = .center,
                         @ViewsBuilder views: () -> [UIView]) -> Self {
        create(axis: .vertical, arrangedSubviews: views(), spacing: spacing, alignment: alignment, distribution: .fill)
    }
    static func horizontal(spacing: CGFloat = 0,
                           alignment: UIStackView.Alignment = .center,
                           @ViewsBuilder views: () -> [UIView]) -> Self {
        create(axis: .horizontal, arrangedSubviews: views(), spacing: spacing, alignment: alignment, distribution: .fill)
    }
    
    /// Create an UIStackView with an array of UIView and common parameters.
    ///
    /// - Parameters:
    ///   - arrangedSubviews: The UIViews to add to the stack.
    ///   - axis: The axis along which the arranged views are laid out.
    ///   - spacing: The distance in points between the adjacent edges of the stack view’s arranged views (default: 0.0).
    ///   - alignment: The alignment of the arranged subviews perpendicular to the stack view’s axis (default: .center).
    ///   - distribution: The distribution of the arranged views along the stack view’s axis (default: .fill).
    static func create(
        axis: NSLayoutConstraint.Axis,
        arrangedSubviews: [UIView] = [],
        spacing: CGFloat = 0.0,
        alignment: UIStackView.Alignment = .center,
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
    
    func arrangedSubview<T: UIView>(at index: Int) -> T? {
        let views = arrangedSubviews
        guard views.indices.contains(index) else { return nil }
        return views[index] as? T
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
        insertArrangedSubview(view, at: index)
    }
    
    
    @discardableResult
    func customSpacing(_ spacing: CGFloat, at index: Int) -> UIStackView {
        let subviews = arrangedSubviews
        if subviews.count >= index, index > 0 {
            setCustomSpacing(spacing, after: subviews[index - 1])
        }
        return self
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
    func swap(_ view1: UIView, _ view2: UIView) {
        guard let view1Index = arrangedSubviews.firstIndex(of: view1),
              let view2Index = arrangedSubviews.firstIndex(of: view2)
        else { return }
        removeArrangedSubview(view1)
        insertArrangedSubview(view1, at: view2Index)

        removeArrangedSubview(view2)
        insertArrangedSubview(view2, at: view1Index)
    }
    
    
    /// Exchanges two views of the arranged subviews animated.
    /// - Parameters:
    ///   - view1: first view to swap.
    ///   - view2: second view to swap.
    ///   - duration: animation duration in seconds (default is 0.25 second).
    ///   - delay: animation delay in seconds (default is 0 second).
    ///   - options: animation options (default is AnimationOptions.curveLinear).
    ///   - completion: optional completion handler to run with animation finishes (default is nil).
    func swapAnimated(_ view1: UIView, _ view2: UIView,
                      duration: TimeInterval = 0.25,
                      delay: TimeInterval = 0,
                      options: UIView.AnimationOptions = .curveLinear,
                      completion: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: duration, delay: delay, options: options, animations: {
            self.swap(view1, view2)
            self.layoutIfNeeded()
        }, completion: completion)
    }
}
public final class PairView<V1: UIView, V2: UIView>: UIStackView {
    public convenience init(config1: (V1) -> Void, config2: (V2) -> Void) {
        self.init(v1: V1().then(config1), v2: V2().then(config2))
    }
    public convenience init(v1: V1, v2: V2) {
        self.init(arrangedSubviews: [v1, v2])
        axis = .vertical
        alignment = .center
        view1 = v1
        view2 = v2
    }
    public private(set) unowned var view1: V1!
    public private(set) unowned var view2: V2!
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
