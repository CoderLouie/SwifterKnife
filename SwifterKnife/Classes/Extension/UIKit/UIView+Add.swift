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

    /// Add shadow to view.
    ///
    /// - Note: This method only works with non-clear background color, or if the view has a `shadowPath` set.
    /// See parameter `opacity` for detail.
    ///
    /// - Parameters:
    ///   - color: shadow color (default is #137992).
    ///   - radius: shadow radius (default is 3).
    ///   - offset: shadow offset (default is .zero).
    ///   - opacity: shadow opacity (default is 0.5). It will also be affected by the `alpha` of `backgroundColor`.
    func addShadow(
        ofColor color: UIColor = UIColor(red: 0.07, green: 0.47, blue: 0.57, alpha: 1.0),
        radius: CGFloat = 3,
        offset: CGSize = .zero,
        opacity: Float = 0.5) {
        layer.shadowColor = color.cgColor
        layer.shadowOffset = offset
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity
        layer.masksToBounds = false
    }
    
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
    
    /// Remove all subviews in view.
    func removeSubviews() {
        subviews.forEach { $0.removeFromSuperview() }
    }

    /// Remove all gesture recognizers from view.
    func removeGestureRecognizers() {
        gestureRecognizers?.forEach(removeGestureRecognizer)
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
        UIView.animate(withDuration: aDuration, delay: 0, options: .curveLinear, animations: { () -> Void in
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
        let aDuration = animated ? duration : 0
        UIView.animate(withDuration: aDuration, animations: {
            self.transform = self.transform.concatenating(CGAffineTransform(rotationAngle: angleWithType))
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
            UIView.animate(withDuration: duration, delay: 0, options: .curveLinear, animations: { () -> Void in
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
    
    /// Search all superviews until a view with the condition is found.
    ///
    /// - Parameter predicate: predicate to evaluate on superviews.
    func ancestorView(where predicate: (UIView?) -> Bool) -> UIView? {
        if predicate(superview) {
            return superview
        }
        return superview?.ancestorView(where: predicate)
    }

    /// Search all superviews until a view with this class is found.
    ///
    /// - Parameter name: class of the view to search.
    func ancestorView<T: UIView>(withClass _: T.Type) -> T? {
        return ancestorView(where: { $0 is T }) as? T
    }
}

public extension UIView {
    func searchSubview<T: UIView>(reversed: Bool = true, where cond: (T) -> Bool) -> T? {
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
    
    /// Set some or all corners radiuses of view.
    ///
    /// - Parameters:
    ///   - radius: radius for selected corners.
    ///   - corners: array of corners to change (example: [.bottomLeft, .topRight]).
    ///   - fillColor: fillColor
    ///   - borderWidth: borderWidth
    ///   - borderColor: borderColor
    func roundCorners(_ radius: CGFloat,
                     corners: UIRectCorner,
                     fillColor: UIColor? = nil,
                     borderWidth: CGFloat? = nil,
                     borderColor: UIColor? = nil) {
        onDidLayout { this in
            let path = UIBezierPath(roundedRect: this.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
            let maskLayer = CAShapeLayer()
            var needAdd = false
            if let width = borderWidth {
                needAdd = true
                maskLayer.lineWidth = width
            }
            if let color = borderColor {
                needAdd = true
                maskLayer.strokeColor = color.cgColor
            }
            maskLayer.path = path.cgPath
            if !needAdd {
                if let bg = fillColor {
                    this.backgroundColor = bg
                }
                this.layer.mask = maskLayer
            } else {
                let bgColor = fillColor ?? this.backgroundColor
                maskLayer.fillColor = bgColor?.cgColor
                this.backgroundColor = .clear
                this.layer.addSublayer(maskLayer)
            }
        }
    }
}


public protocol ViewAddition {}
extension UIView: ViewAddition {}
public extension ViewAddition where Self: UIView {
    
    func onDidLayout(_ closure: @escaping (Self) -> Void) {
        if !bounds.isEmpty {
            closure(self)
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.onDidLayout(closure)
            }
        }
    }
}



public extension UIView {
    var middleW: CGFloat {
        return frame.size.width * 0.5
    }
    var middleH: CGFloat {
        return frame.size.height * 0.5
    }
}

/*
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

/*
public extension UIView {
    var centerX: CGFloat {
        get { center.y }
        set { center = CGPoint(x: center.x, y: newValue) }
    }
    var centerY: CGFloat {
        return frame.size.height * 0.5
    }
    var origin: CGPoint {
        get {
            return frame.origin
        }
        set {
            frame.origin = newValue
        }
    }
    var size: CGSize {
        get {
            return frame.size
        }
        set {
            frame.size = newValue
        }
    }
    var width: CGFloat {
        get {
            return frame.size.width
        }
        set {
            frame.size.width = newValue
        }
    }
    var height: CGFloat {
        get {
            return frame.size.height
        }
        set {
            frame.size.height = newValue
        }
    }
    var left: CGFloat {
        get {
            return frame.origin.x
        }
        set {
            frame.origin.x = newValue
        }
    }
    var right: CGFloat {
        get {
            return frame.origin.x + frame.size.width
        }
        set {
            frame.origin.x = newValue - frame.size.width
        }
    }
    var top: CGFloat {
        get {
            return frame.origin.y
        }
        set {
            frame.origin.y = newValue
        }
    }
    var bottom: CGFloat {
        get {
            return frame.origin.y + frame.size.height
        }
        set {
            frame.origin.y = newValue - frame.size.height
        }
    }
}
 */
