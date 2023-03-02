//
//  UIView+Add.swift
//  SwifterKnife
//
//  Created by liyang on 2021/10/19.
//

import UIKit

// MARK: - enums

public extension UIView {
    /// Shake directions of a view.
    ///
    /// - horizontal: Shake left and right.
    /// - vertical: Shake up and down.
    enum ShakeDirection {
        /// Shake left and right.
        case horizontal
        
        /// Shake up and down.
        case vertical
    }
    
    /// Angle units.
    ///
    /// - degrees: degrees.
    /// - radians: radians.
    enum AngleUnit {
        /// degrees.
        case degrees
        
        /// radians.
        case radians
    }
    
    /// Shake animations types.
    ///
    /// - linear: linear animation.
    /// - easeIn: easeIn animation.
    /// - easeOut: easeOut animation.
    /// - easeInOut: easeInOut animation.
    enum ShakeAnimationType {
        /// linear animation.
        case linear
        
        /// easeIn animation.
        case easeIn
        
        /// easeOut animation.
        case easeOut
        
        /// easeInOut animation.
        case easeInOut
    }
}

// MARK: - Properties

public extension UIView {
    /// Take screenshot of view (if applicable).
    var screenshot: UIImage? {
        UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, 0)
        defer {
            UIGraphicsEndImageContext()
        }
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        layer.render(in: context)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    var screenshotView: UIImageView? {
        guard let snapshot = screenshot else { return nil }
        let imgView = UIImageView(image: snapshot)
        imgView.frame = frame
        return imgView
    }
    
    /// Get view's parent view controller
    var parentViewController: UIViewController? {
        weak var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}

// MARK: - Utils

public extension UIView {
    /// Recursively find the first responder.
    func firstResponder() -> UIView? {
        var views = [UIView](arrayLiteral: self)
        var index = 0
        repeat {
            let view = views[index]
            if view.isFirstResponder {
                return view
            }
            views.append(contentsOf: view.subviews)
            index += 1
        } while index < views.count
        return nil
    }
    
    /// Remove all subviews in view.
    func removeSubviews() {
        while let lastView = subviews.last {
            lastView.removeFromSuperview()
        }
    }
    
    /// Remove all gesture recognizers from view.
    func removeGestureRecognizers() {
        gestureRecognizers?.forEach(removeGestureRecognizer)
    }
    
    
    @discardableResult
    func enqueueSubview<View: UIView>(_ view: View, config: (View) -> Void) -> View {
        addSubview(view)
        config(view)
        return view
    }
}

// MARK: - Animation
public extension UIView {
    
    /// Fade in view.
    ///
    /// - Parameters:
    ///   - duration: animation duration in seconds (default is 1 second).
    ///   - completion: optional completion handler to run with animation finishes (default is nil).
    func fadeIn(duration: TimeInterval = 1, completion: ((Bool) -> Void)? = nil) {
        if isHidden {
            isHidden = false
        }
        UIView.animate(withDuration: duration, animations: {
            self.alpha = 1
        }, completion: completion)
    }
    
    /// Fade out view.
    ///
    /// - Parameters:
    ///   - duration: animation duration in seconds (default is 1 second).
    ///   - completion: optional completion handler to run with animation finishes (default is nil).
    func fadeOut(duration: TimeInterval = 1, completion: ((Bool) -> Void)? = nil) {
        if isHidden {
            isHidden = false
        }
        UIView.animate(withDuration: duration, animations: {
            self.alpha = 0
        }, completion: completion)
    }
    
    /// Rotate view by angle on relative axis.
    ///
    /// - Parameters:
    ///   - angle: angle to rotate view by.
    ///   - type: type of the rotation angle.
    ///   - animated: set true to animate rotation (default is true).
    ///   - duration: animation duration in seconds (default is 1 second).
    ///   - completion: optional completion handler to run with animation finishes (default is nil).
    func rotate(
        byAngle angle: CGFloat,
        ofType type: AngleUnit,
        animated: Bool = false,
        duration: TimeInterval = 1,
        completion: ((Bool) -> Void)? = nil) {
            let angleWithType = (type == .degrees) ? .pi * angle / 180.0 : angle
            let aDuration = animated ? duration : 0
            UIView.animate(withDuration: aDuration, delay: 0, options: .curveLinear, animations: {
                self.transform = self.transform.rotated(by: angleWithType)
            }, completion: completion)
        }
    
