//
//  AspectImageView.swift
//  SwifterKnife
//
//  Created by liyang on 2022/8/23.
//

import UIKit

fileprivate extension CGRect {
    var pixelate: CGRect {
        CGRect(x: origin.x.pixFloor, y: origin.y.pixFloor, width: size.width.pixCeil, height: size.height.pixCeil)
    }
}

open class AspectFitView: UIView {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open var contentInset: UIEdgeInsets = .zero {
        didSet {
            guard oldValue != contentInset else { return }
            setNeedsLayout()
        }
    }
    public var image: UIImage? {
        get { imgView.image }
        set {
            imgView.image = newValue
            setNeedsLayout()
        }
    }
    open func setup() {
        imgView = UIImageView().then {
            $0.contentMode = .scaleAspectFit
            addSubview($0)
        }
    }
    open var imageContentModel: UIView.ContentMode = .top
    open override func layoutSubviews() {
        super.layoutSubviews()
        let bounds = bounds
        let inset = contentInset
        let rect = bounds.inset(by: inset)
        guard let ratio = imgView.image?.size.whRatio else { return }
        let size: CGSize
        if ratio < 1 {
            size = CGSize(width: rect.height * ratio, height: rect.height)
        } else {
            size = CGSize(width: rect.width, height: rect.width / ratio)
        }
        imgView.contentMode = .scaleAspectFit
        var frame = rect.resizing(to: size, model: .scaleAspectFit).pixelate
        switch imageContentModel {
        case .top:
            frame.origin.y = inset.top
        case .left:
            frame.origin.x = inset.left
        case .right:
            frame.origin.x = rect.maxX - frame.size.width
        case .bottom:
            frame.origin.y = rect.maxY - frame.size.height
        default: break
        }
        imgView.frame = frame
    }
    private(set) public unowned var imgView: UIImageView!
}
