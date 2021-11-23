//
//  CALayer+Add.swift
//  SwifterKnife
//
//  Created by liyang on 2021/11/20.
//

import QuartzCore

// MARK: - Properties

public extension CALayer {
    /// 核心动画是否处于暂停状态
    var animationIsPaused: Bool { timeOffset > 0 }
}

// MARK: - Methods

public extension CALayer {
    
    /// 暂停核心动画
    func pauseAnimation() {
        let now = convertTime(CACurrentMediaTime(), from: nil)
        speed = 0
        timeOffset = now
    }
    
    /// 继续执行核心动画
    func resumeAnimation() {
        let pauseTime = timeOffset
        speed = 1.0
        timeOffset = 0
        beginTime = 0
        beginTime = convertTime(CACurrentMediaTime(), from: nil) - pauseTime
    }
}
