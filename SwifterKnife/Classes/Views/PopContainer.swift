//
//  PopContainer.swift
//  SwifterKnife
//
//  Created by liyang on 2024/9/23.
//

import UIKit
import SnapKit
import SwifterKnife

public final class PopContainer: UIView {
    public enum ArrowDirection {
        case up
        case down
    }
    public final class Config {
        public var popAreaInset: UIEdgeInsets = .init(top: -1, left: 10, bottom: -1, right: 10)
        public var contentEdgeInset: UIEdgeInsets = .zero
        public var arrowSize = CGSize(width: 12, height: 8)
        public var spaceBetweenSource: CGFloat = 5
        
        // 圆角和箭头起始点之间的最小水平间距
        public var minSpaceBetweenCornerAndArrow: CGFloat = 2
        
        public var bgColor: UIColor? = nil
        public var outlineColor: UIColor? = nil
        public var outlineWidth: CGFloat = 0
        public var outlineRadius: CGFloat = 5
        public var arrowRadius: CGFloat = 0
        
        public var direction: ArrowDirection?
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        shapeLayer = CAShapeLayer().then {
            layer.addSublayer($0)
        }
        super.backgroundColor = .clear
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private unowned var shapeLayer: CAShapeLayer!
    
    @discardableResult
    public func show(_ contentView: UIView, on view: UIView?, from sourceView: UIView?, rect targetRect: CGRect? = nil, config cfgClosure: (Config) -> Void) -> Config? {
        guard let parentView: UIView = view ?? App.keyWindow else { return nil }
        let parentBounds = parentView.bounds
        let parentSize = parentBounds.size
        let sourceRect: CGRect = {
            if let v = sourceView {
                return v.convert(targetRect ?? v.bounds, to: parentView)
            } else {
                return targetRect ?? CGRect(x: parentBounds.midX - 1, y: parentBounds.midY - 1, width: 2, height: 2)
            }
        }()
        let cfg = Config()
        cfgClosure(cfg)
        
        let arrowOffset = cfg.spaceBetweenSource
        let radius = cfg.outlineRadius
        let arrowH = cfg.arrowSize.height
        let arrowW = cfg.arrowSize.width
        let arrowW2 = arrowW * 0.5
        
        let dir: ArrowDirection = cfg.direction ?? {
            let d: ArrowDirection = sourceRect.midY > parentBounds.midY ? .down : .up
            cfg.direction = d
            return d
        }()
        var inset = cfg.contentEdgeInset
        if dir == .up { inset.top += arrowH }
        else { inset.bottom += arrowH }
        
        contentView.removeFromSuperview()
        self.removeFromSuperview()
        addSubview(contentView)
        parentView.addSubview(self)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(inset)
        }
        self.snp.makeConstraints { make in
            make.top.leading.equalTo(100)
        }
        parentView.layoutIfNeeded()
        let selfSize = self.bounds.size
        
        let popInset = cfg.popAreaInset
        let roundLineSpace: CGFloat = cfg.minSpaceBetweenCornerAndArrow
        let sourceRectMidx = sourceRect.midX
         
        var arrowX = sourceRectMidx
        let limit = radius + roundLineSpace + arrowW2
        var left = sourceRectMidx - selfSize.width * 0.5
        if left >= popInset.left {
            let max = parentSize.width - popInset.right
            left = min(left, max - selfSize.width)
            arrowX = min(arrowX, max - limit)
        } else {
            left = popInset.left
            arrowX = max(arrowX, popInset.left + limit)
        }
        arrowX -= left
        
