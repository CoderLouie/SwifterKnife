//
//  CGRect+Add.swift
//  SwifterKnife
//
//  Created by liyang on 2021/10/19.
//

import CoreGraphics

// MARK: - Properties
public extension CGRect {

    /// Return center of rect
    var center: CGPoint { CGPoint(x: midX, y: midY) }

}

// MARK: - Initializers
public extension CGRect {

    /// Create a `CGRect` instance with center and size
    /// - Parameters:
    ///   - center: center of the new rect
    ///   - size: size of the new rect
    init(center: CGPoint, size: CGSize) {
        let origin = CGPoint(x: center.x - size.width / 2.0, y: center.y - size.height / 2.0)
        self.init(origin: origin, size: size)
    }

}

// MARK: - Methods
public extension CGRect {

    /// Create a new `CGRect` by resizing with specified anchor
    /// - Parameters:
    ///   - size: new size to be applied
    ///   - anchor: specified anchor, a point in normalized coordinates -
    ///     '(0, 0)' is the top left corner of rect，'(1, 1)' is the bottom right corner of rect,
    ///     defaults to '(0.5, 0.5)'. excample:
    ///
    ///          anchor = CGPoint(x: 0.0, y: 1.0):
    ///
    ///                       A2------B2
    ///          A----B       |        |
    ///          |    |  -->  |        |
    ///          C----D       C-------D2
    ///
    func resizing(to size: CGSize, anchor: CGPoint = CGPoint(x: 0.5, y: 0.5)) -> CGRect {
        let sizeDelta = CGSize(width: size.width - width, height: size.height - height)
        return CGRect(origin: CGPoint(
                        x: minX - sizeDelta.width * anchor.x,
                        y: minY - sizeDelta.height * anchor.y),
                      size: size)
    }

}


public extension CGRect {
    var rightBottom: CGPoint {
        CGPoint(x: maxX, y: maxY)
    }
    var rightTop: CGPoint {
        CGPoint(x: maxX, y: minY)
    }
    var leftBottom: CGPoint {
        CGPoint(x: minX, y: maxY)
    }
}

public extension CGRect {
    func resizing(to size: CGSize, model: UIView.ContentMode) -> CGRect {
        var rect = standardized
        var size = size.standardized
        let center = rect.center
        
        switch model {
        case .scaleAspectFit, .scaleAspectFill:
            if rect.width < 0.01 || rect.height < 0.01 ||
                size.width < 0.01 || size.height < 0.01 {
                rect.origin = center
                rect.size = .zero
            } else {
                let scale: CGFloat
                if model == .scaleAspectFit {
                    if size.width / size.height <
                        rect.width / rect.height {
                        scale = rect.height / size.height
                    } else {
                        scale = rect.width / size.width
                    }
                } else {
                    if size.width / size.height <
                        rect.width / rect.height {
                        scale = rect.width / size.width
                    } else {
                        scale = rect.height / size.height
                    }
                }
                size *= scale
                rect.size = size
                rect.origin = CGPoint(x: center.x - size.width * 0.5, y: center.y - size.height * 0.5)
            }
        case .center:
            rect.size = size
            rect.origin = CGPoint(x: center.x - size.width * 0.5, y: center.y - size.height * 0.5)
        case .top:
            rect.origin.x = center.x - size.width * 0.5
            rect.size = size
        case .bottom:
            rect.origin.x = center.x - size.width * 0.5
            rect.origin.y += rect.size.height - size.height
            rect.size = size
        case .left:
            rect.origin.y = center.y - size.height * 0.5
            rect.size = size
        case .right:
            rect.origin.y = center.y - size.height * 0.5
            rect.origin.x += rect.size.width - size.width
            rect.size = size
        case .topLeft:
            rect.size = size
        case .topRight:
            rect.origin.x += rect.size.width - size.width;
            rect.size = size;
        case .bottomLeft:
            rect.origin.y += rect.size.height - size.height
            rect.size = size
        case .bottomRight:
            rect.origin.x += rect.size.width - size.width
            rect.origin.y += rect.size.height - size.height
            rect.size = size
        default: break
        }
        
        return rect
    }
}
