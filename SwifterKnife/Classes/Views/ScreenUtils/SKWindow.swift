//
//  SKWindow.swift
//  SwifterKnife
//
//  Created by liyang on 2024/12/22.
//

import UIKit


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
        
        
        container = UIView().then {
            $0.backgroundColor = UIColor(gray: 0, alpha: 0.8)
            $0.isHidden = true
            addSubview($0)
            $0.snp.makeConstraints { make in
                make.leading.bottom.trailing.equalToSuperview()
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
    
    private unowned var container: UIView!
    private unowned var popoverButton: UIButton!
    private lazy var contentEdge = CGRect(x: 0, y: Screen.safeAreaT, width: Screen.width, height: Screen.height - Screen.safeAreaT - Screen.safeAreaB).inset(by: .init(inset: 20.fit))
}

extension SKWindow {
    
    @objc private func handlePopoverTouchEvent() {
        container.isHidden.toggle()
//        textView.hiddenPopMenu()
    }
    @objc func longGestureAction(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            Haptic.impact(.medium).generate()
//            logWindow.isHidden = true
//            textView.hiddenPopMenu()
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

