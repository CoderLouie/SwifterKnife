//
//  TextField.swift
//  SwifterKnife
//
//  Created by liyang on 2022/6/29.
//

import UIKit

open class TextField: UITextField {
    public var insets: UIEdgeInsets = .zero {
        didSet {
            guard insets != oldValue else { return }
            setNeedsDisplay()
        }
    }
    
    open override func textRect(forBounds bounds: CGRect) -> CGRect {
        calculateTextRect(forRect: bounds)
    }
    open override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        calculateTextRect(forRect: bounds)
    }
    open override func editingRect(forBounds bounds: CGRect) -> CGRect {
        calculateTextRect(forRect: bounds)
    }
    
    private func calculateTextRect(forRect rect: CGRect) -> CGRect {
        var paddedRect = rect.inset(by: insets)
        if rightViewMode == .always ||
            rightViewMode == .whileEditing,
           let rightV = rightView {
            paddedRect.size.width -= rightV.frame.width
        }
        return paddedRect
    }
}


open class Input: UITextField {
    // Maximum length of text. 0 means no limit.
    open var maxLength: Int = 0
    
    public var onEditingEnd: ((Input) -> Void)?
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    @objc private func inputEnded() {
        onEditingEnd?(self)
    }
    open func setup() {
        delegate = self
        addTarget(self, action: #selector(inputEnded), for: .editingDidEnd)
        NotificationCenter.default.addObserver(self, selector: #selector(textDidChange), name: UITextField.textDidChangeNotification, object: self)
    }
    // Limit the length of text
    @objc private func textDidChange(notification: Notification) {
        guard let sender = notification.object as? Input, sender === self else { return }
        guard maxLength > 0,
              let text = text,
              markedTextRange == nil,
              text.count > maxLength else { return }
        let endIndex = text.index(text.startIndex, offsetBy: maxLength)
        self.text = String(text[..<endIndex])
        undoManager?.removeAllActions()
    }
}
extension Input: UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let type = textField.returnKeyType
        if type == .done ||
            type == .go ||
            type == .search ||
            type == .send {
            textField.resignFirstResponder()
        }
        return true
    }
}

