//
//  Button.swift
//  SwifterKnife_Example
//
//  Created by 李阳 on 2022/6/1.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit

extension UIControl.State: Hashable {
    public static var loading: UIControl.State {
        let disableFlag = UIControl.State.disabled.rawValue
        return .init(rawValue: (1 << 16) | disableFlag)
    }
}

public class Button: UIControl {
    /// 标题位置 (同时有标题和图片的时候生效)
    public enum TitlePosition {
        /// 标题在左
        case left
        /// 标题在右
        case right
        /// 标题在上
        case top
        /// 标题在下
        case bottom
        
        fileprivate var isHorizontal: Bool {
            return self == .left || self == .right
        }
        fileprivate var atStart: Bool {
            return self == .left || self == .top
        }
    }
    
    /// 文字 和 ImageView 的距离
    public var titleAndImageSpace: CGFloat = 0
    /// 图片 和 ActivityIndicatorView 的距离
    public var imageAndSpinnerSpace: CGFloat = 0
    /// 标题位置
    public var titleLayout: TitlePosition = .right
    
    
    /// 配置自身属性，比如背景颜色
    func configSelf(forState state: UIControl.State, config: @escaping (UIView) -> Void) {
        setConfigClosure(config, type: .me, forState: state)
    }
    func configGradientLayer(forState state: UIControl.State, config: @escaping (CAGradientLayer) -> Void) {
        setConfigClosure(config, type: .gradientLayer, forState: state)
    }
    func configLabel(forState state: UIControl.State, config: @escaping (UILabel) -> Void) {
        setConfigClosure(config, type: .label, forState: state)
    }
    func configImageView(forState state: UIControl.State, config: @escaping (UIImageView) -> Void) {
        setConfigClosure(config, type: .image, forState: state)
    }
    func configBackgroundImageView(forState state: UIControl.State, config: @escaping (UIImageView) -> Void) {
        setConfigClosure(config, type: .backgroundImage, forState: state)
    }
    func configSpinnerView(forState state: UIControl.State, config: @escaping (UIActivityIndicatorView) -> Void) {
        setConfigClosure(config, type: .spinner, forState: state)
    }
    var isLoading: Bool = false {
        didSet {
            guard isLoading != oldValue else { return }
            super.isEnabled = !isLoading
            if isLoading {
                spinnerView.startAnimating()
            } else {
                _spinnerView?.stopAnimating()
            }
            setNeedsLayout()
            invalidateIntrinsicContentSize()
        }
    }
    
    public override var isEnabled: Bool {
        get { super.isEnabled }
        set { super.isEnabled = !isLoading && newValue }
    }
    public override var state: UIControl.State {
        var value = super.state
        if isLoading { value.formUnion(.loading) }
        return value
    }
    
    private var _spinnerView: UIActivityIndicatorView?
    private var spinnerView: UIActivityIndicatorView {
        if let view = _spinnerView { return view }
        let view = UIActivityIndicatorView()
        contentView.addSubview(view)
        _spinnerView = view
        return view
    }
    private var _imageView: UIImageView?
    private var imageView: UIImageView {
        if let view = _imageView { return view }
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        contentView.addSubview(view)
        _imageView = view
        return view
    }
    private var _label: UILabel?
    private var label: UILabel {
        if let view = _label { return view }
        let view = UILabel()
        contentView.addSubview(view)
        _label = view
        return view
    }
    private var _bgImageView: UIImageView?
    private var bgImageView: UIImageView {
        if let view = _bgImageView { return view }
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        self.addSubview(view)
        _bgImageView = view
        return view
    }
    private var _gradientLayer: CAGradientLayer?
    private var gradientLayer: CAGradientLayer {
        if let layer = _gradientLayer {  return layer }
        let layer = CAGradientLayer()
        self.layer.insertSublayer(layer, at: 0)
        _gradientLayer = layer
        return layer
    }
    /// 仅做布局使用
    private lazy var contentView: VirtualView = VirtualView().then {
        $0.isUserInteractionEnabled = false
        self.addSubview($0)
    }
     
