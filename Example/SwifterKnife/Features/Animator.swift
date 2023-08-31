//
//  Animator.swift
//  SwifterKnife_Example
//
//  Created by 李阳 on 2023/8/30.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import Foundation

public struct AnimationKeyPaths {
    private static let shared = AnimationKeyPaths()
    private init() {}
    
    fileprivate static func animKeyPath<T: AnimationValueType>(of keyPath: KeyPath<AnimationKeyPaths, AnimationKeyPath<T>>) -> String {
        shared[keyPath: keyPath].rawValue
    }
}

public protocol AnimationValueType {}

public struct AnimationKeyPath<ValueType: AnimationValueType> {
    let rawValue: String

    init(keyPath: String) {
        self.rawValue = keyPath
    }
}
extension Array: AnimationValueType {}
extension Bool: AnimationValueType {}
extension CALayer: AnimationValueType {}
extension CATransform3D: AnimationValueType {}
extension CGColor: AnimationValueType {}
extension CGFloat: AnimationValueType {}
extension CGPath: AnimationValueType {}
extension CGPoint: AnimationValueType {}
extension CGRect: AnimationValueType {}
extension CGSize: AnimationValueType {}

extension AnimationKeyPaths {
    public var backgroundColor: AnimationKeyPath<CGColor> {
        .init(keyPath: #keyPath(CALayer.backgroundColor))
    }
    
    public var hidden: AnimationKeyPath<Bool> {
        .init(keyPath: #keyPath(CALayer.isHidden))
    }
    public var mask: AnimationKeyPath<CALayer> {
        .init(keyPath: #keyPath(CALayer.mask))
    }
    public var masksToBounds: AnimationKeyPath<Bool> {
        .init(keyPath: #keyPath(CALayer.masksToBounds))
    }
    public var opacity: AnimationKeyPath<CGFloat> {
        .init(keyPath: #keyPath(CALayer.opacity))
    }
    public var path: AnimationKeyPath<CGPath> {
        .init(keyPath: #keyPath(CAShapeLayer.path))
    }
    public var zPosition: AnimationKeyPath<CGFloat> {
        .init(keyPath: #keyPath(CALayer.zPosition))
    }
}
extension AnimationKeyPaths {
    public var borderColor: AnimationKeyPath<CGColor> {
        .init(keyPath: #keyPath(CALayer.borderColor))
    }
    public var borderWidth: AnimationKeyPath<CGFloat> {
        .init(keyPath: #keyPath(CALayer.borderWidth))
    }
    public var cornerRadius: AnimationKeyPath<CGFloat> {
        .init(keyPath: #keyPath(CALayer.cornerRadius))
    }
}

extension AnimationKeyPaths {
    public var anchorPoint: AnimationKeyPath<CGPoint> {
        .init(keyPath: #keyPath(CALayer.anchorPoint))
    }
    public var anchorPointX: AnimationKeyPath<CGPoint> {
        .init(keyPath: "\(#keyPath(CALayer.anchorPoint)).x")
    }
    public var anchorPointy: AnimationKeyPath<CGPoint> {
        .init(keyPath: "\(#keyPath(CALayer.anchorPoint)).y")
    }
}

extension AnimationKeyPaths {
    public var bounds: AnimationKeyPath<CGRect> {
        .init(keyPath: #keyPath(CALayer.bounds))
    }
    public var boundsOrigin: AnimationKeyPath<CGPoint> {
        .init(keyPath: "\(#keyPath(CALayer.bounds)).origin")
    }
    public var boundsOriginX: AnimationKeyPath<CGFloat> {
        .init(keyPath: "\(#keyPath(CALayer.bounds)).origin.x")
    }
    public var boundsOriginY: AnimationKeyPath<CGFloat> {
        .init(keyPath: "\(#keyPath(CALayer.bounds)).origin.y")
    }
    public var boundsSize: AnimationKeyPath<CGSize> {
        .init(keyPath: "\(#keyPath(CALayer.bounds)).size")
    }
    public var boundsSizeWidth: AnimationKeyPath<CGFloat> {
        .init(keyPath: "\(#keyPath(CALayer.bounds)).size.width")
    }
    public var boundsSizeHeight: AnimationKeyPath<CGFloat> {
        .init(keyPath: "\(#keyPath(CALayer.bounds)).size.height")
    }
    
}

extension AnimationKeyPaths {
    public var frame: AnimationKeyPath<CGRect> {
        .init(keyPath: #keyPath(CALayer.frame))
    }
    public var frameOrigin: AnimationKeyPath<CGPoint> {
        .init(keyPath: "\(#keyPath(CALayer.frame)).origin")
    }
    public var frameOriginX: AnimationKeyPath<CGFloat> {
        .init(keyPath: "\(#keyPath(CALayer.frame)).origin.x")
    }
    public var frameOriginY: AnimationKeyPath<CGFloat> {
        .init(keyPath: "\(#keyPath(CALayer.frame)).origin.y")
    }
    public var frameSize: AnimationKeyPath<CGSize> {
        .init(keyPath: "\(#keyPath(CALayer.frame)).size")
    }
    public var frameSizeWidth: AnimationKeyPath<CGFloat> {
        .init(keyPath: "\(#keyPath(CALayer.frame)).size.width")
    }
    public var frameSizeHeight: AnimationKeyPath<CGFloat> {
        .init(keyPath: "\(#keyPath(CALayer.frame)).size.height")
    }
}

extension AnimationKeyPaths {
    public var position: AnimationKeyPath<CGPoint> {
        .init(keyPath: #keyPath(CALayer.position))
    }
    public var positionX: AnimationKeyPath<CGFloat> {
        .init(keyPath: "\(#keyPath(CALayer.position)).x")
    }
    public var positionY: AnimationKeyPath<CGFloat> {
        .init(keyPath: "\(#keyPath(CALayer.position)).y")
    }
}

extension AnimationKeyPaths {
    public var transform: AnimationKeyPath<CATransform3D> {
        .init(keyPath: #keyPath(CALayer.transform))
    }
    public var transformRotationX: AnimationKeyPath<CGFloat> {
        .init(keyPath: "\(#keyPath(CALayer.transform)).rotation.x")
    }
    public var transformRotationY: AnimationKeyPath<CGFloat> {
        .init(keyPath: "\(#keyPath(CALayer.transform)).rotation.y")
    }
    public var transformRotationZ: AnimationKeyPath<CGFloat> {
        .init(keyPath: "\(#keyPath(CALayer.transform)).rotation.z")
    }
    public var transformScaleX: AnimationKeyPath<CGFloat> {
        .init(keyPath: "\(#keyPath(CALayer.transform)).scale.x")
    }
    public var transformScaleY: AnimationKeyPath<CGFloat> {
        .init(keyPath: "\(#keyPath(CALayer.transform)).scale.y")
    }
    public var transformScaleZ: AnimationKeyPath<CGFloat> {
        .init(keyPath: "\(#keyPath(CALayer.transform)).scale.z")
    }
    public var transformTranslationX: AnimationKeyPath<CGFloat> {
        .init(keyPath: "\(#keyPath(CALayer.transform)).translation.x")
    }
    public var transformTranslationY: AnimationKeyPath<CGFloat> {
        .init(keyPath: "\(#keyPath(CALayer.transform)).translation.y")
    }
    public var transformTranslationZ: AnimationKeyPath<CGFloat> {
        .init(keyPath: "\(#keyPath(CALayer.transform)).translation.z")
    }
}

extension CAAnimation {
    fileprivate func configure(delay: Double, duration: Double, timingFunction: CAMediaTimingFunction, isRemovedOnCompletion: Bool = false) {
        self.beginTime = delay
        self.duration = duration
        self.timingFunction = timingFunction
        self.fillMode = .forwards
        self.isRemovedOnCompletion = isRemovedOnCompletion
    }
}

public extension CAMediaTimingFunction {
    static var `default`: CAMediaTimingFunction {
        .init(name: .default)
    }
    static var linear: CAMediaTimingFunction {
        .init(name: CAMediaTimingFunctionName.linear)
    }
    static var easeIn: CAMediaTimingFunction {
        .init(name: CAMediaTimingFunctionName.easeIn)
    }
    static var easeOut: CAMediaTimingFunction {
        .init(name: CAMediaTimingFunctionName.easeOut)
    }
    static var easeInEaseOut: CAMediaTimingFunction {
        .init(name: CAMediaTimingFunctionName.easeInEaseOut)
    }
}

public final class Animator {
    
    public enum AnimationPlayType {
        /// run animation sequentially
        case sequence

        /// run animation parallelly
        case parallel
    }

    private weak var layer: CALayer?
    private var group = CAAnimationGroup()
    private var animations = [CAAnimation]()
    public private(set) var isCompleted: Bool = false

    public let key: String

    public init(layer: CALayer, forKey key: String? = nil) {
        self.layer = layer
        self.key = key ?? UUID().uuidString
    }
    public convenience init(view: UIView, forKey key: String? = nil) {
        self.init(layer: view.layer, forKey: key)
    }

    private func calculateBeginTime() {
        for (i, anim) in animations.enumerated() where i > 0 {
            let prev = animations[i - 1]
            anim.beginTime += prev.beginTime + prev.duration
        }
    }

    private func totalDuration(type: AnimationPlayType) -> Double {
        switch type {
        case .sequence:
            return animations.last.map { $0.beginTime + $0.duration } ?? 0
        case .parallel:
            return animations.map { $0.duration }.max() ?? 0
        }
    }

    public func delay(_ delay: Double) -> Self {
        if isCompleted { return self }
        let beginTime = delay < 0.0 ? 0.0 : delay
        group.beginTime = CACurrentMediaTime() + beginTime
        return self
    }

    public func forever(autoreverses: Bool = true) -> Self {
        if isCompleted { return self }
        group.repeatCount = Float.greatestFiniteMagnitude
        group.autoreverses = autoreverses
        return self
    }

    public func removeAll() -> Self {
        layer?.removeAllAnimations()
        group = CAAnimationGroup()
        animations = []
        isCompleted = false
        return self
    }

    public func cancel() {
        layer?.removeAnimation(forKey: key)
    }

    public func run(type: AnimationPlayType, fillMode: CAMediaTimingFillMode = .forwards, isRemovedOnCompletion: Bool = false, completion: (() -> Void)? = nil) {

        if case .sequence = type {
            calculateBeginTime()
        }
        group.animations = animations
        group.duration = totalDuration(type: type)
        group.fillMode = fillMode
        group.isRemovedOnCompletion = isRemovedOnCompletion

        if let completion = completion {
            CATransaction.begin()
            CATransaction.setCompletionBlock {
                completion()
            }
            layer?.add(group, forKey: key)
            CATransaction.commit()
        } else {
            layer?.add(group, forKey: key)
        }
        isCompleted = true
    }

    public func addAnimation(_ anim: CAAnimation) -> Self {
        if isCompleted { return self }
        animations.append(anim)
        return self
    }
    public func addBasicAnimation<T: AnimationValueType>(keyPath: KeyPath<AnimationKeyPaths, AnimationKeyPath<T>>, from: T, to: T, duration: Double, delay: Double = 0, timingFunction: CAMediaTimingFunction = .default) -> Self {
        if isCompleted { return self }
        let path = AnimationKeyPaths.animKeyPath(of: keyPath)
        let basicAnimation = CABasicAnimation(keyPath: path)
        basicAnimation.fromValue = from
        basicAnimation.toValue = to
        basicAnimation.configure(delay: delay, duration: duration, timingFunction: timingFunction)

        animations.append(basicAnimation)
        return self
    }

    @available(iOS 9, tvOS 10.0, macOS 10.11, *)
    public func addSpringAnimation<T: AnimationValueType>(keyPath: KeyPath<AnimationKeyPaths, AnimationKeyPath<T>>, from: T, to: T, damping: CGFloat, mass: CGFloat, stiffness: CGFloat, initialVelocity: CGFloat, duration: Double, delay: Double = 0, timingFunction: CAMediaTimingFunction = .default) -> Self {
        if isCompleted { return self }
        let path = AnimationKeyPaths.animKeyPath(of: keyPath)
        let springAnimation = CASpringAnimation(keyPath: path)
        springAnimation.fromValue = from
        springAnimation.toValue = to
        springAnimation.damping = damping
        springAnimation.mass = mass
        springAnimation.stiffness = stiffness
        springAnimation.initialVelocity = initialVelocity
        springAnimation.configure(delay: delay, duration: duration, timingFunction: timingFunction)

        animations.append(springAnimation)
        return self
    }

    public func addTransitionAnimation(startProgress: Float, endProgress: Float, type: CATransitionType, subtype: CATransitionSubtype, duration: Double, delay: Double = 0, timingFunction: CAMediaTimingFunction = .default) -> Self {
        if isCompleted { return self }
        let transitionAnimation = CATransition()
        transitionAnimation.startProgress = startProgress
        transitionAnimation.endProgress = endProgress
        transitionAnimation.type = type
        transitionAnimation.subtype = subtype
        transitionAnimation.configure(delay: delay, duration: duration, timingFunction: timingFunction)

        animations.append(transitionAnimation)
        return self
    }
}
