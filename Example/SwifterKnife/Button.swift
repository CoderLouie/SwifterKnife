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
        
    }
}
 

fileprivate extension CGSize {
    var _ceil: CGSize {
        return CGSize(width: ceil(width), height: ceil(height))
    }
}

private extension Button {
    func updateContent() -> CGSize {
        var height: CGFloat = 0, width: CGFloat = 0
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
        
        var flag: (Bool, Bool, Bool) = (false, false, false)
        let isHorizontalLayout = titleLayout.isHorizontal
        
        if let closure = config[.label] as? ((UILabel) -> Void) {
            closure(label)
            if !label.isHidden,
               (!(label.text?.isEmpty ?? true) ||
                !(label.attributedText?.string.isEmpty ?? true)) {
                var size = label.frame.size
                if size.width == 0 || size.height == 0 {
                    label.sizeToFit()
                    size = label.frame.size._ceil
                    label.frame.size = size
                }
                flag.0 = true
                if isHorizontalLayout {
                    height = max(height, size.height)
                    width += size.width + titleAndImageSpace
                } else {
                    width = max(height, size.width)
                    height += size.height + titleAndImageSpace
                }
            }
        }
        if let closure = config[.image] as? ((UIImageView) -> Void) {
            closure(imageView)
            if !imageView.isHidden, imageView.image != nil {
                var size = imageView.frame.size
                if size.width == 0 || size.height == 0 {
                    imageView.sizeToFit()
                    size = imageView.frame.size
                }
                flag.1 = true
                if isHorizontalLayout {
                    height = max(height, size.height)
                    width += (size.width) + imageAndSpinnerSpace
                } else {
                    width = max(height, (size.width))
                    height += (size.height) + imageAndSpinnerSpace
                }
            } else if flag.0 {
                if isHorizontalLayout {
                    width -= titleAndImageSpace
                } else {
                    height -= titleAndImageSpace
                }
            }
        } else if flag.0 {
            if isHorizontalLayout {
                width -= titleAndImageSpace
            } else {
                height -= titleAndImageSpace
            }
        }
        if let closure = config[.spinner] as? ((UIActivityIndicatorView) -> Void) {
            closure(spinnerView)
            if !spinnerView.isHidden {
                var size = spinnerView.frame.size
                if size.width == 0 || size.height == 0 {
                    spinnerView.sizeToFit()
                    size = spinnerView.frame.size
                }
                flag.2 = true
                if isHorizontalLayout {
                    height = max(height, (size.height))
                    width += (size.width)
                } else {
                    width = max(height, (size.width))
                    height += (size.height)
                }
            } else if flag.1 {
                if isHorizontalLayout {
                    width -= imageAndSpinnerSpace
                } else {
                    height -= imageAndSpinnerSpace
                }
            }
        } else if flag.1 {
            if isHorizontalLayout {
                width -= imageAndSpinnerSpace
            } else {
                height -= imageAndSpinnerSpace
            }
        }
        
        if isHorizontalLayout {
            let halfH = height * 0.5
            let atStart = titleLayout == .left
            if flag.0 {
                label.center.y = halfH
                if atStart { label.frame.origin.x = 0 }
            }
            if flag.1 {
                imageView.center.y = halfH
            }
            if flag.2 {
                spinnerView.center.y = halfH
            }
        } else {
            
        }
        
        let contentSize = CGSize(width: width, height: height)
        contentView.bounds.size = contentSize
        
        
        _contentSize = contentSize
        return _contentSize
    }
}

