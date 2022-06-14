//
//  Button.swift
//  SwifterKnife
//
//  Created by liyang on 2022/6/1. 
//

import UIKit
 
extension UIControl.State: Hashable {
    public static var loading: UIControl.State {
        let disableFlag = UIControl.State.disabled.rawValue
        return .init(rawValue: (1 << 16) | disableFlag)
    }
}
/**
 标题在左
 spinner, image, title
 
 标题在右
 title, image, spinner
 
 标题在上
 title
 image
 spinner
 
 标题在下
 spinner
 image
 title
 */
public class Button: UIControl {
    
    /// 标题位置
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
    public enum RoundedDirection {
        case horizontal
        case vertical
    }
    public var roundedDirection: RoundedDirection? = nil {
        didSet {
            if roundedDirection == nil {
                layer.cornerRadius = 0
            }
        }
    }
    /// 文字 和 ImageView 的距离
    public var titleAndImageSpace: CGFloat = 0
    /// 图片 和 ActivityIndicatorView 的距离
    public var imageAndSpinnerSpace: CGFloat = 0
    /// 标题位置
    public var titleLayout: TitlePosition = .right
    
    public var adjustsImageWhenHighlighted = true // default is YES. if YES, image is drawn darker when highlighted(pressed)

    public var adjustsImageWhenDisabled = true // default is YES. if YES, image is drawn lighter when disabled
    
    public var contentEdgeInsets: UIEdgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
    
    /// 配置自身属性，比如背景颜色
    public func config(forState state: UIControl.State, config: @escaping (Button) -> Void) {
        setConfigClosure(config, type: .me, forState: state)
    }
    public func configGradientLayer(forState state: UIControl.State, config: @escaping (CAGradientLayer) -> Void) {
        setConfigClosure(config, type: .gradientLayer, forState: state)
    }
    public func configLabel(forState state: UIControl.State, config: @escaping (UILabel) -> Void) {
        setConfigClosure(config, type: .label, forState: state)
    }
    public func configImageView(forState state: UIControl.State, config: @escaping (UIImageView) -> Void) {
        setConfigClosure(config, type: .image, forState: state)
    }
    public func configBackgroundImageView(forState state: UIControl.State, config: @escaping (UIImageView) -> Void) {
        setConfigClosure(config, type: .backgroundImage, forState: state)
    }
    public func configSpinnerView(forState state: UIControl.State, config: @escaping (UIActivityIndicatorView) -> Void) {
        setConfigClosure(config, type: .spinner, forState: state)
    }
    public var isLoading: Bool = false {
        didSet {
            guard isLoading != oldValue else { return }
            super.isEnabled = !isLoading
            if isLoading {
                spinnerView.startAnimating()
            } else {
                _spinnerView?.stopAnimating()
            }
            makeNeedUpdateConstraintsAndLayout()
        }
    }
    
    public override var isEnabled: Bool {
        get { super.isEnabled }
        set {
            let oldValue = super.isEnabled
            let newValue = !isLoading && newValue
            guard newValue != oldValue else { return }
            super.isEnabled = newValue
            makeNeedUpdateConstraintsAndLayout()
        }
    }
    public override var isHighlighted: Bool {
        get { super.isHighlighted }
        set {
            guard newValue != super.isHighlighted else { return }
            super.isHighlighted = newValue
            makeNeedUpdateConstraintsAndLayout()
        }
    }
    public override var isSelected: Bool {
        get { super.isSelected }
        set {
            guard newValue != super.isSelected else { return }
            super.isSelected = newValue
            makeNeedUpdateConstraintsAndLayout()
        }
    }
    public override var state: UIControl.State {
        var value = super.state
        if isLoading { value.formUnion(.loading) }
        return value
    }
    
    private func makeNeedUpdateConstraintsAndLayout() {
        setNeedsLayout()
        invalidateIntrinsicContentSize()
    }
    
    private var _spinnerView: UIActivityIndicatorView?
    private var spinnerView: UIActivityIndicatorView {
        if let view = _spinnerView { return view }
        let view = UIActivityIndicatorView()
        view.style = .white
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
        view.textColor = .black
        view.font = UIFont.systemFont(ofSize: 15)
        view.baselineAdjustment = .alignCenters
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
    private var _state: UInt = .max
    private var _contentSize: CGSize = .zero
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
        let size = contentSize
        let inset = contentEdgeInsets
        return CGSize(width: size.width + inset.left + inset.right, height: size.height + inset.top + inset.bottom)
    }
    public override func sizeThatFits(_ size: CGSize) -> CGSize {
        intrinsicContentSize
    }
    public override func layoutSubviews() {
        super.layoutSubviews()
        updateContent()
        let bounds = self.bounds
        if let dir = roundedDirection {
            layer.masksToBounds = true
            switch dir {
            case .horizontal:
                layer.cornerRadius = bounds.width * 0.5
            case .vertical:
                layer.cornerRadius = bounds.height * 0.5
            }
        }
        let inset = contentEdgeInsets
        let newBounds = bounds.inset(by: inset)
        let contentViewX: CGFloat
        let contentViewY: CGFloat
        
        switch contentVerticalAlignment {
        case .center, .fill:
            contentViewY = newBounds.midY - _contentSize.height * 0.5
        case .top:
            contentViewY = newBounds.minY
        case .bottom:
            contentViewY = newBounds.maxY - _contentSize.height
        @unknown default:
            contentViewY = newBounds.midY - _contentSize.height * 0.5
        }
        
        switch contentHorizontalAlignment {
        case .center, .fill:
            contentViewX = newBounds.midX - _contentSize.width * 0.5
        case .leading, .left:
            contentViewX = newBounds.minX
        case .trailing, .right:
            contentViewX = newBounds.maxX - _contentSize.width
        @unknown default:
            contentViewX = newBounds.midX - _contentSize.width * 0.5
        }
        contentView.frame.origin = CGPoint(x: contentViewX, y: contentViewY)
        
        _bgImageView?.frame = bounds
        aroundLayer {
            _gradientLayer?.frame = bounds
        }
    }
}

