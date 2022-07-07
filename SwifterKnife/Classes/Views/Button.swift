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
 title, image, spinner
 
 标题在右
 spinner, image, title
 
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
        appendConfigClosure(config, type: .me, forState: state)
        if stateValid(state) {
            config(self)
        }
    }
    public func configGradientLayer(forState state: UIControl.State, config: @escaping (CAGradientLayer) -> Void) {
        appendConfigClosure(config, type: .gradientLayer, forState: state)
        if stateValid(state), let layer = _gradientLayer {
            config(layer)
        }
    }
    public func configLabel(forState state: UIControl.State, config: @escaping (UILabel) -> Void) {
        appendConfigClosure(config, type: .label, forState: state)
        if stateValid(state), let view = _label {
            config(view)
            setNeedsLayout()
        }
    }
    public func configImageView(forState state: UIControl.State, config: @escaping (UIImageView) -> Void) {
        appendConfigClosure(config, type: .image, forState: state)
        if stateValid(state), let view = _imageView {
            config(view)
            setNeedsLayout()
        }
    }
    public func configBackgroundImageView(forState state: UIControl.State, config: @escaping (UIImageView) -> Void) {
        appendConfigClosure(config, type: .backgroundImage, forState: state)
        if stateValid(state), let view = _bgImageView {
            config(view)
        }
    }
    public func configSpinnerView(forState state: UIControl.State, config: @escaping (UIActivityIndicatorView) -> Void) {
        guard state == .loading else { return }
        appendConfigClosure(config, type: .spinner, forState: state)
        if _state == UIControl.State.loading.rawValue,
           let view = _spinnerView {
            config(view)
            setNeedsLayout()
        }
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
    /// 需要布局的子视图
    private var needLayoutViews: [(UIView, CGFloat)?] = []
    
    private func appendConfigClosure(_ closure: Any, type: ConfigType, forState state: UIControl.State) {
        if var config = configs[state] { 
            var closures = config[type, default: []]
            closures.append(closure)
            config[type] = closures
            configs[state] = config
            return
        }
        configs[state] = [type: [closure]]
    }
    private func stateValid(_ state: UIControl.State) -> Bool {
        if _state == state.rawValue { return true }
        if _state == UIControl.State([.selected, .highlighted]).rawValue,
            state == .selected { return true }
        if _state == UIControl.State.loading.rawValue,
            state == .disabled { return true }
        return false
    }
    private func configClosures(for type: ConfigType) -> [Any]? {
        if let res = self.configs[state]?[type] { return res }
        if state == [.selected, .highlighted],
           let res = self.configs[.selected]?[type] { return res }
        if state == .loading,
           let res = self.configs[.disabled]?[type] { return res }
        return self.configs[.normal]?[type]
    }
    private func configs<C>(_ type: ConfigType, as kind: C.Type = C.self) -> [C]? {
        configClosures(for: type) as? [C]
    }
    private var _state: UInt = .max
    private var _contentSize: CGSize = .zero
    private var configs: [UIControl.State: [ConfigType: [Any]]] = [:]
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
        let posX: CGFloat
        let posY: CGFloat
        switch contentVerticalAlignment {
        case .center, .fill:
            posY = 0.5
        case .top:
            posY = 0
        case .bottom:
            posY = 1
        @unknown default:
            posY = 0.5
        }
        
        switch contentHorizontalAlignment {
        case .center, .fill:
            posX = 0.5
        case .leading, .left:
            posX = 0
        case .trailing, .right:
            posX = 1
        @unknown default:
            posX = 0.5
        }
        contentView.frame.origin = CGPoint(x: (newBounds.width - _contentSize.width) * posX + newBounds.minX, y: (newBounds.height - _contentSize.height) * posY + newBounds.minY)
        
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
            return
        }
        _state = state.rawValue
        
        if let closures: [((Button) -> Void)] = configs(.me) {
            closures.forEach { $0(self) }
        }
        if let closures: [((CAGradientLayer) -> Void)] = configs(.gradientLayer) {
            config(.gradientLayer) {
                closures.forEach { $0(gradientLayer) }
            }
        } else { _gradientLayer?.isHidden = true }
        
        if let closures: [((UIImageView) -> Void)] = configs(.backgroundImage) {
            config(.backgroundImage) {
                closures.forEach { $0(bgImageView) }
            }
        } else { _bgImageView?.isHidden = true }
        
        var needLayoutViews: [(UIView, CGFloat)?] = [nil, nil, nil]
        let layoutAtStart = titleLayout.atStart
        
        if let closures: [((UILabel) -> Void)] = configs(.label) {
            config(.label) {
                closures.forEach { $0(label) }
            }
            if !label.isHidden {
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
        
        if let closures: [((UIImageView) -> Void)] = configs(.image) {
            config(.image) {
                closures.forEach { $0(imageView) }
            }
            
            if !imageView.isHidden {
                let size = imageView.frame.size
                if size.width == 0 || size.height == 0 {
                    imageView.sizeToFit()
                }
                needLayoutViews[1] = (imageView, layoutAtStart ? imageAndSpinnerSpace : titleAndImageSpace)
            } else { imageView.isHidden = true }
        } else { _imageView?.isHidden = true }
        
        if state == .loading {
            var needConfigSpinner = _spinnerView?.isAnimating ?? false
            if let closures = configs[state]?[.spinner] as? [((UIActivityIndicatorView) -> Void)] {
                config(.spinner) {
                    needConfigSpinner = true
                    closures.forEach { $0(spinnerView) }
                }
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
    
    private func config(_ type: ConfigType, work: () -> Void) {
        switch type {
        case .me:
            work()
        case .gradientLayer:
            aroundLayer {
                gradientLayer.isHidden = false
                work()
            }
        case .backgroundImage:
            bgImageView.isHidden = false
            bgImageView.grayLevel = .none
            work()
            if !bgImageView.isHidden, bgImageView.image != nil {
                if adjustsImageWhenHighlighted,
                   state.contains(.highlighted) {
                    bgImageView.grayLevel = .dark
                }
                if adjustsImageWhenDisabled,
                   state.contains(.disabled) {
                    bgImageView.grayLevel = .light
                }
            } else { _bgImageView?.isHidden = true }
        case .label:
            label.isHidden = false
            label.frame.size = .zero
            work()
            if label.isHidden ||
                (label.text?.isEmpty ?? true) ||
                (label.attributedText?.string.isEmpty ?? true) {
                label.isHidden = true
            } else {
                label.isHidden = false
            }
        case .image:
            imageView.grayLevel = .none
            imageView.isHidden = false
            imageView.frame.size = .zero
            work()
            if !imageView.isHidden, imageView.image != nil {
                if adjustsImageWhenHighlighted,
                   state.contains(.highlighted) {
                    imageView.grayLevel = .dark
                }
                if adjustsImageWhenDisabled,
                   state.contains(.disabled) {
                    imageView.grayLevel = .light
                }
            } else { _imageView?.isHidden = true }
        case .spinner:
            spinnerView.isHidden = false
            spinnerView.frame.size = .zero
            work()
        }
    }
}