/*
 2022-06-01 11:34:56.169341+0800 SwifterKnife_Example[1168:13061030] ------------------
 2022-06-01 11:34:56.170261+0800 SwifterKnife_Example[1168:13061030] all method of UIButton is
 (
     "__scalarStatisticsForUserTouchUpInsideEvent",
     "_accessibilityInfoButtonContext",
     accessibilityLabel,
     accessibilityValue,
     accessibilityTraits,
     isAccessibilityElement,
     accessibilityPath,
     accessibilityPerformEscape,
     "_accessibilityAutomationType",
     "_accessibilityUserTestingChildren",
     "_accessibilityAuditIssuesWithOptions:",
     "_accessibilityNativeTraits",
     "_accessibilityImagePath",
     "_accessibilityButtonMacCatalystPopupButtonCell",
     "_axButtonTypeIsModernCircle",
     "_mapkit_title",
     "_mapkit_setAttributedTitle:",
     "_mapkit_setImage:",
     "_mapkit_accessoryControlToExtendWithCallout",
     "ab_text",
     "setAb_text:",
     "ab_textAttributes",
     "setAb_textAttributes:",
     "_nui_baselineViewType",
     "_nui_additionalInsetsForBaselines",
     canUseFastLayoutSizeCalulation,
     "_nui_lineHeight",
     "fontForStyle:currentSizeCategory:maxSizeCategory:",
     "fontForStyle:maxSizeCategory:",
     dealloc,
     "encodeWithCoder:",
     "initWithCoder:",
     ".cxx_destruct",
     "setEnabled:",
     title,
     "setTitle:",
     role,
     lineBreakMode,
     "setLineBreakMode:",
     "_font",
     image,
     "setBounds:",
     adjustsImageSizeForAccessibilityContentSizeCategory,
     "setAdjustsImageSizeForAccessibilityContentSizeCategory:",
     "setFrame:",
     "initWithFrame:",
     setNeedsLayout,
     "_intrinsicSizeWithinSize:",
     layoutSubviews,
     "traitCollectionDidChange:",
     "_controlEventsForActionTriggered",
     "_contentHuggingDefault_isUsuallyFixedWidth",
     "_contentHuggingDefault_isUsuallyFixedHeight",
     "sizeThatFits:",
     "setFont:",
     "setTitle:forState:",
     "setTitleColor:forState:",
     titleLabel,
     defaultAccessibilityTraits,
     isAccessibilityElementByDefault,
     isElementAccessibilityExposedToInterfaceBuilder,
     "_backgroundView",
     "_scaleFactorForImage",
     canBecomeFocused,
     "gestureRecognizerShouldBegin:",
     largeContentTitle,
     largeContentImage,
     scalesLargeContentImage,
     imageView,
     "_imageView",
     font,
     "setTintColor:",
     "setHighlighted:",
     alignmentRectInsets,
     updateConstraints,
     "setSpringLoaded:",
     isSpringLoaded,
     tintColorDidChange,
     viewForFirstBaselineLayout,
     viewForLastBaselineLayout,
     "pressesBegan:withEvent:",
     "pressesEnded:withEvent:",
     "pressesCancelled:withEvent:",
     "_setButtonType:",
     "pointerInteraction:regionForRequest:defaultRegion:",
     "pointerInteraction:styleForRegion:",
     "pointerInteraction:willEnterRegion:animator:",
     "pointerInteraction:willExitRegion:animator:",
     "_updateImageView",
     "setSemanticContentAttribute:",
     "setSelected:",
     "_encodableSubviews",
     "_selectorOverridden:",
     "_populateArchivedSubviews:",
     "floatingContentView:isTransitioningFromState:toState:",
     "_preferredConfigurationForFocusAnimation:inContext:",
     buttonType,
     "_pointerWillEnter:",
     "_pointerWillExit:",
     "_contextMenuInteraction:styleForMenuWithConfiguration:",
     menu,
     "contextMenuInteraction:configurationForMenuAtLocation:",
     "contextMenuInteraction:previewForHighlightingMenuWithConfiguration:",
     "contextMenuInteraction:previewForDismissingMenuWithConfiguration:",
     "cursorInteraction:regionForLocation:defaultRegion:",
     "cursorInteraction:styleForRegion:modifiers:",
     "cursorInteraction:willEnterRegion:withAnimator:",
     "cursorInteraction:willExitRegion:withAnimator:",
     "_accessibilityShouldActivateOnHUDLift",
     "_intrinsicSizeForTitle:attributedTitle:image:backgroundImage:titlePaddingInsets:",
     "contentRectForBounds:",
     "_selectedIndicatorBounds",
     "_newLabelWithFrame:",
     "imageForState:",
     "_roundSize:",
     "_shouldAdjustToTraitCollection",
     "_supportsMacIdiom",
     "_likelyToHaveTitle",
     "backgroundImageForState:",
     "_selectionIndicatorView",
     "_allButtonContent",
     "setAttributedTitle:forState:",
     "setContentEdgeInsets:",
     "attributedTitleForState:",
     "setImage:forState:",
     "setPreferredSymbolConfiguration:forImageInState:",
     currentImage,
     contentEdgeInsets,
     "titleForState:",
     "setShowsMenuAsPrimaryAction:",
     "_menuProvider",
     "_setImageContentMode:",
     "_setDisableAutomaticTitleAnimations:",
     "_setWantsAccessibilityUnderline:",
     "setImageEdgeInsets:",
     "_isCarPlaySystemTypeButton",
     "_isInCarPlay",
     "_didMoveFromWindow:toWindow:",
     "_externalTitleColorForState:isTintColor:",
     "_externalFocusedTitleColor",
     "_setTitleShadowOffset:",
     "_setFrame:deferLayout:",
     "_titleView",
     "setTitleShadowColor:forState:",
     "setTitleColor:forStates:",
     "_didChangeFromIdiom:onScreen:traverseHierarchy:",
     "setAdjustsImageWhenHighlighted:",
     "setAdjustsImageWhenDisabled:",
     "setBackgroundImage:forState:",
     "_setImageColor:forState:",
     "setTitleEdgeInsets:",
     "_isTitleFrozen",
     "_setFont:",
     "_setTitleFrozen:",
     "setTitleShadowColor:forStates:",
     "setTitle:forStates:",
     "setImage:forStates:",
     "setContentHorizontalAlignment:",
     "setContentVerticalAlignment:",
     "setDisabledDimsImage:",
     "_contentBackdropView",
     "_sendSetNeedsLayoutToSuperviewOnTitleAnimationCompletionIfNecessary",
     "_pathTitleEdgeInsets",
     "_pathImageEdgeInsets",
     "_isModernButton",
     "_externalUnfocusedBorderColor",
     currentTitle,
     "setMenu:",
     "setAutosizesToFit:",
     "_willMoveToWindow:",
     "_intrinsicContentSizeInvalidatedForChildView:",
     "_setLineBreakMode:",
     "_setBlurEnabled:",
     "_blurEnabled",
     "_reducedTransparencyDidChange:",
     "_highlightCornerRadius",
     "setBackgroundImage:forStates:",
     "_setHighlighted:animated:",
     "_didUpdateFocusInContext:withAnimationCoordinator:",
     "_pointerEffectPreviewParameters",
     "_pointerEffectWithPreview:",
     "_shapeInContainer:",
     pointerStyleProvider,
     "_pointerInteractionCanBeAssisted",
     "_gestureRecognizerFailed:",
     "_buttonType",
     "_lineBreakMode",
     "_setFont:isDefaultForIdiom:",
     "_titleViewLabelMetricsChanged",
     "_titleColorForState:suppressTintColorFollowing:",
     "_contentForState:",
     "_fontIsDefaultForIdiom",
     "_setupBackgroundView",
     "_setTitleColor:forStates:",
     "_setShadowColor:forStates:",
     "titleColorForState:",
     "titleShadowColorForState:",
     "_setContentConstraints:",
     "setShowsTouchWhenHighlighted:",
     "_setDefaultFontForIdiom",
     "_commonInitForPrimaryAction:",
     "_takeContentFromArchivableContent:",
     "_shouldHaveFloatingAppearance",
     "_effectiveContentView",
     "initWithFrame:primaryAction:",
     "_archivableContent:",
     "_floatingContentView",
     "_usesVisualElement",
     "_visualElement",
     "_uninstallSelectGestureRecognizer",
     "_updateEffectsForImageView:background:",
     "_installSelectGestureRecognizer",
     autosizesToFit,
     pressFeedbackPosition,
     "_canHaveTitle",
     "_setupTitleView",
     "_updateTitleView",
     "_isSystemProvidedButton",
     "_setupImageView",
     "_invalidateContentConstraints",
     "_refreshVisualElementForTraitCollection:",
     "_refreshVisualElementForTraitCollection:populatingAPIProperties:",
     "visualElementForTraitCollection:",
     "_setVisualElement:",
     "_hasDrawingStyle",
     "_isEffectivelyDisabledExternalButton",
     "_selectGestureChanged:",
     "beginTrackingWithTouch:withEvent:",
     "_imageForState:applyingConfiguration:usesImageForNormalState:",
     "_clippedHighlightBounds",
     "_hasHighlightColor",
     "_isExternalRoundedRectButtonWithPressednessState",
     "_highlightsBackgroundImage",
     "_selectedIndicatorViewWithImage:",
     "_selectedIndicatorAlpha",
     "_textNeedsCompositingModeWhenSelected",
     "_imageNeedsCompositingModeWhenSelected",
     "titleRectForContentRect:",
     "imageRectForContentRect:",
     "_externalFlatEdge",
     "_highlightBoundsForDrawingStyle",
     "_borderColorForState:",
     "_prepareMaskAnimationViewIfNecessary",
     "_transitionAnimationWithKeyPath:",
     "_borderWidthForState:bounds:",
     "_fadeOutAnimationWithKeyPath:",
     "_updateMaskState",
     "_invalidateForPropertyChange",
     "_externalBorderColorForState:",
     "_drawingStrokeForState:",
     "_highlightBounds",
     "_setContent:forState:",
     "_wantsAccessibilityUnderline",
     "_titleForState:",
     "_shadowColorForState:",
     "_backgroundForState:usesBackgroundForNormalState:",
     "_preferredConfigurationForState:",
     "_attributedTitleForState:adjustedToTraitCollection:",
     "_imageColorForState:",
     "preferredSymbolConfigurationForImageInState:",
     "_combinedContentPaddingInsets",
     "_attributedTitleForState:",
     "_deriveTitleRect:imageRect:fromContentRect:calculatePositionForEmptyTitle:",
     "_titleRectForContentRect:calculatePositionForEmptyTitle:",
     imageEdgeInsets,
     "_effectiveSizeForImage:",
     titleEdgeInsets,
     "_setContentHuggingPriorities:",
     "_titleOrImageViewForBaselineLayout",
     "_viewForBaselineLayout",
     "_setupTitleViewRequestingLayout:",
     "_baselineOffsetsAtSize:",
     "_highlightRectForImageRect:",
     "_highlightRectForTextRect:",
     adjustsImageWhenHighlighted,
     showsTouchWhenHighlighted,
     adjustsImageWhenDisabled,
     "backgroundRectForBounds:",
     "_wantsContentBackdropView",
     "_updateContentBackdropView",
     "_updateTitleViewStyleEffectConfiguration",
     "_beginTitleAnimation",
     "_shouldSkipNormalLayoutForSakeOfTemplateLayout",
     "_requiresLayoutForPropertyChange",
     "_layoutContentBackdropView",
     "_updateBackgroundImageView",
     "_layoutBackgroundImageView",
     "_layoutImageAndTitleViews",
     "_applyAppropriateTouchInsetsForButton",
     "_setupDrawingStyleForState:",
     "_shouldUpdatePressedness",
     "_updateSelectionViewForState:",
     "_setupPressednessForState:",
     "_titleShadowOffset",
     "_newImageViewWithFrame:",
     "_createPreparedImageViewWithFrame:",
     "_isiOSSystemProvidedButton",
     "_refreshVisualElement",
     "_setTitle:forStates:",
     "_setImage:forStates:",
     "_setBackground:forStates:",
     "_defaultFontForIdiom:",
     "_drawingStrokeForStyle:",
     "_setDrawingStroke:forState:",
     "_drawingStyleForStroke:",
     "_externalDrawingStyleForState:",
     "_shouldDefaultToTemplatesForImageViewBackground:",
     "_setVisualEffectViewEnabled:backgroundColor:",
     "_enumerateContentWithBlock:",
     "_defaultImageForState:withConfiguration:",
     "_externalImageColorForState:",
     "_hasImageForProperty:",
     "_applyCarPlaySystemButtonCustomizations",
     "setCursorStyleProvider:",
     "_shapeInContainer:proposal:",
     "_createPointerInteraction",
     "_pointerEffect",
     "_updateContextMenuEnabled",
     "_layoutDebuggingTitle",
     reversesTitleShadowWhenHighlighted,
     "setReversesTitleShadowWhenHighlighted:",
     "setRole:",
     "_disableAutomaticTitleAnimations",
     "_setExternalFlatEdge:",
     currentTitleColor,
     "_currentImageColor",
     currentTitleShadowColor,
     currentBackgroundImage,
     currentAttributedTitle,
     currentPreferredSymbolConfiguration,
     "_currentImageWithResolvedConfiguration",
     "_visualEffectViewEnabled",
     titleShadowOffset,
     "setTitleShadowOffset:",
     "_alwaysHandleScrollerMouseEvent",
     "_setShouldHandleScrollerMouseEvent:",
     "setShowPressFeedback:",
     "crossfadeToImage:forState:",
     "_setLetterpressStyle:forState:",
     "_setDrawingStyle:forState:",
     "_drawingStyleForState:",
     "_isContentBackgroundHidden",
     "_setContentBackgroundHidden:",
     "_setImageColor:forStates:",
     "_setAttributedTitle:forStates:",
     "_letterpressStyleForState:",
     "_preferredCursorEffect",
     "_setPreferredCursorEffect:",
     "setPointerStyleProvider:",
     "_setMenuProvider:",
     "_contentConstraints",
     "_internalTitlePaddingInsets",
     "_setInternalTitlePaddingInsets:",
     "_imageContentMode",
     "_plainButtonBackgroundColor",
     "_setPlainButtonBackgroundColor:",
     cursorStyleProvider,
     "_viewForLoweringBaselineLayoutAttribute:",
     "_uikit_applyValueFromTraitStorage:forKeyPath:",
     "_hasCustomAutolayoutNeighborSpacingForAttribute:",
     "_autolayoutSpacingAtEdge:forAttribute:inContainer:isGuide:",
     "_autolayoutSpacingAtEdge:forAttribute:nextToNeighbor:edge:attribute:multiplier:"
 )
 
 */

// MARK: - 自定义按钮的lable
//fileprivate class LLCustomButtonLabel: UILabel {
//    var onTextChange: (() -> Void)?
//
//    override var text: String? {
//        didSet { onTextChange?() }
//    }
//    override var attributedText: NSAttributedString? {
//        didSet { onTextChange?() }
//    }
//}