fileprivate func ceil(_ size: CGSize) -> CGSize {
    CGSize(width: ceil(size.width), height: ceil(size.height))
}

private extension Button {
    var contentSize: CGSize {
        updateContent()
        return _contentSize
    }
     
    private func aroundLayer(_ work: () -> Void) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        work()
        CATransaction.commit()
    }
    func updateContent() {
        let state = self.state
        guard _state != state.rawValue else {
//            print("state 未发生变化 ", self.frame)
            return
        }
//        print("state 发生变化 ", self.frame)
        _state = state.rawValue
        
        let config = { (type: ConfigType) -> Any? in
            if let t = self.configs[state]?[type] { return t }
            if state == [.selected, .highlighted],
               let t = self.configs[.selected]?[type] { return t }
            if state == .loading,
               let t = self.configs[.disabled]?[type] { return t }
            return self.configs[.normal]?[type]
        }
         
        if let closure = config(.me) as? ((Button) -> Void) {
            closure(self)
        }
        if let closure = config(.gradientLayer) as? ((CAGradientLayer) -> Void) {
            aroundLayer {
                gradientLayer.isHidden = false
                closure(gradientLayer)
            }
        } else { _gradientLayer?.isHidden = true }
        
        if let closure = config(.backgroundImage) as? ((UIImageView) -> Void) {
            bgImageView.isHidden = false
            bgImageView.grayLevel = .none
            closure(bgImageView)
            if adjustsImageWhenHighlighted,
               state.contains(.highlighted) {
                bgImageView.grayLevel = .dark
            }
            if adjustsImageWhenDisabled,
               state.contains(.disabled) {
                bgImageView.grayLevel = .light
            }
        } else { _bgImageView?.isHidden = true }
        
        var needLayoutViews: [(UIView, CGFloat)?] = [nil, nil, nil]
        let layoutAtStart = titleLayout.atStart
        
        if let closure = config(.label) as? ((UILabel) -> Void) {
            label.isHidden = false
            label.frame.size = .zero
            closure(label)
            if label.isHidden ||
                (label.text?.isEmpty ?? true) ||
                (label.attributedText?.string.isEmpty ?? true) {
                label.isHidden = true
            } else {
                label.isHidden = false
                var size = label.frame.size
                if size.width == 0 || size.height == 0 {
                    size = label.intrinsicContentSize
                    let maxW = label.preferredMaxLayoutWidth
                    if label.adjustsFontSizeToFitWidth,
                       maxW > 0,
                       label.numberOfLines == 1,
                       size.width > maxW {
                        size.width = label.preferredMaxLayoutWidth
                    }
                    label.frame.size = ceil(size)
                }
                
                if layoutAtStart {
                    needLayoutViews[0] = (label, titleAndImageSpace)
                } else {
                    needLayoutViews[2] = (label, 0)
                }
            }
        } else { _label?.isHidden = true }
        
        if let closure = config(.image) as? ((UIImageView) -> Void) {
            imageView.grayLevel = .none
            imageView.isHidden = false
            imageView.frame.size = .zero
            closure(imageView)
            if !imageView.isHidden, imageView.image != nil {
                if adjustsImageWhenHighlighted,
                   state.contains(.highlighted) {
                    imageView.grayLevel = .dark
                }
                if adjustsImageWhenDisabled,
                   state.contains(.disabled) {
                    imageView.grayLevel = .light
                }
                
                imageView.isHidden = false
                let size = imageView.frame.size
                if size.width == 0 || size.height == 0 {
                    imageView.sizeToFit()
                }
                needLayoutViews[1] = (imageView, layoutAtStart ? imageAndSpinnerSpace : titleAndImageSpace)
            } else { imageView.isHidden = true }
        } else { _imageView?.isHidden = true }
        
        if state == .loading {
            var needConfigSpinner = _spinnerView?.isAnimating ?? false
            if let closure = configs[state]?[.spinner] as? ((UIActivityIndicatorView) -> Void) {
                spinnerView.isHidden = false
                needConfigSpinner = true
                spinnerView.frame.size = .zero
                closure(spinnerView)
            }
            if needConfigSpinner {
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
            } else { _spinnerView?.isHidden = true }
        } else { _spinnerView?.isHidden = true }
        
        var height: CGFloat = 0, width: CGFloat = 0
        let isHorizontalLayout = titleLayout.isHorizontal
        var prevSpace: CGFloat = 0
        for item in needLayoutViews {
            guard let item = item else {
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
        if isHorizontalLayout { width -= prevSpace }
        else { height -= prevSpace }
        
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
        contentView.frame.size = contentSize
        
        _contentSize = contentSize
    }
}
