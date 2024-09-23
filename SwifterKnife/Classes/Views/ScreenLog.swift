//
//  ScreenLog.swift
//  SwifterKnife
//
//  Created by liyang on 2024/9/14.
//

import UIKit
import SnapKit
import SwifterKnife

extension UIWindow.Level {
    
    public static func + (lhs: UIWindow.Level, rhs: RawValue) -> UIWindow.Level {
        .init(rawValue: lhs.rawValue + rhs)
    }
}

fileprivate class ScreenLogWindow: UIWindow {
    override init(frame: CGRect) {
        super.init(frame: frame)
//        let level = UIWindow.Level.normal.rawValue + 9
        windowLevel = .alert + 5
        
        isHidden = true
        let view = screenLogView
        addSubview(view)
    }
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let res = super.hitTest(point, with: event)
        if res === self { return nil }
        if res === screenLogView {
            screenLogView.textView.hiddenPopMenu()
            return nil
        }
        return res
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate let screenLogView = ScreenLogView(frame: UIScreen.main.bounds)
fileprivate let logWindow = ScreenLogWindow(frame: UIScreen.main.bounds)

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
    private(set) lazy var address = unsafeBitCast(self, to: Int.self)
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
    override var normalTitleColor: UIColor { UIColor(gray: 255, alpha: 0.5) }
    override var selectedTitleColor: UIColor { .white }
    override var intrinsicContentSize: CGSize {
        CGSize(width: label.intrinsicContentSize.width + 20.fit, height: 30.fit)
    }
    override var isSelected: Bool {
        didSet {
            layer.borderColor = label.textColor.cgColor
        }
    }
    override func setup() {
        super.setup()
        addBorder(color: normalTitleColor, radius: 4, width: 1)
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
fileprivate class _PopMenuControl: _TitleControl {
    override var intrinsicContentSize: CGSize {
        CGSize(width: label.intrinsicContentSize.width + 20.fit, height: 30.fit)
    }
    override func setup() {
        super.setup()
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}
fileprivate class _MenuView: UIView {
    private var menus: [MenuItem] = []
    private var onChange: (() -> Void)?
    convenience init(menus: [MenuItem], onChange: @escaping () -> Void) {
        self.init(frame: .zero)
//        backgroundColor = .white
//        addCorner(radius: 4)
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
fileprivate class _PopMenu: UIView {
    private var onClick: ((Int) -> Void)?
    convenience init(onClick: @escaping (Int) -> Void) {
        self.init(frame: .zero)
        backgroundColor = .white
        addCorner(radius: 4)
        self.onClick = onClick
        
        let actions = ["删除行","全选","复制","复制行"]
        UIStackView.horizontal {
            actions.enumerated().map { (idx, title) in
                _PopMenuControl().then {
                    $0.tag = idx
                    $0.label.text = title
                    $0.addTarget(self, action: #selector(onMenuControlClick(_:)), for: .touchUpInside)
                }
            }
        }.do {
            $0.alignment = .fill
            $0.distribution = .fill
            addSubview($0)
            $0.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
    }
    @objc private func onMenuControlClick(_ sender: _MenuControl) {
        onClick?(sender.tag)
    }
}
fileprivate class _LogTextView: UITextView {
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setup()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        hiddenPopMenu()
    }
    private func setup() {
        backgroundColor = .clear
        tintColor = .create("#FFE500")
        textContainerInset = .zero
        textContainer.lineFragmentPadding = 0
        isEditable = false
        alwaysBounceVertical = true
        textColor = .white
        inputDelegate = self
    }
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }
    private(set) weak var popMenu: UIView?
    private var selectionChangedWorkItem: DispatchWorkItem?
    var selectedRect: CGRect? {
        guard let text = text as? NSString,
              text.length > 0 else { return nil }
        
        guard let textRange = selectedTextRange else {
            return nil
        }
        let rects = selectionRects(for: textRange)
        if rects.count == 1 {
            return rects[0].rect
        }
        let range = selectedRange
        guard range.isValid else { return nil }
        
        let rect1 = caretRect(for: textRange.start)
        let rect2 = caretRect(for: textRange.end)
        
        var origin: CGPoint = CGPoint(x: 0, y: rect1.minY)
        var size: CGSize = .zero
        if rect1.minY == rect2.minY {
            origin.x = rect1.minX
            size.width = rect2.minX - rect1.maxX
            size.height = rect1.height
        } else {
            origin.x = 0
            size.width = bounds.width
            size.height = rect2.maxY - rect1.minY
        }
        return CGRect(origin: origin, size: size)
    }
}

extension _LogTextView: UITextInputDelegate {
    @discardableResult
    func justHiddenPopMenu() -> Bool {
        guard popMenu != nil else { return false }
        popMenu?.removeFromSuperview()
        popMenu = nil
        return true
    }
    func hiddenPopMenu() {
        guard justHiddenPopMenu() else { return }
        let range = selectedRange
        if range.length == 0 { return }
        selectedRange = .zero
    }
    func textWillChange(_ textInput: UITextInput?) { }
    func textDidChange(_ textInput: UITextInput?) { }
    
    func selectionWillChange(_ textInput: UITextInput?) {
        justHiddenPopMenu()
    }
    func selectionDidChange(_ textInput: UITextInput?) {
        selectionChangedWorkItem?.cancel()
        let item = DispatchWorkItem { [weak self] in
            self?.textSelectionDidChange()
        }
        selectionChangedWorkItem = item
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: item)
    }
    private func textSelectionDidChange() {
        guard let rect = selectedRect, !rect.isEmpty else {
            justHiddenPopMenu()
            return
        }
         
        justHiddenPopMenu()
        let menuView = _PopMenu { [unowned self] tag in
            switch tag {
            case 0: screenLogView.deleteLine(nil)
            case 1:
                self.selectAll(nil)
                return
            case 2: self.copy(nil)
            case 3: screenLogView.copyLine(nil)
            default: break
            }
            self.hiddenPopMenu()
        }
        popMenu = PopContainer().then {
            $0.show(menuView, on: screenLogView, from: self, rect: rect, config: { _ in })
        }
    }
}
fileprivate class _PopContainer: UIView {
    override func didAddSubview(_ subview: UIView) {
        super.didAddSubview(subview)
        isHidden = false
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        removeSubviews()
        isHidden = true
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
            $0.isSelected = true
            $0.label.text = "Clear"
            $0.snp.makeConstraints { make in
                make.trailing.equalTo(-space)
                make.centerY.equalToSuperview()
            }
        }
        _ToolControl().do {
            toolbar.addSubview($0)
            $0.tag = 1
            $0.addTarget(self, action: #selector(toolbarButtonDidClick(_:)), for: .touchUpInside)
            $0.isSelected = true
            $0.label.text = "Prev"
            $0.snp.makeConstraints { make in
                make.trailing.equalTo(clearControl.snp.leading).offset(-space)
                make.centerY.equalToSuperview()
            }
        }
        let font = UIFont(name: "Menlo", size: 12)?.fit
        
        textView = _LogTextView().then {
            $0.font = font
            container.addSubview($0)
            $0.snp.makeConstraints { make in
                make.leading.trailing.equalToSuperview().inset(space)
                make.top.equalTo(space * 0.5)
                make.bottom.equalTo(toolbar.snp.top)
                make.height.equalTo(Screen.height * 0.4)
            }
        }
        popContainer = _PopContainer().then {
            $0.frame = bounds
            $0.backgroundColor = .clear
            $0.isHidden = true
            addSubview($0)
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
            
            longGes = UILongPressGestureRecognizer(target: self, action: #selector(longGestureAction(_:)))
            $0.addGestureRecognizer(longGes)
            panGes = UIPanGestureRecognizer(target: self, action: #selector(panGestureAction(_:)))
            $0.addGestureRecognizer(panGes)
            
            panGes.require(toFail: longGes)
        }
    }
    
    
    func copyLine(_ sender: Any?) {
        let items = selectedItems
        guard !items.isEmpty else { return }
        let log = items.map(\.content).joined(separator: "\n")
        log.copyToPasteboard()
    }
    func deleteLine(_ sender: Any?) {
        let items = selectedItems
        guard !items.isEmpty else { return }
        for i in items {
            for t in i.tags {
                if var map = itemTagMap[t] {
                    map.removeAll { $0 === i }
                    if map.isEmpty {
                        allTags.remove(t)
                        tagItems.removeAll { $0.title == t }
                    }
                    itemTagMap[t] = map
                }
            }
        }
        tagControl.isSelected = (tagItems.first(where: \.isSelected) != nil) ?? false
        
        let ptrs = Set(items.map(\.address))
        showingItems.removeAll { ptrs.contains($0.address) }
        self.items.removeAll { ptrs.contains($0.address) }
        textView.text = showingItems.map(\.content).joined(separator: "\n")
    }
    private var selectedItems: [ScreenLogItem] {
        let range = textView.selectedRange
        guard range.location != NSNotFound, range.length > 0 else { return [] }
        let r = (range.location..<range.location + range.length)
        var res: [ScreenLogItem] = []
        var current = 0
        for item in showingItems {
            let n = item.content.count
            let tmp = (current..<current + n)
            current += n
            if tmp.lowerBound >= r.upperBound { return res }
            if tmp.overlaps(r) {
                res.append(item)
            }
        }
        return res
    }
    
    private(set) var popContainer: _PopContainer!
    private var items: [ScreenLogItem] = []
    private var showingItems: [ScreenLogItem] = []
    private var itemTagMap: [String: [ScreenLogItem]] = [:]
    private var allTags: Set<String> = []
    private var levelItems: [MenuItem] = ScreenLogLevel.allCases.map { MenuItem(title: "\($0)") }
    private var tagItems: [MenuItem] = []
    
    private unowned var toolbar: UIView!
    private(set) unowned var textView: _LogTextView!
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
            itemTagMap[t, default: []].append(item)
            
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
        showingItems.append(item)
        if textView.text.isEmpty {
            textView.text = string
        } else {
            textView.text += "\n\(string)"
        }
    }
}


extension ScreenLogView {
    @objc private func handlePopoverTouchEvent() {
        container.isHidden.toggle()
        textView.hiddenPopMenu()
    }
    @objc private func toolbarButtonDidClick(_ sender: UIControl) {
        if sender === levelControl ||
            sender === tagControl {
            let isLevel = sender === levelControl
            let items = isLevel ? levelItems : tagItems
            let menuView = _MenuView(menus: items) { [unowned self] in
                self.onMenuSelectedItemChange()
            }
            PopContainer().show(menuView, on: popContainer, from: sender) { _ in }
        } else {
            if showingItems.isEmpty { return }
            if sender.tag == 0 {
                for i in showingItems {
                    for t in i.tags {
                        if var map = itemTagMap[t] {
                            map.removeAll { $0 === i }
                            if map.isEmpty {
                                allTags.remove(t)
                                tagItems.removeAll { $0.title == t }
                            }
                            itemTagMap[t] = map
                        }
                    }
                }
                tagControl.isSelected = (tagItems.first(where: \.isSelected) != nil) ?? false
                
                let ptrs = Set(showingItems.map(\.address))
                items.removeAll { ptrs.contains($0.address) }
                showingItems = []
//                levelItems.forEach { $0.isSelected = false }
                textView.text = ""
            } else if sender.tag == 1 {
                let n = showingItems.count
                let last = showingItems.removeLast()
                for t in last.tags {
                    if var map = itemTagMap[t] {
                        map.removeAll { $0 === last }
                        if map.isEmpty {
                            allTags.remove(t)
                            tagItems.removeAll { $0.title == t }
                        }
                        itemTagMap[t] = map
                    }
                }
                tagControl.isSelected = (tagItems.first(where: \.isSelected) != nil) ?? false
                items.removeAll { $0 === last }
                if let t = textView.text {
                    let n1 = last.content.count
                    // \n
                    let mapN = n == 1 ? n1 : n1 + 1
                    textView.text.removeLast(mapN)
                }
            }
        }
    }
    private func onMenuSelectedItemChange() {
        let selTags = Set(tagItems.filter(\.isSelected).map(\.title))
        tagControl.isSelected = !selTags.isEmpty
        let selLevels = Set(levelItems.filter(\.isSelected).map(\.title))
        levelControl.isSelected = !selLevels.isEmpty
        showingItems = items.filter {
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
            textView.hiddenPopMenu()
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

public enum ScreenLogLevel: Int, CaseIterable {
    case normal, info, warn, success, error
    
    public init(int: Int) {
        self = Self.init(rawValue: int) ?? .normal
    }
    public init<T: RawRepresentable>(raw: T) where T.RawValue == Int {
        self.init(int: raw.rawValue)
    }
}
public enum ScreenLog {
    public static func log(_ string: String, level: ScreenLogLevel = .normal, tags: [String] = []) {
        screenLogView.log(Console.timeString + " " + string, level: level, tags: tags)
    }
}
