//
//  Position.swift
//  SwifterKnife
//
//  Created by liyang on 2022/7/4.
//

import UIKit

public typealias Position = CGPoint

public extension Position {
    static var leftTop: Position {
        return Position(x: 0, y: 0)
    }
    static var leftCenter: Position {
        return Position(x: 0, y: 0.5)
    }
    static var leftBottom: Position {
        return Position(x: 0, y: 1)
    }
    static var topCenter: Position {
        return Position(x: 0.5, y: 0)
    }
    static var center: Position {
        return Position(x: 0.5, y: 0.5)
    }
    static var bottomCenter: Position {
        return Position(x: 0.5, y: 1)
    }
    static var rightTop: Position {
        return Position(x: 1, y: 0)
    }
    static var rightCenter: Position {
        return Position(x: 1, y: 0.5)
    }
    static var rightBottom: Position {
        return Position(x: 1, y: 1)
    }
}


public struct RectCorner {
    let topLeft: CGFloat
    let topRight: CGFloat
    let bottomLeft: CGFloat
    let bottomRight: CGFloat
}
extension RectCorner: SwiftyAdaptable {
    public func adaptive(tramsform: (CGFloat) -> CGFloat) -> RectCorner {
        .init(topLeft: tramsform(topLeft),
              topRight: tramsform(topRight),
              bottomLeft: tramsform(bottomLeft),
              bottomRight: tramsform(bottomRight))
    }
}
extension RectCorner {
    public static var zero: RectCorner {
        .init(topLeft: 0, topRight: 0, bottomLeft: 0, bottomRight: 0)
    }
    
    public init(topLeft: CGFloat, topRight: CGFloat) {
        self.init(topLeft: topLeft, topRight: topRight, bottomLeft: topRight, bottomRight: topLeft)
    }
    
    public static func top(_ radius: CGFloat) -> RectCorner {
        let fit = radius.fit
        return .init(topLeft: fit, topRight: fit, bottomLeft: 0, bottomRight: 0)
    }
}
public class RoundedLayer: CAShapeLayer {
    public static func mask(_ corner: RectCorner) -> RoundedLayer {
        return RoundedLayer().then {
            $0.rectCorner = corner
            $0.fillColor = UIColor.black.cgColor
        }
    }
    
    public var rectCorner: RectCorner = .zero {
        didSet { setNeedsLayout() }
    }
    public override func layoutSublayers() {
        super.layoutSublayers()
        
        let f = bounds
        let c = rectCorner
        let topLC = CGPoint(x: f.minX + c.topLeft, y: f.minY + c.topLeft)
        let topRC = CGPoint(x: f.maxX - c.topRight, y: f.minY + c.topRight)
        let bottomRC = CGPoint(x: f.maxX - c.bottomRight, y: f.maxY - c.bottomRight)
        let bottomLC = CGPoint(x: f.minX + c.bottomLeft, y: f.maxY - c.bottomLeft)
        
        let path = UIBezierPath()
        path.addArc(withCenter: topLC, radius: c.topLeft, startAngle: .pi, endAngle: .pi * 1.5, clockwise: true)
        path.addLine(to: CGPoint(x: topRC.x, y: f.minY))
        path.addArc(withCenter: topRC, radius: c.topRight, startAngle: .pi * 1.5, endAngle: 0, clockwise: true)
        path.addLine(to: CGPoint(x: f.maxX, y: bottomRC.y))
        path.addArc(withCenter: bottomRC, radius: c.bottomRight, startAngle: 0, endAngle: .pi * 0.5, clockwise: true)
        path.addLine(to: CGPoint(x: bottomLC.x, y: f.maxY))
        path.addArc(withCenter: bottomLC, radius: c.bottomLeft, startAngle: .pi * 0.5, endAngle: .pi, clockwise: true)
        path.close()
        self.path = path.cgPath
    }
}


open class RoundedView: UIView {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    public var rectCorner: RectCorner {
        get { shaperLayer.rectCorner }
        set { shaperLayer.rectCorner = newValue }
    }
    public private(set) var shaperLayer: RoundedLayer!
    open func setup() {
        shaperLayer = RoundedLayer.mask(.zero)
        layer.mask = shaperLayer
    }
    open override func layoutSubviews() {
        super.layoutSubviews()
        shaperLayer.frame = bounds
    }
}
