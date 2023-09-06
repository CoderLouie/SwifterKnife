//
//  Animator.swift
//  SwifterKnife_Example
//
//  Created by 李阳 on 2023/8/30.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import Foundation
 

public struct Amount3D {
    public var x: CGFloat
    public var y: CGFloat
    public var z: CGFloat
    
    public static let zero = Amount3D(x: 0, y: 0, z: 0)
}
extension CATransform3D {
    public var rotation: Amount3D { .zero }
    public var scale: Amount3D { .zero }
    public var translation: Amount3D { .zero }
    
    public var _rotation: CGFloat { 0 }
    public var _scale: CGFloat { 0 }
    public var _translation: CGPoint { .zero }
}

extension PartialKeyPath where Root: CALayer {
    public var animKeyPath: String? {
        if let path = _kvcKeyPathString { return path }
        switch self {
        case \Root.anchorPoint.x: return "anchorPoint.x"
        case \Root.anchorPoint.y: return "anchorPoint.y"
            
        case \Root.position.x: return "position.x"
        case \Root.position.y: return "position.y"
            
        case \Root.shadowOffset.width: return "shadowOffset.width"
        case \Root.shadowOffset.height: return "shadowOffset.height"
          
        /// 默认围绕z轴
        case \Root.transform.rotation,
            \Root.transform._rotation: return "transform.rotation"
        /// 围绕x轴旋转的弧度
        case \Root.transform.rotation.x: return "transform.rotation.x"
        case \Root.transform.rotation.y: return "transform.rotation.y"
        case \Root.transform.rotation.z: return "transform.rotation.z"
            
        /// 所有方向缩放
        case \Root.transform.scale,
            \Root.transform._scale: return "transform.scale"
        /// x方向缩放
        case \Root.transform.scale.x: return "transform.scale.x"
        case \Root.transform.scale.y: return "transform.scale.y"
        case \Root.transform.scale.z: return "transform.scale.z"
            
        /// x,y 坐标均发生改变
        case \Root.transform.translation,
            \Root.transform._translation: return "transform.translation"
        /// x方向移动
        case \Root.transform.translation.x: return "transform.translation.x"
        case \Root.transform.translation.y: return "transform.translation.y"
        case \Root.transform.translation.z: return "transform.translation.z"
            
        case \Root.sublayerTransform.rotation.x: return "sublayerTransform.rotation.x"
        case \Root.sublayerTransform.rotation.y: return "sublayerTransform.rotation.y"
        case \Root.sublayerTransform.rotation.z: return "sublayerTransform.rotation.z"
            
        case \Root.sublayerTransform.scale.x: return "sublayerTransform.scale.x"
        case \Root.sublayerTransform.scale.y: return "sublayerTransform.scale.y"
        case \Root.sublayerTransform.scale.z: return "sublayerTransform.scale.z"
            
        case \Root.sublayerTransform.translation.x: return "sublayerTransform.translation.x"
        case \Root.sublayerTransform.translation.y: return "sublayerTransform.translation.y"
        case \Root.sublayerTransform.translation.z: return "sublayerTransform.translation.z"
            
        case \Root.bounds.origin: return "bounds.origin"
        case \Root.bounds.origin.x: return "bounds.origin.x"
        case \Root.bounds.origin.y: return "bounds.origin.y"
            
        case \Root.bounds.size: return "bounds.size"
        case \Root.bounds.size.width: return "bounds.size.width"
        case \Root.bounds.size.height: return "bounds.size.height"
            
        case \Root.frame.origin: return "frame.origin"
        case \Root.frame.origin.x: return "frame.origin.x"
        case \Root.frame.origin.y: return "frame.origin.y"
            
        case \Root.frame.size: return "frame.size"
        case \Root.frame.size.width: return "frame.size.width"
        case \Root.frame.size.height: return "frame.size.height"
        // 可视内容 参数：CGRect 值是0～1之间的小数
        case \Root.contentsRect.origin: return "contentsRect.origin"
        case \Root.contentsRect.origin.x: return "contentsRect.origin.x"
        case \Root.contentsRect.origin.y: return "contentsRect.origin.y"
            
        case \Root.contentsRect.size: return "contentsRect.size"
        case \Root.contentsRect.size.width: return "contentsRect.size.width"
        case \Root.contentsRect.size.height: return "contentsRect.size.height"
        default: return nil
        }
    }
}

extension CAPropertyAnimation {
    public func setSwiftlyKeyPath<T>(_ keyPath: KeyPath<CALayer, T>) {
        self.keyPath = keyPath.animKeyPath
    }
}

extension CABasicAnimation {
    public static func animate<T>(forKeyPath keyPath: KeyPath<CALayer, T>, fromValue: T?, toValue: T?) -> Self {
        let anim = Self(keyPath: keyPath.animKeyPath)
        anim.fromValue = fromValue
        anim.toValue = toValue
        return anim
    }
}

extension CAKeyframeAnimation {
    public static func animate<T>(forKeyPath keyPath: KeyPath<CALayer, T>, values: [T]?) -> Self {
        let anim = Self(keyPath: keyPath.animKeyPath)
        anim.values = values
        return anim
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
extension CATransitionType {
    public var cube: CATransitionType {
        .init(rawValue: "cube")
    }
    public var suckEffect: CATransitionType {
        .init(rawValue: "suckEffect")
    }
    public var oglFlip: CATransitionType {
        .init(rawValue: "oglFlip")
    }
    public var rippleEffect: CATransitionType {
        .init(rawValue: "rippleEffect")
    }
    public var pageCurl: CATransitionType {
        .init(rawValue: "pageCurl")
    }
    public var pageUnCurl: CATransitionType {
        .init(rawValue: "pageUnCurl")
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

    public func removeAll() -> Self {
        layer?.removeAllAnimations()
        animations = []
        return self
    }

    public func cancel() {
        layer?.removeAnimation(forKey: key)
    }

    /*
     group.fillMode = fillMode
     group.isRemovedOnCompletion = removedOnCompletion
     group.repeatCount = repeatCount
     group.autoreverses = autoreverses
     */
    public func run(type: AnimationPlayType,
                    delay: Double = 0,
                    config: (CAAnimationGroup) -> Void,
                    completion: (() -> Void)? = nil) {
        if case .sequence = type {
            calculateBeginTime()
        }
        let group = CAAnimationGroup()
        group.beginTime = CACurrentMediaTime() + max(delay, 0)
        group.animations = animations
        group.duration = totalDuration(type: type)
        config(group)
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
    public func addBasicAnimation<T>(keyPath: KeyPath<CALayer, T>, from: T?, to: T?, duration: Double, delay: Double = 0, timingFunction: CAMediaTimingFunction = .default) -> Self {
        if isCompleted { return self }
        guard let path = keyPath.animKeyPath else { return self }
        let basicAnimation = CABasicAnimation(keyPath: path)
        basicAnimation.fromValue = from
        basicAnimation.toValue = to
        basicAnimation.configure(delay: delay, duration: duration, timingFunction: timingFunction)

        animations.append(basicAnimation)
        return self
    }


    public func addSpringAnimation<T>(keyPath: KeyPath<CALayer, T>, from: T?, to: T?, damping: CGFloat, mass: CGFloat, stiffness: CGFloat, initialVelocity: CGFloat, duration: Double, delay: Double = 0, timingFunction: CAMediaTimingFunction = .default) -> Self {
        if isCompleted { return self }
        guard let path = keyPath.animKeyPath else { return self }
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
