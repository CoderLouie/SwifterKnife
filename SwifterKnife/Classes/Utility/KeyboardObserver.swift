//
//  KeyboardObserver.swift
//  SwifterKnife
//
//  Created by liyang on 2023/3/1.
//

import UIKit

extension KeyboardEvent {
    public enum Name: RawRepresentable, CaseIterable {
        case willShow
        case didShow
        case willHide
        case didHide
        case willChangeFrame
        case didChangeFrame
        
        public var rawValue: NSNotification.Name {
            switch self {
            case .willShow:
                return UIResponder.keyboardWillShowNotification
            case .didShow:
                return UIResponder.keyboardDidShowNotification
            case .willHide:
                return UIResponder.keyboardWillHideNotification
            case .didHide:
                return UIResponder.keyboardDidHideNotification
            case .willChangeFrame:
                return UIResponder.keyboardWillChangeFrameNotification
            case .didChangeFrame:
                return UIResponder.keyboardDidChangeFrameNotification
            }
        }
        
        public init?(rawValue name: NSNotification.Name) {
            switch name {
            case UIResponder.keyboardWillShowNotification:
                self = .willShow
            case UIResponder.keyboardDidShowNotification:
                self = .didShow
            case UIResponder.keyboardWillHideNotification:
                self = .willHide
            case UIResponder.keyboardDidHideNotification:
                self = .didHide
            case UIResponder.keyboardWillChangeFrameNotification:
                self = .willChangeFrame
            case UIResponder.keyboardDidChangeFrameNotification:
                self = .didChangeFrame
            default:
                return nil
            }
        }
        
        static var allNames: [NSNotification.Name] {
            return allCases.map { $0.rawValue }
        }
    }
}

public struct KeyboardEvent {
    public let name: Name
    public let beginFrame: CGRect
    public let endFrame: CGRect
    public let curve: UIView.AnimationCurve
    public let duration: TimeInterval
    public var isLocal: Bool?
    
    public var options: UIView.AnimationOptions {
        return UIView.AnimationOptions(rawValue: UInt(curve.rawValue << 16))
    }
    
    init?(notification: Notification) {
        guard let userInfo = (notification as NSNotification).userInfo else { return nil }
        guard let name = KeyboardEvent.Name(rawValue: notification.name) else { return nil }
        guard let beginFrame = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue else { return nil }
        guard let endFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return nil }
        guard
            let curveInt = (userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber)?.intValue,
            let curve = UIView.AnimationCurve(rawValue: curveInt)
            else { return nil }
        guard
            let interval = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue
            else { return nil }
        
        self.name = name
        self.beginFrame = beginFrame
        self.endFrame = endFrame
        self.curve = curve
        self.duration = TimeInterval(interval)
        if #available(iOS 9, *) {
            self.isLocal = (userInfo[UIResponder.keyboardIsLocalUserInfoKey] as? NSNumber)?.boolValue
        }
    }
}


public final class KeyboardObserver {
    public enum State {
        case initial
        case showing
        case shown
        case hiding
        case hidden
        case changing
    }
    public typealias Listener = (_ event: KeyboardEvent) -> Void
    
    public private(set) var state = State.initial
    public var isEnabled = true
    
    private var eventListen: [KeyboardEvent.Name: [Listener]] = [:]
    
    deinit {
        eventListen.removeAll()
        NotificationCenter.default.removeObserver(self)
    }
    public init() {}
    
