//
//  LogViewController.swift
//  SwifterKnife
//
//  Created by liyang on 2025/4/11.
//

import UIKit



fileprivate class MenuItem {
    let title: String
    var isSelected: Bool = false
    init(title: String) {
        self.title = title
        self.isSelected = false
    }
}
fileprivate class LogItem {
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
            $0.font = .systemFont(ofSize: 12, weight: .regular)
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
    override var normalTitleColor: UIColor {
        UIColor.white.withAlphaComponent(0.5)
    }
    override var selectedTitleColor: UIColor { .white }
    override var intrinsicContentSize: CGSize {
        CGSize(width: label.intrinsicContentSize.width + 20, height: 30)
    }
    override var isSelected: Bool {
        didSet {
            layer.borderColor = label.textColor.cgColor
        }
    }
    override func setup() {
        super.setup()
        layer.do {
            $0.masksToBounds = true
            $0.cornerRadius = 4
            $0.borderWidth = 1
            $0.borderColor = normalTitleColor.cgColor
        }
        label.doConstraints { make in
            make.centerEqualTo(0)
        }
        do {
            let amount: Float = 50
            let axis: NSLayoutConstraint.Axis = .horizontal
            let val1 = contentHuggingPriority(for: axis).rawValue
            setContentHuggingPriority(.init(rawValue: val1 + amount), for: axis)
            let val2 = contentCompressionResistancePriority(for: axis).rawValue
            setContentCompressionResistancePriority(.init(rawValue: val2 + amount), for: axis)
        }
    }
}
fileprivate class _MenuControl: _TitleControl {
    override var intrinsicContentSize: CGSize {
        CGSize(width: 100, height: 30)
    }
    override func setup() {
        super.setup()
        label.doConstraints { make in
            make.leadingEqualTo(12)
            make.centerYEqualTo(0)
        }
    }
}
fileprivate class _PopMenuControl: _TitleControl {
    override var intrinsicContentSize: CGSize {
        CGSize(width: label.intrinsicContentSize.width + 20, height: 30)
    }
    override func setup() {
        super.setup()
        label.doConstraints { make in
//            make.center.equalToSuperview()
            make.centerEqualTo(0)
        }
    }
}
fileprivate class _MenuView: UIView {
    private var menus: [MenuItem] = []
    private var onChange: (() -> Void)?
    convenience init(menus: [MenuItem], onChange: @escaping () -> Void) {
        self.init(frame: .zero)
        self.menus = menus
        self.onChange = onChange
        
        UIStackView(arrangedSubviews: menus.enumerated().map { (idx, item) in
            _MenuControl().then {
                $0.tag = idx
                $0.isSelected = item.isSelected
                $0.label.text = item.title
                $0.addTarget(self, action: #selector(onMenuControlClick(_:)), for: .touchUpInside)
            }
        }).do { this in
            this.axis = .vertical
            this.alignment = .fill
            this.distribution = .fillEqually
            
            addSubview(this)
            this.doConstraints { make in
                make.edgesEqualTo(0)
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
//        addCorner(radius: 4)
        layer.do {
            $0.masksToBounds = true
            $0.cornerRadius = 4
        }
        self.onClick = onClick
        
        let actions = ["删除行","全选","复制","复制行"]
        UIStackView(arrangedSubviews: actions.enumerated().map { (idx, title) in
            _PopMenuControl().then {
                $0.tag = idx
                $0.label.text = title
                $0.addTarget(self, action: #selector(onMenuControlClick(_:)), for: .touchUpInside)
            }
        }).do {
            $0.axis = .horizontal
            $0.alignment = .fill
            $0.distribution = .fill
            addSubview($0)
            $0.doConstraints { make in
                make.edgesEqualTo(0)
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
        tintColor = UIColor(red: 255 / 255.0, green: 229 / 255.0, blue: 0 / 255.0, alpha: 1)
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
        guard range.location != NSNotFound,
              range.length > 0 else { return nil }
        
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
    @available(iOS 18.4, *)
    func conversationContext(_ context: UIConversationContext?, didChange textInput: (any UITextInput)?) {
    }
    
    @discardableResult
    func justHiddenPopMenu() -> Bool {
        guard popMenu != nil else { return false }
        popMenu?.removeFromSuperview()
        popMenu = nil
        return true
    }
    @discardableResult
    func hiddenPopMenu() -> Bool {
        guard justHiddenPopMenu() else { return false }
        let range = selectedRange
        if range.length == 0 { return false }
        selectedRange = NSRange(location: 0, length: 0)
        return true
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
        justHiddenPopMenu()
        guard let rect = selectedRect, !rect.isEmpty else {
            return
        }
         
        let menuView = _PopMenu { [unowned self] tag in
            switch tag {
            case 0: self.logView?.deleteLine(nil)
            case 1:
                self.selectAll(nil)
                return
            case 2: self.copy(nil)
            case 3: self.logView?.copyLine(nil)
            default: break
            }
            self.hiddenPopMenu()
        }
        popMenu = PopContainer().then {
            $0.backgroundColor = .white
            $0.show(menuView, on: logView!, from: self, rect: rect, config: { _ in })
        }
    }
    private var logView: _LogView? {
        superview as? _LogView
    }
}
fileprivate class _PopContainer: UIView {
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        removeFromSuperview()
    }
}
fileprivate class _LogView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func setup() {
        let toolbar = UIView().then {
            addSubview($0)
            $0.doConstraints { make in
                make.horizontalEqualTo(0)
                make.bottomEqualTo(0)
                make.heightEqualTo(44)
            }
        }
        let space: CGFloat = 12
        levelControl = _ToolControl().then {
            toolbar.addSubview($0)
            $0.addTarget(self, action: #selector(toolbarButtonDidClick(_:)), for: .touchUpInside)
            $0.label.text = "Level"
            $0.doConstraints { make in
                make.leadingEqualTo(space)
                make.centerYEqualTo(0)
            }
        }
        tagControl = _ToolControl().then {
            toolbar.addSubview($0)
            $0.addTarget(self, action: #selector(toolbarButtonDidClick(_:)), for: .touchUpInside)
            $0.label.text = "Tag"
            $0.doConstraints { make in
                make.son.leadingAnchor.constraint(equalTo: levelControl.trailingAnchor, constant: space)
                make.centerYEqualTo(0)
            }
        }
        let clearControl = _ToolControl().then {
            toolbar.addSubview($0)
            $0.addTarget(self, action: #selector(toolbarButtonDidClick(_:)), for: .touchUpInside)
            $0.isSelected = true
            $0.label.text = "Clear"
            $0.doConstraints { make in
                make.trailingEqualTo(-space)
                make.centerYEqualTo(0)
            }
        }
        _ToolControl().do {
            toolbar.addSubview($0)
            $0.tag = 1
            $0.addTarget(self, action: #selector(toolbarButtonDidClick(_:)), for: .touchUpInside)
            $0.isSelected = true
            $0.label.text = "Prev"
            $0.doConstraints { make in
                make.son.trailingAnchor.constraint(equalTo: clearControl.leadingAnchor, constant: -space)
                make.centerYEqualTo(0)
            }
        }
        let font = UIFont(name: "Menlo", size: 12)
        
        textView = _LogTextView().then {
            $0.font = font
            addSubview($0)
            $0.doConstraints { make in
                make.horizontalEqualTo(space)
                make.topEqualTo(space * 0.5)
                make.son.bottomAnchor.constraint(equalTo: toolbar.topAnchor)
            }
        }
    }
    
    
    func copyLine(_ sender: Any?) {
        let items = selectedItems
        guard !items.isEmpty else { return }
        let log = items.map(\.content).joined(separator: "\n")
        UIPasteboard.general.string = log
    }
    func deleteLine(_ sender: Any?) {
        let items = selectedItems
        guard !items.isEmpty else { return }
        for i in items {
            for t in i.tags {
                if var array = itemTagMap[t] {
                    array.removeAll { $0 === i }
                    if array.isEmpty {
                        allTags.remove(t)
                        tagItems.removeAll { $0.title == t }
                        itemTagMap[t] = nil
                    } else {
                        itemTagMap[t] = array
                    }
                    
                }
            }
        }
        tagControl.isSelected = tagItems.contains(where: \.isSelected)
        
        let ptrs = Set(items.map(\.address))
        showingItems.removeAll { ptrs.contains($0.address) }
        self.items.removeAll { ptrs.contains($0.address) }
        textView.text = showingItems.map(\.content).joined(separator: "\n")
    }
    private var selectedItems: [LogItem] {
        let range = textView.selectedRange
        guard range.location != NSNotFound,
              range.length > 0 else { return [] }
        let r = (range.location..<range.location + range.length)
        var res: [LogItem] = []
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
     
    private var items: [LogItem] = []
    private var showingItems: [LogItem] = []
    private var itemTagMap: [String: [LogItem]] = [:]
    private var allTags: Set<String> = []
    private let levelItems = ScreenLogLevel.allCases.map { MenuItem(title: "\($0)") }
    private var tagItems: [MenuItem] = []
     
    private(set) unowned var textView: _LogTextView!
    private unowned var tagControl: UIControl!
    private unowned var levelControl: UIControl!
}
extension _LogView {
    func log(_ string: String, level: ScreenLogLevel = .normal, tags: [String] = []) {
        let item = LogItem(tags: tags, level: level, content: string)
        items.append(item)
        
        for t in item.tags.sorted() {
            itemTagMap[t, default: []].append(item)
            
            if allTags.contains(t) { continue }
            allTags.insert(t)
            tagItems.append(MenuItem(title: t))
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


extension _LogView {
    @objc private func toolbarButtonDidClick(_ sender: UIControl) {
        if sender === levelControl ||
            sender === tagControl {
            let isLevel = sender === levelControl
            let items = isLevel ? levelItems : tagItems
            guard !items.isEmpty else { return }
            let menuView = _MenuView(menus: items) { [unowned self] in
                self.onMenuSelectedItemChange()
            }
            let container = _PopContainer().then {
                $0.frame = bounds
                $0.backgroundColor = .clear
                addSubview($0)
            }
            PopContainer().do {
                $0.backgroundColor = .white
                $0.show(menuView, on: container, from: sender) { _ in }
            }
        } else {
            if showingItems.isEmpty { return }
            if sender.tag == 0 { // clear
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
                tagControl.isSelected = tagItems.contains(where: \.isSelected)
                
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
                tagControl.isSelected = tagItems.contains(where: \.isSelected)
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

fileprivate enum _Times {
    private static let dataFmt: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = .init(identifier: "Asia/Shanghai")
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter
    }()
    static var now: String {
        return dataFmt.string(from: Date())
    }
}
class LogViewController: _BaseViewController {
    func log(_ string: String, level: ScreenLogLevel = .normal, tags: [String] = []) {
        logView.log(_Times.now + " " + string, level: level, tags: tags)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logView.do {
            view.addSubview($0)
            $0.doConstraints { make in 
                make.horizontalEqualTo(0)
                make.bottomEqualTo(-Screen.tabbarH - 20)
                make.topEqualTo(Screen.navbarH + 20)
            }
        }
    }
    private var logView = _LogView()
}
 

