//
//  CALayer+Add.swift
//  SwifterKnife
//
//  Created by liyang on 2021/11/20.
//

import QuartzCore

public extension CALayer {
    func pauseAnimation() {
        speed = 0
        timeOffset = convertTime(CACurrentMediaTime(), from: nil)
    }
    func resumeAnimation() {
        speed = 1.0
        beginTime = convertTime(CACurrentMediaTime(), from: nil) - timeOffset
        timeOffset = 0
    }
}
