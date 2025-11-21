//
//  SKWindow.swift
//  SwifterKnife
//
//  Created by liyang on 2024/12/22.
//

import UIKit

class _BaseViewController: UIViewController {
    var isPush: Bool? {
        guard let n = navigationController?.viewControllers.count else { return nil }
        return n > 1 ? true : nil
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 13 / 255.0, green: 13 / 255.0, blue: 13 / 255.0, alpha: 1)
        view.isOpaque = false
        
        let centerY = Screen.navbarCenterY
         
        if let isP = isPush {
            UIButton().do {
                $0.setTitle(isP ? "返回" : "关闭" , for: .normal)
                $0.setTitleColor(.white, for: .normal)
                $0.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
                $0.addTarget(self, action: #selector(onLeftButtonClick), for: .touchUpInside)
                view.addSubview($0)
                $0.doConstraints { make in
                    make.leadingEqualTo(16)
                    make.centerYEqualTo(centerY)
                }
            }
        }
        
        if let t = title, !t.isEmpty {
            UILabel().then {
                view.addSubview($0)
                $0.textColor = .white
                $0.font = .systemFont(ofSize: 18, weight: .medium)
                $0.text = t
                $0.doConstraints { make in
                    make.centerYEqualTo(centerY)
                    make.centerXEqualTo(0)
                }
            }
        }
    }
    @objc private func onLeftButtonClick() {
        if let isP = isPush, isP {
            navigationController?.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
}


fileprivate class _NavigationController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBarHidden(true, animated: false)
    }
}

fileprivate class _TabBarController: UITabBarController {
     
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.do { bar in
            let font = UIFont.systemFont(ofSize: 16, weight: .semibold)
            UITabBarItem.appearance(whenContainedInInstancesOf: [Self.self]).do {
                $0.titlePositionAdjustment.vertical = -15.6667
                $0.setTitleTextAttributes(
                    [.font: font,
                     .foregroundColor: UIColor.white.withAlphaComponent(0.4)], for: .normal)
                $0.setTitleTextAttributes(
                    [.font: font,
                     .foregroundColor: UIColor.white], for: .selected)
            }
            bar.tintColor = .white
            bar.isTranslucent = true
            bar.barStyle = .black
        }
          
        addChild(LogViewController.self, "日志")
        addChild(OptionsViewController.self, "选项")
    }
    
    @discardableResult
    private func addChild<T: UIViewController>(_ viewController: T.Type, _ title: String?) -> T {
        let vc = T()
        vc.title = title
        addChild(_NavigationController(rootViewController: vc))
        return vc
    }
}


extension UIWindow.Level {
    public static func + (lhs: UIWindow.Level, rhs: RawValue) -> UIWindow.Level {
        .init(rawValue: lhs.rawValue + rhs)
    }
}

class SKWindow: UIWindow {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        if #available(iOS 13, *) {
            NotificationCenter.default.addObserver(forName: UIScene.willConnectNotification, object: nil, queue: nil) { [weak self] notify in
                guard let this = self,
                        this.windowScene == nil else { return }
                this.windowScene = notify.object as? UIWindowScene
            }
        }
        
        windowLevel = .alert + 5
        
        isHidden = true
        
        rootViewController = _TabBarController()
        
        container = UIView().then {
            $0.isHidden = true
            $0.tag = 999
            $0.backgroundColor = UIColor.black.withAlphaComponent(0.9)
            addSubview($0)
            $0.doConstraints { make in
                make.edgesEqualTo(0)
            }
        }
        popoverButton = UIButton().then {
            addSubview($0)
            $0.setTitle("D", for: .normal)
            $0.setTitleColor(.white, for: .normal)
            $0.titleLabel?.font = .systemFont(ofSize: 16)
            $0.frame.size = CGSize(width: 32, height: 32)
            $0.center = CGPoint(x: 50, y: Screen.height * 0.7)
            $0.backgroundColor = UIColor.black.withAlphaComponent(0.7)

            $0.layer.do {
                $0.masksToBounds = true
                $0.cornerRadius = 16
                $0.borderColor = UIColor.white.withAlphaComponent(0.7).cgColor
                $0.borderWidth = 1
                $0.shadowColor = UIColor.black.cgColor // 阴影颜色
                $0.shadowOpacity = 0.4 // 阴影透明度
                $0.shadowRadius = 2
                $0.shadowOffset = CGSize(width: 2, height: 2) // 阴影偏移量
            }
            
            $0.addTarget(self, action: #selector(handlePopoverTouchEvent), for: .touchUpInside)
            
            let longGes = UILongPressGestureRecognizer(target: self, action: #selector(longGestureAction(_:)))
            $0.addGestureRecognizer(longGes)
            let panGes = UIPanGestureRecognizer(target: self, action: #selector(panGestureAction(_:)))
            $0.addGestureRecognizer(panGes)
            
            panGes.require(toFail: longGes)
        }
    }
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let res = super.hitTest(point, with: event)
        if res === self { return nil }
        return res
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        DispatchQueue.main.async {
            self.use_canvas_ifneeded()
        }
    }
     
    private func use_canvas_ifneeded() {
        for view in subviews {
            if view === container { continue }
            if view === popoverButton { continue }
            if view.superview === container { continue }
            container.addSubview(view)
        }
    }
    
    private unowned var container: UIView!
    private unowned var popoverButton: UIButton!
    private lazy var contentEdge = Screen.bodyRect.inset(by: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20))
}

extension SKWindow {
    
