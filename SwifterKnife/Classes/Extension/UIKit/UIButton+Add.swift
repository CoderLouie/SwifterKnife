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

public extension UIButton {
    
    func addTouchUpInside(_ target: Any?, _ action: Selector) {
        addTarget(target, action: action, for: .touchUpInside)
    }
    
    /*
     Example
     btn.addTarget(self, action: #selector(onButtonClicked(_:_:)), for: .touchUpInside)
     
     @objc func onButtonClicked(_ sender: UIButton, _ event: UIEvent) {
        let pos = sender.touchPosition(with: event)
        if res.contains(.right) {
            xxx
        } else {
            xxx
        }
     }
     */
    func touchPosition(with event: UIEvent) -> TouchPosition {
        guard let touch = event.allTouches?.randomElement() else { return [] }
        return touch.touchPosition
    }
    
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
        
        if #available(iOS 10.0, tvOS 10.0, *) {
            let colorImage = UIGraphicsImageRenderer(size: CGSize(width: 1, height: 1)).image { context in
                color.setFill()
                context.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
                draw(.zero)
            }
            setBackgroundImage(colorImage, for: forState)
            return
        }
        
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        if let context = UIGraphicsGetCurrentContext() {
            context.setFillColor(color.cgColor)
            context.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
            let colorImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            setBackgroundImage(colorImage, for: forState)
        }
    }
}