        let arrowRadius = cfg.arrowRadius
        let path = UIBezierPath()
        if dir == .up {
            let y1: CGFloat = arrowH
            let y2: CGFloat = selfSize.height
            let x1: CGFloat = 0
            let x2: CGFloat = selfSize.width
            let rt: CGFloat = y1 + radius// radiusTop
            let rb: CGFloat = y2 - radius// radiusBottom
            let rl: CGFloat = x1 + radius// radiusLeft
            let rr: CGFloat = x2 - radius// radiusRight
            
            if arrowRadius > 0 {
                path.move(to: CGPoint(x: arrowX - arrowW2, y: y1))
            } else {
                path.move(to: CGPoint(x: arrowX, y: 0))
                path.addLine(to: CGPoint(x: arrowX - arrowW2, y: y1))
            }
            
            path.addLine(to: CGPoint(x: rl, y: y1))
            path.addArc(withCenter: CGPoint(x: rl, y: rt), radius: radius, startAngle: 1.5 * .pi, endAngle: .pi, clockwise: false)
            
            path.addLine(to: CGPoint(x: x1, y: rb))
            path.addArc(withCenter: CGPoint(x: rl, y: rb), radius: radius, startAngle: .pi, endAngle: .pi * 0.5, clockwise: false)
            
            path.addLine(to: CGPoint(x: rr, y: y2))
            path.addArc(withCenter: CGPoint(x: rr, y: rb), radius: radius, startAngle: .pi * 0.5, endAngle: 0, clockwise: false)
            
            path.addLine(to: CGPoint(x: x2, y: rt))
            path.addArc(withCenter: CGPoint(x: rr, y: rt), radius: radius, startAngle: 0, endAngle: .pi * 1.5, clockwise: false)
            
            path.addLine(to: CGPoint(x: arrowX + arrowW2, y: y1))
            
            if arrowRadius > 0 {
                let angle2 = atan(arrowW2 / arrowH)
                let maxRadius = arrowH * sin(angle2)
                let usingRadius = min(arrowRadius, maxRadius)
                let center = CGPoint(x: arrowX, y: usingRadius / sin(angle2))
                let startAngle = -angle2
                let endAngle = startAngle - .pi + angle2 * 2
                path.addArc(withCenter: center, radius: usingRadius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
            }
        } else {
            let h: CGFloat = selfSize.height
            let y1: CGFloat = 0
            let y2: CGFloat = h - arrowH
            let x1: CGFloat = 0
            let x2: CGFloat = selfSize.width
            let rt: CGFloat = radius
            let rb: CGFloat = y2 - radius
            let rl: CGFloat = x1 + radius
            let rr: CGFloat = x2 - radius
            
            if arrowRadius > 0 {
                path.move(to: CGPoint(x: arrowX - arrowW2, y: y2))
            } else {
                path.move(to: CGPoint(x: arrowX, y: h));
                path.addLine(to: CGPoint(x: arrowX - arrowW2, y: y2))
            }
            
            path.addLine(to: CGPoint(x: rl, y: y2))
            path.addArc(withCenter: CGPoint(x: rl, y: rb), radius: radius, startAngle: .pi * 0.5, endAngle: .pi, clockwise: true)
            
            path.addLine(to: CGPoint(x: x1, y: rt))
            path.addArc(withCenter: CGPoint(x: rl, y: rt), radius: radius, startAngle: .pi, endAngle: .pi * 1.5, clockwise: true)
            
            path.addLine(to: CGPoint(x: rr, y: y1))
            path.addArc(withCenter: CGPoint(x: rr, y: rt), radius: radius, startAngle: .pi * 1.5, endAngle: 0, clockwise: true)
            
            path.addLine(to: CGPoint(x: x2, y: rb))
            path.addArc(withCenter: CGPoint(x: rr, y: rb), radius: radius, startAngle: 0, endAngle: .pi * 0.5, clockwise: true)
            
            path.addLine(to: CGPoint(x: arrowX + arrowW2, y: y2))
            
            if arrowRadius > 0 {
                let angle2 = atan(arrowW2 / arrowH)
                let maxRadius = arrowH * sin(angle2)
                let usingRadius = min(arrowRadius, maxRadius)
                let center = CGPoint(x: arrowX, y: h - usingRadius / sin(angle2))
                let startAngle = angle2
                let endAngle = startAngle + .pi - angle2 * 2
                path.addArc(withCenter: center, radius: usingRadius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
            }
        }
        path.close()
        shapeLayer.do {
            $0.path = path.cgPath
            if let c = cfg.bgColor {
                $0.fillColor = c.cgColor
            }
            $0.strokeColor = cfg.outlineColor?.cgColor
            $0.lineWidth = cfg.outlineWidth
//            $0.lineCap = .round
//            $0.lineJoin = .round
        }
        contentView.backgroundColor = .clear
        
        let top = dir == .up ? sourceRect.maxY + arrowOffset : sourceRect.minY  - arrowOffset - selfSize.height
        self.snp.updateConstraints { make in
            make.leading.equalTo(left)
            make.top.equalTo(top)
        }
        return cfg
    }
    public override var backgroundColor: UIColor? {
        get { shapeLayer.fillColor.map(UIColor.init) }
        set { shapeLayer.fillColor = newValue?.cgColor }
    }
}
/*
 override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
     guard let touch = touches.first else { return }
     if hitTest(touch.location(in: self), with: event) === self {
         dismiss {}
     }
 }
 */
