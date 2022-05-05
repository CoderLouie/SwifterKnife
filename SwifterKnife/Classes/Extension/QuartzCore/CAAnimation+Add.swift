//
//  CAAnimation+Add.swift
//  SwifterKnife
//
//  Created by liyang on 2022/02/23.
//


import UIKit

extension CAAnimation {
    public static var spring: CAKeyframeAnimation {
        let animate = CAKeyframeAnimation(keyPath: "transform")
        animate.duration = 0.4
        animate.isRemovedOnCompletion = true
        animate.fillMode = .forwards
        
        animate.values = [CATransform3DMakeScale(0.7, 0.7, 1),
                          CATransform3DMakeScale(1.2, 1.2, 1),
                          CATransform3DMakeScale(0.8, 0.8, 1),
                          CATransform3DMakeScale(1, 1, 1)]
        return animate
    }
    
    public static var rotate: CABasicAnimation {
        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.fromValue = 0
        animation.toValue = Double.pi * 2
        animation.duration = 1
        animation.autoreverses = false
        animation.repeatCount = MAXFLOAT
        return animation
    }
    
    public static var popJump: CAKeyframeAnimation {
        let animate = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animate.duration = 0.5
        animate.isRemovedOnCompletion = false
        
        let curTx: CGFloat = 0
        let delta: CGFloat = 10
        let deltaQuarter = delta / 4
        animate.values = [curTx,
                          curTx - deltaQuarter,
                          curTx - deltaQuarter * 2,
                          curTx - deltaQuarter * 3,
                          curTx - delta,
                          curTx - deltaQuarter * 3,
                          curTx - deltaQuarter * 2,
                          curTx - deltaQuarter,
                          curTx]
        animate.keyTimes = [0, 0.025, 0.085, 0.2, 0.5, 0.8, 0.915, 0.975, 1]
        animate.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animate.repeatCount = MAXFLOAT
        return animate
    }
}
 
