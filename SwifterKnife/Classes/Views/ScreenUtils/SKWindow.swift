//
//  SKWindow.swift
//  SwifterKnife
//
//  Created by liyang on 2024/12/22.
//

import UIKit

class _BaseViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .create("#0D0D0D")
        
        view.isOpaque = false
        
        let centerY = Screen.navbarCenterY
        
        func createButton(_ title: String, _ closure: @escaping () -> Void) {
            UIButton().do {
                $0.setTitle(title, for: .normal)
                $0.setTitleColor(.white, for: .normal)
                $0.titleLabel?.font = .semibold(14).fit
                $0.addTouchUpInsideClosure { sender, event in
                    closure()
                }
                view.addSubview($0)
                $0.snp.makeConstraints { make in
                    make.leading.equalTo(16.fit)
                    make.centerY.equalTo(centerY)
                }
            }
        }
        if isModal {
            createButton("关闭") {
                self.dismiss(animated: true)
            }
        } else if navigationController?.viewControllers.count ?? 0 > 1 {
            createButton("返回") {
                self.navigationController?.popViewController(animated: true)
            }
        }
        if let t = title, !t.isEmpty {
            UILabel().then {
                view.addSubview($0)
                $0.textColor = .white
                $0.font = .medium(18).fit
                $0.text = t
                $0.snp.makeConstraints { make in
                    make.centerY.equalTo(centerY)
                    make.centerX.equalToSuperview()
                }
            }
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
            let font = UIFont.semibold(16).fit
            UITabBarItem.appearance(whenContainedInInstancesOf: [Self.self]).do {
                $0.titlePositionAdjustment.vertical = -15.6667
                $0.setTitleTextAttributes(
                    [.font: font,
                     .foregroundColor: UIColor(gray: 255, alpha: 0.4)], for: .normal)
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
        windowLevel = .alert + 5
        
        isHidden = true
        
        rootViewController = _TabBarController()
        
        container = UIView().then {
            $0.isHidden = true
            $0.tag = 999
            $0.backgroundColor = UIColor(gray: 0, alpha: 0.9)
            addSubview($0)
            $0.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
        popoverButton = UIButton().then {
            addSubview($0)
            $0.setTitle("D", for: .normal)
            $0.setTitleColor(.white, for: .normal)
            $0.titleLabel?.font = .systemFont(ofSize: 16).fit
            $0.frame.size = CGSize(width: 32, height: 32).fit
            $0.center = CGPoint(x: 50.fit, y: Screen.height * 0.7)
            $0.backgroundColor = UIColor(gray: 0, alpha: 0.7)
            $0.addBorder(color: UIColor(gray: 255, alpha: 0.7), radius: 16.fit, width: 1)
            $0.layer.shadowColor = UIColor.black.cgColor // 阴影颜色
            $0.layer.shadowOpacity = 0.4 // 阴影透明度
            $0.layer.shadowRadius = 2
            $0.layer.shadowOffset = CGSize(width: 2, height: 2) // 阴影偏移量
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
    private lazy var contentEdge = Screen.bodyRect.inset(by: UIEdgeInsets(inset: 20))
}

extension SKWindow {
    
    @objc private func handlePopoverTouchEvent() {
        container.isHidden.toggle()
    }
    @objc func longGestureAction(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            Haptic.impact(.medium).generate()
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
        _window ?<< SKWindow(frame: UIScreen.main.bounds)
    }
    
    private static func rootVC(at index: Int) -> UIViewController? {
        guard let tabvc = _window?.rootViewController as? UITabBarController else { return nil }
        return (tabvc.viewControllers?[safe: index] as? UINavigationController)?.viewControllers.first
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
            logvc.log(string, level: level, tags: tags)
        }
        if Thread.isMainThread {
            ops()
        } else {
            DispatchQueue.main.async(execute: ops)
        }
    }
    public static func makeScreenOptions(_ make: (_ maker: SKSOptionHandler) -> Void) {
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
