//
//  UIButton+Add.swift
//  SwifterKnife
//
//  Created by liyang on 2021/10/19.
//

import UIKit

public extension UIButton {
    
    struct TouchPosition: OptionSet {
        public let rawValue: Int
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
        public static var left: TouchPosition { .init(rawValue: 1 << 0) }
        public static var right: TouchPosition { .init(rawValue: 1 << 1) }
        public static var top: TouchPosition { .init(rawValue: 1 << 2) }
        public static var bottom: TouchPosition { .init(rawValue: 1 << 3) }
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
        
        let p = touch.location(in: self)
        let size = bounds.size
        
        var res: TouchPosition = []
        
        if p.x > size.width * 0.5 {
            res.formUnion(.right)
        } else { res.formUnion(.left) }
        
        if p.y > size.height * 0.5 {
            res.formUnion(.bottom)
        } else { res.formUnion(.top) }
        
        return res
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
}
