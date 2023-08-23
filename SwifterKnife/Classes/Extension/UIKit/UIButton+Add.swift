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
    }
    
    static func sizesInfo<V1: UIView, V2: UIView>(for view1: V1?, view2: V2?, view1Position pos: PlacePosition, spacing: CGFloat) -> (size1: CGSize, size2: CGSize, wrapSize: CGSize, margin: CGFloat) {
        let size1 = (view1?.intrinsicContentSize).filter(\.valid) ?? .zero
        let size2 = (view2?.intrinsicContentSize).filter(\.valid) ?? .zero
        var size: CGSize = .zero
        let margin: CGFloat
        switch pos {
        case .left, .right:
            let w1 = size1.width
            let w2 = size2.width
            margin = (w1 > 0 && w2 > 0) ? spacing : 0
            size.width = w1 + w2 + margin
            size.height = max(size1.height, size2.height)
        case .top, .bottom:
            let h1 = size1.height
            let h2 = size2.height
            margin = (h1 > 0 && h2 > 0) ? spacing : 0
            size.height = h1 + h2 + margin
            size.width = max(size1.width, size2.width)
        }
        return (size1, size2, size, margin)
    }
    
    static func layout<V1: UIView, V2: UIView>(in rect: CGRect, for view1: V1?, view2: V2?, view1Position pos: PlacePosition, spacing: CGFloat, contentEdgeInsets inset: UIEdgeInsets, verticalAlignment: UIControl.ContentVerticalAlignment, horizontalAlignment: UIControl.ContentHorizontalAlignment) {
        guard !rect.isEmpty else { return }
        let (size1, size2, contentSize, margin) = sizesInfo(for: view1, view2: view2, view1Position: pos, spacing: spacing)
        view1?.frame.size = size1
        view2?.frame.size = size2
        let center = rect.center 
        switch pos {
        case .left, .right:
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
            
            let x = { () -> CGFloat in
                let delta = rect.width - contentSize.width
                switch horizontalAlignment {
                case .left, .leading: return inset.left
                case .right, .trailing: return delta - inset.right
                default: return delta * 0.5
                }
            }()
            if pos == .left {
                view1?.frame.origin.x = x
                view2?.frame.origin.x = x + size1.width + margin
            } else {
                view2?.frame.origin.x = x
                view1?.frame.origin.x = x + size2.width + margin
            }
        case .top, .bottom:
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
            let y = { () -> CGFloat in
                let delta = rect.height - contentSize.height
                switch verticalAlignment {
                case .top: return inset.top
                case .bottom: return delta - inset.bottom
                default: return delta * 0.5
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

open class NewButton: UIButton {
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
        let size = UIView.sizesInfo(for: imageView, view2: titleLabel, view1Position: imagePosition, spacing: spacing).wrapSize
        return size.inset(contentEdgeInsets)
    }
    open override func layoutSubviews() {
        super.layoutSubviews()
        let bounds = bounds
        guard !bounds.isEmpty else { return }
        UIView.layout(in: bounds, for: imageView, view2: titleLabel, view1Position: imagePosition, spacing: spacing, contentEdgeInsets: contentEdgeInsets, verticalAlignment: contentVerticalAlignment, horizontalAlignment: contentHorizontalAlignment)
    }
}
