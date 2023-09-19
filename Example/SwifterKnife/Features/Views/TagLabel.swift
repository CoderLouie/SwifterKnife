//
//  TagLabel.swift
//  BatterySwap
//
//  Created by 李阳 on 2023/9/15.
//

import UIKit
import SwifterKnife

class TagLabel: PaddingLabel {
    struct State: RawRepresentable, Hashable {
        let rawValue: Int
        
        static var normal: State {
            .init(rawValue: 0)
        }
        static var selected: State {
            .init(rawValue: 1)
        }
    }
    
    var contentInset: UIEdgeInsets {
        get { textInsets }
        set { textInsets = newValue }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func setup() {
//        addCorner()
        textInsets = .init(horizontal: 8, vertical: 4)
        
//        makeContentHard()
//        font = .medium12
        text = " "
        defaultNormalStyle()
    }
    private func defaultNormalStyle() {
//        backgroundColor = .secondary25
//        textColor = .secondaryDark
    }
    private func defaultSelectedStyle() {
//        backgroundColor = .accentBlue
//        textColor = .white
    }
    var state: State = .normal {
        didSet {
            guard state != oldValue else { return }
            if state == .normal {
                defaultNormalStyle()
            } else if state == .selected {
                defaultSelectedStyle()
            }
            guard let closures = config[state], !closures.isEmpty else {
                return
            }
            closures.forEach { $0(self) }
        }
    }
    
    var isSelected: Bool {
        get { state == .selected }
        set { state = newValue ? .selected : .normal }
    }
    var selectedBgColor: UIColor? {
        get { nil }
        set {
            config(for: .selected) {
                $0.backgroundColor = newValue
            }
        }
    }
    var title: String? {
        get { text }
        set { text = newValue }
    }
    
    private var config: [State: [(TagLabel) -> Void]] = [:]
    func config(for state: State, using closure: @escaping (TagLabel) -> Void) {
        config[state, default: []].append(closure)
        if self.state == state {
            closure(self)
        }
    }
}