    /// Rotate view to angle on fixed axis.
    ///
    /// - Parameters:
    ///   - angle: angle to rotate view to.
    ///   - type: type of the rotation angle.
    ///   - animated: set true to animate rotation (default is false).
    ///   - duration: animation duration in seconds (default is 1 second).
    ///   - completion: optional completion handler to run with animation finishes (default is nil).
    func rotate(
        toAngle angle: CGFloat,
        ofType type: AngleUnit,
        animated: Bool = false,
        duration: TimeInterval = 1,
        completion: ((Bool) -> Void)? = nil) {
            let angleWithType = (type == .degrees) ? .pi * angle / 180.0 : angle
            let currentAngle = atan2(transform.b, transform.a)
            let aDuration = animated ? duration : 0
            UIView.animate(withDuration: aDuration, animations: {
                self.transform = self.transform.rotated(by: angleWithType - currentAngle)
            }, completion: completion)
        }
    
    /// Scale view by offset.
    ///
    /// - Parameters:
    ///   - offset: scale offset
    ///   - animated: set true to animate scaling (default is false).
    ///   - duration: animation duration in seconds (default is 1 second).
    ///   - completion: optional completion handler to run with animation finishes (default is nil).
    func scale(
        by offset: CGPoint,
        animated: Bool = false,
        duration: TimeInterval = 1,
        completion: ((Bool) -> Void)? = nil) {
            if animated {
                UIView.animate(withDuration: duration, delay: 0, options: .curveLinear, animations: {
                    self.transform = self.transform.scaledBy(x: offset.x, y: offset.y)
                }, completion: completion)
            } else {
                transform = transform.scaledBy(x: offset.x, y: offset.y)
                completion?(true)
            }
        }
    
    /// Shake view.
    ///
    /// - Parameters:
    ///   - direction: shake direction (horizontal or vertical), (default is .horizontal).
    ///   - duration: animation duration in seconds (default is 1 second).
    ///   - animationType: shake animation type (default is .easeOut).
    ///   - completion: optional completion handler to run with animation finishes (default is nil).
    func shake(
        direction: ShakeDirection = .horizontal,
        duration: TimeInterval = 1,
        animationType: ShakeAnimationType = .easeOut,
        completion: (() -> Void)? = nil) {
            CATransaction.begin()
            let animation: CAKeyframeAnimation
            switch direction {
            case .horizontal:
                animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
            case .vertical:
                animation = CAKeyframeAnimation(keyPath: "transform.translation.y")
            }
            switch animationType {
            case .linear:
                animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
            case .easeIn:
                animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
            case .easeOut:
                animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
            case .easeInOut:
                animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            }
            CATransaction.setCompletionBlock(completion)
            animation.duration = duration
            animation.values = [-20.0, 20.0, -20.0, 20.0, -10.0, 10.0, -5.0, 5.0, 0.0]
            layer.add(animation, forKey: "shake")
            CATransaction.commit()
        }
}

// MARK: - Search

public extension UIView {
    
    /// Search all superviews until a view with the condition is found.
    ///
    /// - Parameter predicate: predicate to evaluate on superviews.
    func ancestorView<T: UIView>(where predicate: (T) -> Bool) -> T? {
        var view = superview
        while let v = view {
            if let typeView = v as? T,
               predicate(typeView) {
                return typeView
            }
            view = v.superview
        }
        return nil
    }
    
    /**
     let effectView: UIImageView? = view.searchSubview(reversed: false) {
     $0.bounds.size.height < 2
     }
     */
    func searchSubview<T: UIView>(
        reversed: Bool = true,
        where cond: (T) -> Bool) -> T? {
        var views = [self]
        var index = 0
        repeat {
            let view = views[index]
            if let type = view as? T, cond(type) { return type }
            index += 1
            views.insert(contentsOf: reversed ? view.subviews.reversed() : view.subviews, at: index)
        } while index < views.count
        return nil
    }
    
    func firstSubview<T>(_ cond: ((T) -> Bool)? = nil) -> T? {
        subviews.first {
            guard let v = $0 as? T else { return false }
            return cond?(v) ?? true
        } as? T
    }
    
    func lastSubview<T>(_ cond: ((T) -> Bool)? = nil) -> T? {
        subviews.last {
            guard let v = $0 as? T else { return false }
            return cond?(v) ?? true
        } as? T
    }
    
