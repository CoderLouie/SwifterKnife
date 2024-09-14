//
//  ScreenLog.swift
//  SwifterKnife
//
//  Created by liyang on 2024/9/14.
//

import UIKit
import SnapKit
import SwifterKnife


fileprivate class ScreenLogWindow: UIWindow {
    override init(frame: CGRect) {
        super.init(frame: frame)
        windowLevel = UIWindow.Level.init(UIWindow.Level.alert.rawValue + 5)
    }
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let res = super.hitTest(point, with: event)
        if res === self { return nil }
        if res === rootViewController?.view.superview { return nil }
        return res
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate let logWindow: UIWindow = {
    let frame = UIScreen.main.bounds
    let window = ScreenLogWindow(frame: frame)
    window.isHidden = true
    let view = ScreenLogView(frame: frame)
    window.addSubview(view)
    return window
}()
fileprivate var screenLogView: ScreenLogView {
    logWindow.subviews.first as! ScreenLogView
}

public enum ScreenLogLevel: CaseIterable {
    case error, info, normal, warn
}
fileprivate class MenuItem {
    let title: String
    var isSelected: Bool = false
    init(title: String) {
        self.title = title
        self.isSelected = false
    }
}
fileprivate class ScreenLogItem {
    let tags: Set<String>
    let level: ScreenLogLevel
    let content: String
    
    init(tags: [String], level: ScreenLogLevel, content: String) {
        self.tags = tags.isEmpty ? ["Default"] : Set(tags)
        self.level = level
        self.content = content
    }
}

fileprivate class _TitleControl: UIControl {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setup() {
        label = UILabel().then {
            addSubview($0)
            $0.font = .regular(12).fit
            $0.textColor = normalTitleColor
        }
    }
    var normalTitleColor: UIColor { .black }
    var selectedTitleColor: UIColor { .red }
    override var isSelected: Bool {
        didSet {
            label.textColor = isSelected ? selectedTitleColor : normalTitleColor
        }
    }
    private(set) unowned var label: UILabel!
}

fileprivate class _ToolControl: _TitleControl {
    override var normalTitleColor: UIColor { UIColor(gray: 255, alpha: 0.7) }
    override var selectedTitleColor: UIColor { .white }
    override var intrinsicContentSize: CGSize {
        CGSize(width: label.intrinsicContentSize.width + 20.fit, height: 30.fit)
    }
    override func setup() {
        super.setup()
        addBorder(color: UIColor(gray: 255, alpha: 0.7), radius: 4, width: 1)
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        increaseContentPriority(50, for: .horizontal)
    }
}
fileprivate class _MenuControl: _TitleControl {
    override var intrinsicContentSize: CGSize {
        CGSize(width: 100.fit, height: 30.fit)
    }
    override func setup() {
        super.setup()
        label.snp.makeConstraints { make in
            make.leading.equalTo(12.fit)
            make.centerY.equalToSuperview()
        }
    }
}
fileprivate class _MenuView: UIView {
    private var menus: [MenuItem] = []
    private var onChange: (() -> Void)?
    convenience init(menus: [MenuItem], onChange: @escaping () -> Void) {
        self.init(frame: .zero)
        backgroundColor = .white
        addCorner(radius: 4)
        self.menus = menus
        self.onChange = onChange
        
        UIStackView.vertical {
            menus.enumerated().map { (idx, item) in
                _MenuControl().then {
                    $0.tag = idx
                    $0.isSelected = item.isSelected
                    $0.label.text = item.title
                    $0.addTarget(self, action: #selector(onMenuControlClick(_:)), for: .touchUpInside)
                }
            }
        }.do {
            $0.alignment = .fill
            $0.distribution = .fillEqually
            addSubview($0)
            $0.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
    }
    @objc private func onMenuControlClick(_ sender: _MenuControl) {
        sender.isSelected.toggle()
        menus[sender.tag].isSelected = sender.isSelected
        onChange?()
    }
}
fileprivate class ScreenLogView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func setup() {
        container = UIView().then {
            $0.backgroundColor = UIColor(gray: 0, alpha: 0.8)
            $0.isHidden = true
            addSubview($0)
            $0.snp.makeConstraints { make in
                make.leading.bottom.trailing.equalToSuperview()
            }
        }
        toolbar = UIView().then {
            container.addSubview($0)
            $0.snp.makeConstraints { make in
                make.leading.trailing.equalToSuperview()
                make.bottom.equalTo(-Screen.safeAreaB)
                make.height.equalTo(44.fit)
            }
        }
        let space = 12.fit
        levelControl = _ToolControl().then {
            toolbar.addSubview($0)
            $0.addTarget(self, action: #selector(toolbarButtonDidClick(_:)), for: .touchUpInside)
            $0.label.text = "Level"
            $0.snp.makeConstraints { make in
                make.leading.equalTo(space)
                make.centerY.equalToSuperview()
            }
        }
        tagControl = _ToolControl().then {
            toolbar.addSubview($0)
            $0.addTarget(self, action: #selector(toolbarButtonDidClick(_:)), for: .touchUpInside)
            $0.label.text = "Tag"
            $0.snp.makeConstraints { make in
                make.leading.equalTo(levelControl.snp.trailing).offset(space)
                make.centerY.equalToSuperview()
            }
        }
        let clearControl = _ToolControl().then {
            toolbar.addSubview($0)
            $0.addTarget(self, action: #selector(toolbarButtonDidClick(_:)), for: .touchUpInside)
            $0.label.text = "Clear"
            $0.snp.makeConstraints { make in
                make.trailing.equalTo(-space)
                make.centerY.equalToSuperview()
            }
        }
        let font = UIFont(name: "Menlo", size: 12)?.fit
//        UITextField().do {
//            $0.font = font
//            $0.textColor = .white
//            toolbar.addSubview($0)
//            $0.borderStyle = .line
//            $0.attributedPlaceholder = NSAttributedString(string: "Search...", attributes: [.foregroundColor: UIColor(gray: 255, alpha: 0.8), .font: font])
//            $0.isEnabled = false
//            $0.snp.makeConstraints { make in
//                make.leading.equalTo(tagControl.snp.trailing).offset(space)
//                make.trailing.equalTo(clearControl.snp.leading).offset(-space)
//                make.height.equalTo(30.fit)
//                make.centerY.equalToSuperview()
//            }
//        }
        
        textView = UITextView().then {
            $0.font = font
            $0.isEditable = false
            $0.backgroundColor = .clear
            $0.alwaysBounceVertical = true
            $0.textColor = .white
            container.addSubview($0)
            $0.snp.makeConstraints { make in
                make.top.leading.trailing.equalToSuperview().inset(space)
                make.bottom.equalTo(toolbar.snp.top)
                make.height.equalTo(Screen.height * 0.4)
            }
        }
        popoverButton = UIButton().then {
            addSubview($0)
            $0.frame.size = CGSize(width: 32, height: 32).fit
            $0.center = CGPoint(x: 50.fit, y: Screen.height * 0.7)
            $0.backgroundColor = UIColor(gray: 0, alpha: 0.5)
            $0.addBorder(color: UIColor(gray: 255, alpha: 0.7), radius: 16.fit, width: 1)
            $0.addTarget(self, action: #selector(handlePopoverTouchEvent), for: .touchUpInside)
            
            longGes = UILongPressGestureRecognizer(target: self, action: #selector(longGestureAction(_:)))
            $0.addGestureRecognizer(longGes)
            panGes = UIPanGestureRecognizer(target: self, action: #selector(panGestureAction(_:)))
            $0.addGestureRecognizer(panGes)
            
            panGes.require(toFail: longGes)
        }
    }
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let res = super.hitTest(point, with: event)
        if let r = res, let m = menuView, !r.isDescendant(of: m) {
            menuView?.removeFromSuperview()
            menuView = nil
            return self
        }
        if res === self { return nil }
        return res
    }
    private var menuView: _MenuView?
    private var items: [ScreenLogItem] = []
    private var allTags: Set<String> = []
    private var levelItems: [MenuItem] = ScreenLogLevel.allCases.map { MenuItem(title: "\($0)") }
    private var tagItems: [MenuItem] = []
    
    private unowned var toolbar: UIView!
    private unowned var textView: UITextView!
    private unowned var tagControl: UIControl!
    private unowned var levelControl: UIControl!
    private var longGes: UILongPressGestureRecognizer!
    private var panGes: UIPanGestureRecognizer!
    private unowned var popoverButton: UIButton!
    private unowned var container: UIView!
    private lazy var contentEdge = CGRect(x: 0, y: Screen.safeAreaT, width: Screen.width, height: Screen.height - Screen.safeAreaT - Screen.safeAreaB).inset(by: .init(inset: 20.fit))
}
extension ScreenLogView {
    func log(_ string: String, level: ScreenLogLevel = .normal, tags: [String] = []) {
        let item = ScreenLogItem(tags: tags, level: level, content: string)
        items.append(item)
        
        for t in item.tags.sorted() {
            if allTags.contains(t) { continue }
            allTags.insert(t)
            tagItems.append(MenuItem(title: t))
        }
        if logWindow.isHidden {
            logWindow.isHidden = false
        }
        
        let selLevels = Set(levelItems.filter(\.isSelected).map(\.title))
        if !selLevels.isEmpty, !selLevels.contains("\(item.level)") { return }
        let selTags = Set(tagItems.filter(\.isSelected).map(\.title))
        if !selTags.isEmpty, item.tags.intersection(selTags).isEmpty { return }
        if textView.text.isEmpty {
            textView.text += string
        } else {
            textView.text += "\n\(string)"
        }
    }
}


extension ScreenLogView {
    @objc private func handlePopoverTouchEvent() {
        container.isHidden.toggle()
    }
    @objc private func toolbarButtonDidClick(_ sender: UIControl) {
        if sender === levelControl ||
            sender == tagControl {
            let isLevel = sender === levelControl
            let items = isLevel ? levelItems : tagItems
            menuView = _MenuView(menus: items) { [unowned self] in
                self.onMenuSelectedItemChange(isLevel)
            }.then {
                addSubview($0)
                $0.snp.makeConstraints { make in
                    make.leading.equalTo(isLevel ? 0 : 30.fit)
                    make.bottom.equalTo(-Screen.safeAreaB - 44.fit)
                }
            }
        } else {
            allTags = []
            tagItems = []
            levelItems.forEach { $0.isSelected = false }
            textView.text = ""
        }
    }
    private func onMenuSelectedItemChange(_ isLevel: Bool) {
        let selTags = Set(tagItems.filter(\.isSelected).map(\.title))
        let selLevels = Set(levelItems.filter(\.isSelected).map(\.title))
        let showingItems = items.filter {
            if !selTags.isEmpty, $0.tags.intersection(selTags).isEmpty { return false }
            if !selLevels.isEmpty, !selLevels.contains("\($0.level)") { return false }
            return true
        }
        textView.text = showingItems.map(\.content).joined(separator: "\n")
    }
    
    @objc func longGestureAction(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            Haptic.impact(.medium).generate()
            logWindow.isHidden = true
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

public enum ScreenLog {
    public static func log(_ string: String, level: ScreenLogLevel = .normal, tags: [String] = []) {
        screenLogView.log(string, level: level, tags: tags)
    }
}
