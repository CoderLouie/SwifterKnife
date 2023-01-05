//
//  GradientView.swift
//  SwifterKnife
//
//  Created by liyang on 2022/7/4.
//

import UIKit

/*
 一旦把label层设置为mask层，label层就不能显示了,
 会直接从父层中移除，然后作为渐变层的mask层，且label层的父层会指向渐变层,
 父层改了，坐标系也就改了，需要重新设置label的位置，才能正确的设置裁剪区域
 */
@dynamicMemberLookup
open class GradientLabel: UIView {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public enum GradientComponent {
        /// 背景渐变
        case background
        /// 文字渐变
        case text
    }
    public var gradientComponent: GradientComponent = .background {
        didSet {
            guard gradientComponent != oldValue else { return }
            if gradientComponent == .background {
                gradientLayer.mask = nil
                addSubview(label)
            } else {
                gradientLayer.mask = label.layer
            }
            setNeedsLayout()
        }
    }
    public var textInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10) {
        didSet {
            guard textInsets != oldValue else { return }
            setNeedsLayout()
        }
    }
    public var textPosition: Position = .leftCenter {
        didSet {
            guard textPosition != oldValue else { return }
            setNeedsLayout()
        }
    }
    
    public var gradientColors: [UIColor]? {
        set {
            gradientLayer.colors = newValue.map { $0.map(\.cgColor) }
        }
        get {
            guard let colors = gradientLayer.colors as? [CGColor] else {
                return nil
            }
            return colors.map(UIColor.init(cgColor:))
        }
    }
    
    public subscript<Value>(dynamicMember keyPath: WritableKeyPath<UILabel, Value>) -> Value {
        get { label[keyPath: keyPath] }
        set {
            label[keyPath: keyPath] = newValue
            if keyPath == \UILabel.text ||
                keyPath == \UILabel.attributedText {
                invalidateIntrinsicContentSize()
            }
        }
    }
    
    private func setup() {
        backgroundColor = .clear
        
        gradientLayer = CAGradientLayer().then {
            let colors: [UIColor] = [.white.withAlphaComponent(0.5), .white]
            $0.colors = colors.map { $0.cgColor }
            $0.locations = [0, 1]
            $0.startPoint = CGPoint(x: 0, y: 0.5)
            $0.endPoint = CGPoint(x: 1, y: 0.5)
            layer.addSublayer($0)
        }
        label = UILabel().then {
            $0.backgroundColor = .clear
            $0.textColor = .black
            $0.font = .medium(14)
            $0.text = " "
            addSubview($0)
        }
    }
    
    
    public override var intrinsicContentSize: CGSize {
        let size = label.intrinsicContentSize
        let inset = textInsets
        return CGSize(width: size.width + inset.left + inset.right, height: size.height + inset.top + inset.bottom)
    }
    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        intrinsicContentSize
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        let bounds = bounds
        let insetBounds = bounds.inset(by: textInsets)
        var textSize = label.intrinsicContentSize
        if textSize.width > insetBounds.width {
            if label.numberOfLines != 1 {
                label.preferredMaxLayoutWidth = insetBounds.width
                textSize = label.intrinsicContentSize
                invalidateIntrinsicContentSize()
            }
        }
        textSize.width = min(textSize.width, insetBounds.width)
        textSize.height = min(textSize.height, insetBounds.height)
        let textOrigin = CGPoint(x: (insetBounds.width - textSize.width) * textPosition.x + insetBounds.minX, y: (insetBounds.height - textSize.height) * textPosition.y + insetBounds.minY)
        label.frame = CGRect(origin: textOrigin, size: textSize)
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        if gradientComponent == .background {
            gradientLayer.frame = bounds
        } else {
            gradientLayer.frame = label.frame
            label.frame = gradientLayer.bounds
        }
        CATransaction.commit()
        
    }
    public private(set) var label: UILabel!
    public private(set) var gradientLayer: CAGradientLayer!
}


open class GradientControl: UIControl {
    
    public enum GradientComponent: Equatable {
        /// 背景渐变
        case background
        /// 文字渐变
        case border(_ width: CGFloat)
        
        public var isBorder: Bool {
            if case .border = self { return true }
            return false
        }
        
        public static func == (lhs: GradientComponent, rhs: GradientComponent) -> Bool {
            switch (lhs, rhs) {
            case (.background, .background): return true
            case let (.border(lw), .border(rw)):
                return lw == rw
            default: return false
            }
        }
    }
    public enum RoundedDirection {
        case horizontal
        case vertical
    }
    
    public enum RoundedWay {
        case fixed(CGFloat)
        case dynamic(RoundedDirection)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        layer.masksToBounds = true
        gradientLayer = CAGradientLayer().then {
            $0.locations = [0, 1]
            $0.startPoint = CGPoint(x: 0, y: 0.5)
            $0.endPoint = CGPoint(x: 1, y: 0.5)
            layer.insertSublayer($0, at: 0)
        }
        setup()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    open func setup() {
    }
    public var gradientComponent: GradientComponent = .background {
        didSet {
            guard gradientComponent != oldValue else { return }
            setNeedsLayout()
        }
    }
    public var roundedWay: RoundedWay? = nil {
        didSet {
            setNeedsLayout()
        }
    }
    public var gradientColors: [UIColor]? {
        set {
            gradientLayer.colors = newValue.map { $0.map(\.cgColor) }
        }
        get {
            guard let colors = gradientLayer.colors as? [CGColor] else {
                return nil
            }
            return colors.map(UIColor.init(cgColor:))
        }
    }
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        let bounds = bounds
        gradientLayer.frame = bounds
        
        var radius: CGFloat
        if let way = roundedWay {
            switch way {
            case .fixed(let rad):
                radius = rad
            case .dynamic(let dir):
                radius = dir == .horizontal ? bounds.width * 0.5 : bounds.height * 0.5
            }
        } else { radius = 0 }
        layer.cornerRadius = radius
        
        switch gradientComponent {
        case .background:
            gradientLayer.mask = nil
        case .border(let w):
            let maskLayer = CAShapeLayer()
            maskLayer.lineWidth = w
            let w2 = w * 0.5
            let pathBounds = bounds.inset(by: UIEdgeInsets(top: w2, left: w2, bottom: w2, right: w2))
            if let way = roundedWay {
                switch way {
                case .fixed(let rad):
                    radius = rad
                case .dynamic(let dir):
                    radius = dir == .horizontal ? pathBounds.width * 0.5 : pathBounds.height * 0.5
                }
            } else { radius = 0 }
            maskLayer.path = UIBezierPath(roundedRect: pathBounds, cornerRadius: radius).cgPath
            maskLayer.fillColor = UIColor.clear.cgColor
            maskLayer.strokeColor = UIColor.black.cgColor
            
            gradientLayer.mask = maskLayer
        }
    }
    private unowned var gradientLayer: CAGradientLayer!
}