    public func observe(_ name: KeyboardEvent.Name, closure: @escaping Listener) {
        if var listeners = eventListen[name] {
            listeners.append(closure)
            eventListen[name] = listeners
        } else {
            NotificationCenter.default.addObserver(self, selector: #selector(notified(_:)), name: name.rawValue, object: nil)
            eventListen[name] = [closure]
        }
    }
    
    @objc private func notified(_ notification: Notification) {
        guard isEnabled else { return }
        
        guard let event = KeyboardEvent(notification: notification) else { return }
        
        switch event.name {
        case .willShow:
            state = .showing
        case .didShow:
            state = .shown
        case .willHide:
            state = .hiding
        case .didHide:
            state = .hidden
        case .willChangeFrame:
            state = .changing
        case .didChangeFrame:
            state = .shown
        }
        eventListen[event.name]?.forEach { $0(event) }
    }
}


private var keyboardObserverKey: UInt8 = 0
private var keyboardAvoidingSpaceKey: UInt8 = 0
private var keyboardKeepSpaceKey: UInt8 = 0
extension UIView {
    private var theInputView: UIView? {
        searchInLevelOrder { view, _ in
            view.isFirstResponder
        }
    }
    /// 输入视图需要和键盘保持的距离
    public var keyboardKeepSpaceClosure: ((UIView) -> CGFloat?)? {
        set {
            objc_setAssociatedObject(self, &keyboardKeepSpaceKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            if newValue == nil {
                _keyboardObserver = nil
            } else {
                if let _ = _keyboardObserver { return }
                let observer = KeyboardObserver()
                _keyboardObserver = observer
                
                observer.observe(.willShow) { [unowned self] event in
                    guard let inputView = self.theInputView,
                          let closure = self.keyboardKeepSpaceClosure,
                          let space = closure(inputView) else {
                        return
                    }
                    let rect = inputView.convert(inputView.bounds, to: nil)
                    let delta = Screen.height - rect.maxY - event.endFrame.height - space
                    if delta > 0 { return }
                    self.keyboardAvoidingSpace = delta
                    
                    var frame = self.frame
                    frame.origin.y += delta
                    UIView.animate(withDuration: event.duration, delay: 0, options: event.options) { [weak self] in
                        self?.frame = frame
                    }
                }
                observer.observe(.willHide) { [unowned self] event in
                    guard let space = self.keyboardAvoidingSpace else { return }
                    
                    var frame = self.frame
                    frame.origin.y -= space
                    UIView.animate(withDuration: event.duration, delay: 0, options: event.options) { [weak self] in
                        self?.frame = frame
                    } completion: { [weak self] _ in
                        self?.keyboardAvoidingSpace = nil
                    }
                }
            }
        }
        get {
            objc_getAssociatedObject(self, &keyboardKeepSpaceKey) as? (UIView) -> CGFloat?
        }
    }
    
    /// 键盘遮挡的距离 负值
    private var keyboardAvoidingSpace: CGFloat? {
        get {
            objc_getAssociatedObject(self, &keyboardAvoidingSpaceKey) as? CGFloat
        }
        set {
            objc_setAssociatedObject(self, &keyboardAvoidingSpaceKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    private var _keyboardObserver: KeyboardObserver? {
        get {
            objc_getAssociatedObject(self, &keyboardObserverKey) as? KeyboardObserver
        }
        set {
            objc_setAssociatedObject(self, &keyboardObserverKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

/*
public protocol KeyboardAvoiding: AnyObject {
    var containerView: UIView { get }
    var theInputView: UIView? { get }
    var spaceBetweenInputAndKeyboard: CGFloat { get }
}

private var keyboardObserverKey: UInt8 = 0
private var containerOriginFrameKey: UInt8 = 0
public extension KeyboardAvoiding {
    var theInputView: UIView? {
        containerView.firstResponder()
    }
    var spaceBetweenInputAndKeyboard: CGFloat {
        10
    }
    
    func startWorking() {
        let observer = self.keyboardObserver
        
        observer.observe(.willShow) { [unowned self] event in
            if let _ = self.containerOriginFrame { return }
            guard let inputView = self.theInputView else {
                return
            }
            let container = self.containerView
            let rect = inputView.convert(inputView.frame, to: nil)
            let delta = Screen.height - rect.maxY - event.endFrame.height - self.spaceBetweenInputAndKeyboard
            if delta > 0 { return }
            
            var frame = container.frame
            containerOriginFrame = frame
            frame.origin.y = delta
            UIView.animate(withDuration: event.duration, delay: 0, options: event.options) {
                container.frame = frame
            }
        }
        observer.observe(.willHide) { [unowned self] event in
            guard let frame = self.containerOriginFrame else { return }
            let container = self.containerView
            UIView.animate(withDuration: event.duration, delay: 0, options: event.options) {
                container.frame = frame
            } completion: { _ in
                self.containerOriginFrame = nil
            }
        }
    }
    
    private var containerOriginFrame: CGRect? {
        get {
            objc_getAssociatedObject(self, &containerOriginFrameKey) as? CGRect
        }
        set {
            objc_setAssociatedObject(self, &containerOriginFrameKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    private var keyboardObserver: KeyboardObserver {
        let observer: KeyboardObserver
        
        if let existing = objc_getAssociatedObject(self, &keyboardObserverKey) as? KeyboardObserver {
            observer = existing
        } else {
            observer = KeyboardObserver()
            objc_setAssociatedObject(self, &keyboardObserverKey, observer, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        return observer
    }
}
*/
