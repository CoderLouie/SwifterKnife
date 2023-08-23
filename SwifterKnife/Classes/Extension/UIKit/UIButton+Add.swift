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

open class NewButton: UIButton {
    public enum ImagePosition {
        case left, right, top, bottom
    }
    public var imagePosition: ImagePosition = .left
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
    
    private var sizesInfo: (titleSize: CGSize, imgSize: CGSize, contentSize: CGSize, margin: CGFloat) {
        let labelSize = titleLabel?.intrinsicContentSize
        let imgSize = imageView?.intrinsicContentSize
        let size1 = labelSize.filter(\.valid) ?? .zero
        let size2 = imgSize.filter(\.valid) ?? .zero
        var size: CGSize = .zero
        let margin: CGFloat
        switch imagePosition {
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
    open override var intrinsicContentSize: CGSize {
        let size = sizesInfo.contentSize
        return size.inset(contentEdgeInsets)
    }
    open override func layoutSubviews() {
        super.layoutSubviews()
        let bounds = bounds
        guard !bounds.isEmpty else { return }
        let (titleSize, imgSize, contentSize, margin) = sizesInfo
        imageView?.frame.size = imgSize
        titleLabel?.frame.size = titleSize
        let center = bounds.center
        let inset = contentEdgeInsets
        switch imagePosition {
        case .left, .right:
            switch contentVerticalAlignment {
            case .top:
                imageView?.frame.origin.y = inset.top
                titleLabel?.frame.origin.y = inset.top
            case .bottom:
                let bottom = bounds.height - inset.bottom
                imageView?.frame.origin.y = bottom - imgSize.height
                titleLabel?.frame.origin.y = bottom - titleSize.height
            default:
                imageView?.center.y = center.y
                titleLabel?.center.y = center.y
            }
            
            let x = { () -> CGFloat in
                let delta = bounds.width - contentSize.width
                switch contentHorizontalAlignment {
                case .left, .leading: return inset.left
                case .right, .trailing: return delta - inset.right
                default: return delta * 0.5
                }
            }()
            if imagePosition == .left {
                imageView?.frame.origin.x = x
                titleLabel?.frame.origin.x = x + imgSize.width + margin
            } else {
                titleLabel?.frame.origin.x = x
                imageView?.frame.origin.x = x + titleSize.width + margin
            }
        case .top, .bottom:
            switch contentHorizontalAlignment {
            case .left, .leading:
                imageView?.frame.origin.x = inset.left
                titleLabel?.frame.origin.x = inset.left
            case .right, .trailing:
                let right = bounds.width - inset.right
                imageView?.frame.origin.x = right - imgSize.width
                titleLabel?.frame.origin.x = right - titleSize.width
            default:
                imageView?.center.x = center.x
                titleLabel?.center.x = center.x
            }
            let y = { () -> CGFloat in
                let delta = (bounds.height - contentSize.height)
                switch contentVerticalAlignment {
                case .top: return inset.top
                case .bottom: return delta - inset.bottom
                default: return delta * 0.5
                }
            }()
            if imagePosition == .top {
                imageView?.frame.origin.y = y
                titleLabel?.frame.origin.y = y + imgSize.height + margin
            } else {
                titleLabel?.frame.origin.y = y
                imageView?.frame.origin.y = y + imgSize.height + margin
            }
        }
    }
}