    private func setConfigClosure(_ closure: Any, type: ConfigType, forState state: UIControl.State) {
        if var config = configs[state] {
            config[type] = closure
            configs[state] = config
            return
        }
        configs[state] = [type: closure]
    }
    private var _contentSize: CGSize = CGSize(width: UIView.noIntrinsicMetric, height: UIView.noIntrinsicMetric)
    private var configs: [UIControl.State: [ConfigType: Any]] = [:]
    private enum ConfigType {
        case me
        case backgroundImage
        case image
        case label
        case gradientLayer
        case spinner
    }
    
    public override var intrinsicContentSize: CGSize {
        _contentSize
    }
    public override func layoutSubviews() {
        super.layoutSubviews()
        updateContent()
        let bounds = self.bounds
        contentView.center = bounds.center
    }
}
 

fileprivate extension CGSize {
    var _ceil: CGSize {
        return CGSize(width: ceil(width), height: ceil(height))
    }
}

private extension Button {
    func updateContent() -> CGSize {
        let state = self.state
        guard let config = configs[state] ?? configs[.normal] else { return _contentSize }
        if let closure = config[.me] as? ((UIView) -> Void) {
            closure(self)
        }
        if let closure = config[.gradientLayer] as? ((CAGradientLayer) -> Void) {
            closure(gradientLayer)
        }
        if let closure = config[.backgroundImage] as? ((UIImageView) -> Void) {
            closure(bgImageView)
        }
         
        var needLayoutViews: [(UIView, CGFloat)?] = [nil, nil, nil]
        let layoutAtStart = titleLayout.atStart
        
        if let closure = config[.label] as? ((UILabel) -> Void) {
            closure(label)
            if !label.isHidden,
               (!(label.text?.isEmpty ?? true) ||
                !(label.attributedText?.string.isEmpty ?? true)) {
                label.isHidden = false
                var size = label.frame.size
                if size.width == 0 || size.height == 0 {
                    label.sizeToFit()
                    size = label.frame.size._ceil
                    label.frame.size = size
                }
                if layoutAtStart {
                    needLayoutViews[0] = (label, titleAndImageSpace)
                } else {
                    needLayoutViews[2] = (label, 0)
                }
            } else { label.isHidden = true }
        }
        if let closure = config[.image] as? ((UIImageView) -> Void) {
            closure(imageView)
            if !imageView.isHidden, imageView.image != nil {
                imageView.isHidden = false
                let size = imageView.frame.size
                if size.width == 0 || size.height == 0 {
                    imageView.sizeToFit()
                }
                needLayoutViews[1] = (imageView, layoutAtStart ? imageAndSpinnerSpace : titleAndImageSpace)
            } else { imageView.isHidden = true }
        }
        if let closure = config[.spinner] as? ((UIActivityIndicatorView) -> Void) {
            closure(spinnerView)
            if !spinnerView.isHidden {
                let size = spinnerView.frame.size
                if size.width == 0 || size.height == 0 {
                    spinnerView.sizeToFit()
                }
                if layoutAtStart {
                    needLayoutViews[2] = (spinnerView, 0)
                } else {
                    needLayoutViews[0] = (spinnerView, imageAndSpinnerSpace)
                }
            }
        }
        var height: CGFloat = 0, width: CGFloat = 0
        let isHorizontalLayout = titleLayout.isHorizontal
        var prevSpace: CGFloat = 0
        for item in needLayoutViews {
            guard let item = item else {
                if isHorizontalLayout { width -= prevSpace }
                else { height -= prevSpace }
                prevSpace = 0
                continue
            }
            let view = item.0
            let size = view.frame.size
            prevSpace = item.1
            if isHorizontalLayout {
                height = max(height, size.height)
                view.frame.origin.x = width
                width += size.width + item.1
            } else {
                width = max(width, size.width)
                view.frame.origin.y = height
                height += size.height + item.1
            }
        }
        let halfH = height * 0.5
        let halfW = width * 0.5
        for item in needLayoutViews {
            guard let view = item?.0 else { continue }
            if isHorizontalLayout {
                view.center.y = halfH
            } else {
                view.center.x = halfW
            }
        }
        
        let contentSize = CGSize(width: width, height: height)
        contentView.bounds.size = contentSize
        
        _contentSize = contentSize
        return _contentSize
    }
}
