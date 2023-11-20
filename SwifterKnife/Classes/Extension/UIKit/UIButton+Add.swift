//
//  UIButton+Add.swift
//  SwifterKnife
//
//  Created by liyang on 2021/10/19.
//

import UIKit

public struct TouchPosition: OptionSet {
    public let rawValue: Int
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    public static var left: TouchPosition { .init(rawValue: 1 << 0) }
    public static var right: TouchPosition { .init(rawValue: 1 << 1) }
    public static var top: TouchPosition { .init(rawValue: 1 << 2) }
    public static var bottom: TouchPosition { .init(rawValue: 1 << 3) }
}

extension UITouch {
    public var touchPosition: TouchPosition {
        guard let v = view else { return [] }
        let p = location(in: v)
        let size = v.bounds.size
        
        var res: TouchPosition = []
        
        if p.x > size.width * 0.5 {
            res.formUnion(.right)
        } else { res.formUnion(.left) }
        
        if p.y > size.height * 0.5 {
            res.formUnion(.bottom)
        } else { res.formUnion(.top) }
        
        return res
    }
}

extension UIEvent {
    
    /*
     Example
     btn.addTarget(self, action: #selector(onButtonClicked(_:_:)), for: .touchUpInside)
     
     @objc func onButtonClicked(_ sender: UIButton, _ event: UIEvent) {
        let res = event.touchPosition
        if res.contains(.right) {
            xxx
        } else {
            xxx
        }
     }
     */
    public var touchPosition: TouchPosition {
        guard let touch = allTouches?.randomElement() else { return [] }
        return touch.touchPosition
    }
}

public extension UIControl {
    
    func addTouchUpInside(_ target: Any?, _ action: Selector) {
        addTarget(target, action: action, for: .touchUpInside)
    }
}

public extension UIButton {
    /// Center align title text and image.
    /// - Parameters:
    ///   - imageAboveText: set true to make image above title text, default is false, image on left of text.
    ///   - spacing: spacing between title text and image.
    func centerTextAndImage(imageAboveText: Bool = false, spacing: CGFloat) {
        if imageAboveText {
            // https://stackoverflow.com/questions/2451223/#7199529
            guard
                let imageSize = imageView?.image?.size,
                let text = titleLabel?.text,
                let font = titleLabel?.font else { return }

            let titleSize = text.size(withAttributes: [.font: font])

            let titleOffset = -(imageSize.height + spacing)
            titleEdgeInsets = UIEdgeInsets(top: 0.0, left: -imageSize.width, bottom: titleOffset, right: 0.0)

            let imageOffset = -(titleSize.height + spacing)
            imageEdgeInsets = UIEdgeInsets(top: imageOffset, left: 0.0, bottom: 0.0, right: -titleSize.width)

            let edgeOffset = abs(titleSize.height - imageSize.height) / 2.0
            contentEdgeInsets = UIEdgeInsets(top: edgeOffset, left: 0.0, bottom: edgeOffset, right: 0.0)
        } else {
            let insetAmount = spacing / 2
            imageEdgeInsets = UIEdgeInsets(top: 0, left: -insetAmount, bottom: 0, right: insetAmount)
            titleEdgeInsets = UIEdgeInsets(top: 0, left: insetAmount, bottom: 0, right: -insetAmount)
            contentEdgeInsets = UIEdgeInsets(top: 0, left: insetAmount, bottom: 0, right: insetAmount)
        }
    }

    /// Set background color for specified state.
    /// - Parameters:
    ///   - color: The color of the image that will be set as background for the button in the given state.
    ///   - forState: set the UIControl.State for the desired color.
    func setBackgroundColor(color: UIColor, forState: UIControl.State) {
        clipsToBounds = true  // maintain corner radius
        
        let colorImage = UIGraphicsImageRenderer(size: CGSize(width: 1, height: 1)).image { context in
            color.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
//            draw(.zero)
        }
        setBackgroundImage(colorImage, for: forState)
    }
}

public extension UIView {
    enum PlacePosition {
        case left, right, top, bottom
        
        public var isHorizontal: Bool {
            switch self {
            case .left, .right: return true
            case .top, .bottom: return false
            }
        }
    }
    
