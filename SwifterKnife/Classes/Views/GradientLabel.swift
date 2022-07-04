//
//  GradientLabel.swift
//  SwifterKnife
//
//  Created by 李阳 on 2022/7/4.
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
        set { label[keyPath: keyPath] = newValue }
    }
    
    private func setup() {
        backgroundColor = .clear
        
        gradientLayer = CAGradientLayer().then {
//            let colors: [UIColor] = [.white.withAlphaComponent(0.5), .white] 
            let colors: [UIColor] = [
                UIColor(hexString: "#FFCA70"),
                UIColor(hexString: "#FFAF28")]
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
            $0.text = "Slider to see the changes"
            addSubview($0)
        }
    }
    
    
    public override var intrinsicContentSize: CGSize {
        let size = label.intrinsicContentSize
        Console.log(size, whose: self)
        let inset = textInsets
        return CGSize(width: size.width + inset.left + inset.right, height: size.height + inset.top + inset.bottom)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        let bounds = bounds
        let insetBounds = bounds.inset(by: textInsets)
        var textSize = label.intrinsicContentSize
        Console.log(textSize, whose: self)
        if textSize.width > insetBounds.width {
            if label.numberOfLines != 1 {
                label.preferredMaxLayoutWidth = insetBounds.width
                textSize = label.intrinsicContentSize
                invalidateIntrinsicContentSize()
                Console.log("invalidateIntrinsicContentSize", label.frame.size)
            } else {
                textSize.width = insetBounds.width
            }
        }
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