    /// Returns all the subviews of a given type recursively in the
    /// view hierarchy rooted on the view it its called.
    ///
    /// - Parameter ofType: Class of the view to search.
    /// - Returns: All subviews with a specified type.
    func subviews<T>(ofType _: T.Type) -> [T] {
        var views = [T]()
        for subview in subviews {
            if let view = subview as? T {
                views.append(view)
            } else if !subview.subviews.isEmpty {
                views.append(contentsOf: subview.subviews(ofType: T.self))
            }
        }
        return views
    }
}

// MARK: - Constraints

public extension UIView {
    /// Search constraints until we find one for the given view
    /// and attribute. This will enumerate ancestors since constraints are
    /// always added to the common ancestor.
    ///
    /// - Parameter attribute: the attribute to find.
    /// - Returns: matching constraint.
    func findConstraint(attribute: NSLayoutConstraint.Attribute) -> NSLayoutConstraint? {
        let constraint = constraints.first {
            ($0.firstAttribute == attribute && $0.firstItem as? UIView == self) ||
            ($0.secondAttribute == attribute && $0.secondItem as? UIView == self)
        }
        return constraint ?? superview?.findConstraint(attribute: attribute)
    }
}

public extension UIView {
    
    func addTap(target: Any?, action: Selector?) {
        addGestureRecognizer(UITapGestureRecognizer(target: target, action: action))
    }
    
    func fittingSize(withRequiredWidth width: CGFloat) -> CGSize {
        systemLayoutSizeFitting(
            CGSize(width: width, height: 0),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel)
    }
    func fittingSize(withRequiredHeight height: CGFloat) -> CGSize {
        systemLayoutSizeFitting(
            CGSize(width: 0, height: height),
            withHorizontalFittingPriority: .fittingSizeLevel,
            verticalFittingPriority: .required)
    }
    // layoutFittingCompressedSize(尽可能小)
    // layoutFittingExpandedSize(尽可能大)
    var fittingSize: CGSize {
        systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
    }
    
    @available(iOS 11.0, *)
    func roundCorners(_ radius: CGFloat,
                         corners: UIRectCorner = .allCorners) {
        guard radius > 0 else { return }
        layer.masksToBounds = true
        layer.cornerRadius = radius
        var maskCorners: CACornerMask = []
        if corners.contains(.topLeft) {
            maskCorners.formUnion(.layerMinXMinYCorner)
        }
        if corners.contains(.topRight) {
            maskCorners.formUnion(.layerMaxXMinYCorner)
        }
        if corners.contains(.bottomLeft) {
            maskCorners.formUnion(.layerMinXMaxYCorner)
        }
        if corners.contains(.bottomRight) {
            maskCorners.formUnion(.layerMaxXMaxYCorner)
        }
        layer.maskedCorners = maskCorners
    }
    
    
    static func noTransaction(_ work: () -> Void) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        work()
        CATransaction.commit()
    }
      
}


/*
 一句话总结“Intrinsic冲突”：两个或多个可以使用Intrinsic Content Size的组件，因为组件中添加的其他约束，而无法同时使用 intrinsic Content Size了。
 
 Content Hugging Priority
 抗拉伸 值(默认250)越小 越容易被拉伸，
 当子视图不足以填充满父视图的空间时，优先满足此属性值较大的子视图的内容展示，而拉伸属性值较低的子视图。
 控制当内容不足以填充满空间时，优先满足此属性值较大的子view的内容展示，而拉伸属性值较低的子view。
 $0.setContentHuggingPriority(.required, for: .horizontal)
 
 Content Compression Resistance Priority
 抗压缩，值(默认750)越小，越容易被压缩
 当子视图所需的内容超出父视图的空间时，优先展示此值较大的子视图，而省略压缩此值较小的子视图。
 $0.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
 */

 
public extension UIVisualEffectView {
    var bgColor: UIColor? {
        get {
            guard subviews.count > 1 else { return nil }
            return subviews[1].backgroundColor
        }
        set {
            guard subviews.count > 1 else { return }
            subviews[1].backgroundColor = newValue
        }
    }
}

open class WrapLabel: UILabel {
    open override func layoutSubviews() {
        super.layoutSubviews()
        if numberOfLines == 1 { return }
        let bounds = bounds
        if preferredMaxLayoutWidth > 0, preferredMaxLayoutWidth <= bounds.width {
            return
        }
        preferredMaxLayoutWidth = bounds.width
        invalidateIntrinsicContentSize()
    }
    open override var intrinsicContentSize: CGSize {
        super.intrinsicContentSize.adaptive(tramsform: \.pixCeil)
    }
}