    func at_sizesInfo(for view1: UIView?, view2: UIView?, view1Position pos: PlacePosition, spacing: CGFloat) -> (size1: CGSize, size2: CGSize, wrapSize: CGSize, margin: CGFloat) {
        let size1 = (view1?.intrinsicContentSize).filter(\.isValid) ?? .zero
        let size2 = (view2?.intrinsicContentSize).filter(\.isValid) ?? .zero
        var size: CGSize = .zero
        let margin: CGFloat
        if pos.isHorizontal {
            let w1 = size1.width
            let w2 = size2.width
            margin = (w1 > 0 && w2 > 0) ? spacing : 0
            size.width = w1 + w2 + margin
            size.height = max(size1.height, size2.height)
        } else {
            let h1 = size1.height
            let h2 = size2.height
            margin = (h1 > 0 && h2 > 0) ? spacing : 0
            size.height = h1 + h2 + margin
            size.width = max(size1.width, size2.width)
        }
        return (size1, size2, size, margin)
    }
    
    func at_layout(for view1: UIView?, view2: UIView?, view1Position pos: PlacePosition, spacing: CGFloat, contentEdgeInsets inset: UIEdgeInsets = .zero, verticalAlignment: UIControl.ContentVerticalAlignment = .center, horizontalAlignment: UIControl.ContentHorizontalAlignment = .center) {
        let rect = bounds
        guard !rect.isEmpty else { return }
        var (size1, size2, contentSize, margin) = at_sizesInfo(for: view1, view2: view2, view1Position: pos, spacing: spacing)
        
        let spaceW = rect.width - inset.left - inset.right
        guard spaceW > 0 else { return }
        
        let view1MaxW: CGFloat, view2MaxW: CGFloat
        if pos.isHorizontal {
            let isView1Higher: Bool
            if size1.isValid, size2.isValid, let v1 = view1, let v2 = view2 {
                let c1 = v1.contentCompressionResistancePriority(for: .horizontal)
                let c2 = v2.contentCompressionResistancePriority(for: .horizontal)
                if c1 == c2 {
                    switch (v1 is UILabel, v2 is UILabel) {
                    case (true, false): isView1Higher = false
                    default: isView1Higher = true
                    }
                } else {
                    isView1Higher = c1 > c2
                }
            } else { isView1Higher = true }
            if isView1Higher {
                view1MaxW = spaceW - margin
                view2MaxW = view1MaxW - size1.width
            } else {
                view2MaxW = spaceW - margin
                view1MaxW = view2MaxW - size2.width
            }
        } else {
            view1MaxW = spaceW
            view2MaxW = spaceW
        }
        var needRefresh = false
        if size1.isValid, view1MaxW > 0, size1.width > view1MaxW,
           let label = view1 as? UILabel,
           label.numberOfLines != 1,
           Int(label.preferredMaxLayoutWidth) != Int(view1MaxW) {
            label.preferredMaxLayoutWidth = view1MaxW
            needRefresh = true
        }
        if size2.isValid, view2MaxW > 0, size2.width > view2MaxW,
           let label = view2 as? UILabel,
           label.numberOfLines != 1,
           Int(label.preferredMaxLayoutWidth) != Int(view2MaxW) {
            label.preferredMaxLayoutWidth = view2MaxW
            needRefresh = true
        }
        if needRefresh {
            invalidateIntrinsicContentSize()
            setNeedsLayout()
            return
        }
        if view1MaxW > 0, size1.width > view1MaxW { size1.width = view1MaxW }
        if view2MaxW > 0, size2.width > view2MaxW { size2.width = view2MaxW }
        
        view1?.frame.size = size1
        view2?.frame.size = size2
        let center = rect.center
        if pos.isHorizontal {
            contentSize.width = size1.width + size2.width + margin
            switch verticalAlignment {
            case .top:
                view1?.frame.origin.y = inset.top
                view2?.frame.origin.y = inset.top
            case .bottom:
                let bottom = rect.height - inset.bottom
                view1?.frame.origin.y = bottom - size1.height
                view2?.frame.origin.y = bottom - size2.height
            default:
                view1?.center.y = center.y
                view2?.center.y = center.y
            }
            if case .fill = horizontalAlignment {
                if pos == .left {
                    view1?.frame.origin.x = inset.left
                    view2?.frame.origin.x = rect.width - size2.width - inset.right
                } else {
                    view2?.frame.origin.x = inset.left
                    view1?.frame.origin.x = rect.width - size1.width - inset.right
                }
            } else {
                let x = { () -> CGFloat in
                    let delta = rect.width - contentSize.width
                    switch horizontalAlignment {
                    case .left, .leading: return inset.left
                    case .right, .trailing: return delta - inset.right
                    default: return max(delta * 0.5, inset.left)
                    }
                }()
                if pos == .left {
                    view1?.frame.origin.x = x
                    view2?.frame.origin.x = x + size1.width + margin
                } else {
                    view2?.frame.origin.x = x
                    view1?.frame.origin.x = x + size2.width + margin
                }
            }
        } else {
            switch horizontalAlignment {
            case .left, .leading:
                view1?.frame.origin.x = inset.left
                view2?.frame.origin.x = inset.left
            case .right, .trailing:
                let right = rect.width - inset.right
                view1?.frame.origin.x = right - size1.width
                view2?.frame.origin.x = right - size2.width
            default:
                view1?.center.x = center.x
                view2?.center.x = center.x
            }
            if case .fill = verticalAlignment {
                if pos == .top {
                    view1?.frame.origin.y = inset.top
                    view2?.frame.origin.y = rect.height - size2.height - inset.bottom
                } else {
                    view2?.frame.origin.y = inset.top
                    view1?.frame.origin.y = rect.height - size1.height - inset.bottom
                }
            } else {
                let y = { () -> CGFloat in
                    let delta = rect.height - contentSize.height
                    switch verticalAlignment {
                    case .top: return inset.top
                    case .bottom: return delta - inset.bottom
                    default: return max(delta * 0.5, inset.top)
                    }
                }()
                if pos == .top {
                    view1?.frame.origin.y = y
                    view2?.frame.origin.y = y + size1.height + margin
                } else {
                    view2?.frame.origin.y = y
                    view1?.frame.origin.y = y + size2.height + margin
                }
            }
        }
    }
}