    @objc private func handlePopoverTouchEvent() {
        container.isHidden.toggle()
    }
    @objc func longGestureAction(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            UIImpactFeedbackGenerator(style: .medium).do {
                $0.prepare()
                $0.impactOccurred()
            }
            isHidden = true
        }
    }
    @objc func panGestureAction(_ gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .changed:
            let trans = gesture.translation(in: self)
            var center = popoverButton.center
            center.x += trans.x
            center.y += trans.y
            if center.x >= contentEdge.maxX { center.x = contentEdge.maxX }
            if center.x <= contentEdge.minX { center.x = contentEdge.minX }
            if center.y <= contentEdge.minY { center.y = contentEdge.minY }
            if center.y >= contentEdge.maxY { center.y = contentEdge.maxY }
            popoverButton.center = center
            gesture.setTranslation(.zero, in: self)
        default: break
        }
    }
}

public enum SKS {
    private static var _window: SKWindow? = nil
    private static var window: SKWindow {
        if let v = _window { return v }
        let w = SKWindow(frame: UIScreen.main.bounds)
        _window = w
        return w
    }
    
    private static func rootVC(at index: Int) -> UIViewController? {
        guard let tabvc = _window?.rootViewController as? UITabBarController else { return nil }
        guard let vcs = tabvc.viewControllers, vcs.indices.contains(index) else { return nil }
        return (vcs[index] as? UINavigationController)?.viewControllers.first
    }
    
    public static var isEnable: Bool {
        get { !(_window?.isHidden ?? true) }
        set {
            window.isHidden = !newValue
        }
    }
    
    public static func log(_ string: String, level: ScreenLogLevel = .normal, tags: [String] = []) {
        let ops = {
            guard let logvc = rootVC(at: 0) as? LogViewController else { return }
            logvc.log(string + "\n", level: level, tags: tags)
        }
        if Thread.isMainThread {
            ops()
        } else {
            DispatchQueue.main.async(execute: ops)
        }
    }
    
    public static func makeScreenOptions(_ make: @escaping (_ maker: SKSOptionHandler) -> Void) {
        let ops = {
            guard let opvc = rootVC(at: 1) as? OptionsViewController else { return }
            make(opvc)
            opvc.reloadIfNeeded()
        }
        if Thread.isMainThread {
            ops()
        } else {
            DispatchQueue.main.async(execute: ops)
        }
    }
}
 

public typealias ConstraintBuilder = ArrayBuilder<NSLayoutConstraint>

public protocol ConstraintSupport {}
public struct SKConstraintMaker {
    public let son: UIView
    public let father: UIView
    
    
    public func heightEqualToSuperview() -> NSLayoutConstraint {
        son.heightAnchor.constraint(equalTo: father.heightAnchor)
    }
    public func widthEqualToSuperview() -> NSLayoutConstraint {
        son.widthAnchor.constraint(equalTo: father.widthAnchor)
    }
    
    public func heightEqualTo(_ val: CGFloat) -> NSLayoutConstraint {
        son.heightAnchor.constraint(equalToConstant: val)
    }
    public func widthEqualTo(_ val: CGFloat) -> NSLayoutConstraint {
        son.widthAnchor.constraint(equalToConstant: val)
    }
    
    public func topEqualTo(_ val: CGFloat) -> NSLayoutConstraint {
        son.topAnchor.constraint(equalTo: father.topAnchor, constant: val)
    }
    public func leadingEqualTo(_ val: CGFloat) -> NSLayoutConstraint {
        son.leadingAnchor.constraint(equalTo: father.leadingAnchor, constant: val)
    }
    public func trailingEqualTo(_ val: CGFloat) -> NSLayoutConstraint {
        son.trailingAnchor.constraint(equalTo: father.trailingAnchor, constant: val)
    }
    public func bottomEqualTo(_ val: CGFloat) -> NSLayoutConstraint {
        son.bottomAnchor.constraint(equalTo: father.bottomAnchor, constant: val)
    }
    
    public func centerXEqualTo(_ val: CGFloat) -> NSLayoutConstraint {
        if val == 0 {
            return son.centerXAnchor.constraint(equalTo: father.centerXAnchor)
        } else {
            return son.centerXAnchor.constraint(equalTo:  father.leadingAnchor, constant: val)
        }
    }
    public func centerYEqualTo(_ val: CGFloat) -> NSLayoutConstraint {
        if val == 0 {
            return son.centerYAnchor.constraint(equalTo: father.centerYAnchor)
        } else {
            return son.centerYAnchor.constraint(equalTo:  father.topAnchor, constant: val)
        }
    }
    public func centerEqualTo(_ val: CGFloat) -> [NSLayoutConstraint] {
        [centerXEqualTo(val), centerYEqualTo(val)]
    }
    
    public func horizontalEqualTo(_ val: CGFloat) -> [NSLayoutConstraint] {
        [leadingEqualTo(val), trailingEqualTo(-val)]
    }
    public func verticalEqualTo(_ val: CGFloat) -> [NSLayoutConstraint] {
        [topEqualTo(val), bottomEqualTo(-val)]
    }
    public func edgesEqualTo(_ val: CGFloat) -> [NSLayoutConstraint] {
        [topEqualTo(val), bottomEqualTo(-val), leadingEqualTo(val), trailingEqualTo(-val)]
    }
    
}
extension ConstraintSupport where Self: UIView {
    
    @discardableResult
    public func doConstraints(@ConstraintBuilder builder: (_ make: SKConstraintMaker) -> [NSLayoutConstraint]) -> [NSLayoutConstraint] {
        guard let superv = superview else {
            fatalError()
        }
        translatesAutoresizingMaskIntoConstraints = false
        let maker = SKConstraintMaker(son: self, father: superv)
        let res = builder(maker)
        NSLayoutConstraint.activate(res)
        return res
    }
}
extension UIView: ConstraintSupport {}