public final class ToupleView<V1: UIView, V2: UIView>: UIView {
    public var view1Position: UIView.PlacePosition = .left
    public var verticalAlignment: UIControl.ContentVerticalAlignment = .center
    public var horizontalAlignment: UIControl.ContentHorizontalAlignment = .center
    public var edgeInsets: UIEdgeInsets = .zero
    public var spacing: CGFloat = 0
    
    public init(v1: V1, v2: V2, frame: CGRect) {
        super.init(frame: frame)
        addSubview(v1)
        addSubview(v2)
        view1 = v1
        view2 = v2
    }
    public convenience init(config1: (V1) -> Void, config2: (V2) -> Void) {
        self.init(v1: V1().then(config1), v2: V2().then(config2), frame: .zero)
    }
    public convenience init(v1: V1) {
        self.init(v1: v1, v2: .init(), frame: .zero)
    }
    public convenience init(v2: V2) {
        self.init(v1: .init(), v2: v2, frame: .zero)
    }
    public convenience init(v1: V1, v2: V2) {
        self.init(v1: v1, v2: v2, frame: .zero)
    }
    public override convenience init(frame: CGRect) {
        self.init(v1: .init(), v2: .init(), frame: frame)
    }
    public convenience init() {
        self.init(v1: .init(), v2: .init(), frame: .zero)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override var intrinsicContentSize: CGSize {
        let size = at_sizesInfo(for: view1, view2: view2, view1Position: view1Position, spacing: spacing).wrapSize
        return size.inset(edgeInsets)
    }
    public override func layoutSubviews() {
        super.layoutSubviews()
        at_layout(for: view1, view2: view2, view1Position: view1Position, spacing: spacing, contentEdgeInsets: edgeInsets, verticalAlignment: verticalAlignment, horizontalAlignment: horizontalAlignment)
    }
    
    public private(set) unowned var view1: V1!
    public private(set) unowned var view2: V2!
}
public typealias ATImageLabel = ToupleView<UIImageView, UILabel>
public typealias ATLabelImage = ToupleView<UILabel, UIImageView>
public typealias ATDupleView<V: UIView> = ToupleView<V, V>
public typealias ATLabels = ATDupleView<UILabel>


open class NewButton: UIButton {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    open func setup() { }
    
    public var imagePosition: UIView.PlacePosition = .left
    public var spacing: CGFloat = 0
    
    @available(*, unavailable)
    open override var titleEdgeInsets: UIEdgeInsets {
        get { .zero }
        set { }
    }
    @available(*, unavailable)
    open override var imageEdgeInsets: UIEdgeInsets {
        get { .zero }
        set { }
    }
    
    open override var intrinsicContentSize: CGSize {
        let size = at_sizesInfo(for: imageView, view2: titleLabel, view1Position: imagePosition, spacing: spacing).wrapSize
        return size.inset(contentEdgeInsets)
    }
    open override func layoutSubviews() {
        super.layoutSubviews()
        at_layout(for: imageView, view2: titleLabel, view1Position: imagePosition, spacing: spacing, contentEdgeInsets: contentEdgeInsets, verticalAlignment: contentVerticalAlignment, horizontalAlignment: contentHorizontalAlignment)
    }
}
