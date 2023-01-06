//
//  AttributedString.swift
//  SwifterKnife
//
//  Created by liyang on 2023/1/6.
//

import Foundation

// https://github.com/Nirma/Attributed.git

public struct Attributed<Base> {
    let base: Base
    public init(_ base: Base) {
        self.base = base
    }
}
public protocol AttributedCompatible {
    associatedtype CompatibleType

    var at: Attributed<CompatibleType> { get }
}

public extension AttributedCompatible {
    var at: Attributed<Self> {
        return Attributed(self)
    }
}
extension String: AttributedCompatible { }
extension NSString: AttributedCompatible { }

extension Attributed where Base == String {
    public func build(with attributes: Attributes) -> NSAttributedString {
        NSAttributedString(string: base, attributes: attributes.dictionary)
    }
    public func build(_ attributeBlock: (Attributes) -> Void) -> NSAttributedString {
        let attributes = Attributes()
        attributeBlock(attributes)
        return NSAttributedString(string: base, attributes: attributes.dictionary)
    }
}
extension Attributed where Base == NSString {
    public func build(with attributes: Attributes) -> NSAttributedString {
        (base as String).at.build(with: attributes)
    }
    public func build(_ attributeBlock: (Attributes) -> Void) -> NSAttributedString {
        (base as String).at.build(attributeBlock)
    }
}

public extension NSAttributedString {
    
    func modified(with attributes: Attributes, for range: NSRange) -> NSAttributedString {

        let result = NSMutableAttributedString(attributedString: self)
        result.addAttributes(attributes.dictionary, range: range)
        return NSAttributedString(attributedString: result)
    }
    
    func modified(with attributes: Attributes, for substring: String) -> NSAttributedString {
        guard let range = string.range(of: substring) else {
            return self
        }
        let nsrange = NSRange(range, in: string)
        return modified(with: attributes, for: nsrange)
    }
}

public final class Attributes {
    public private(set) var dictionary: [NSAttributedString.Key: Any]
    
    public init() {
        dictionary = [:]
    }
    
    public static var one: Attributes {
        return Attributes()
    }
}

public extension Attributes {
    
    @discardableResult
    func font(_ font: UIFont) -> Attributes {
        dictionary[.font] = font
        return self
    }
    
    @discardableResult
    func kerning(_ kerning: Double) -> Attributes {
        dictionary[.kern] = NSNumber(floatLiteral: kerning)
        return self
    }
    
    @discardableResult
    func strikeThroughStyle(_ strikeThroughStyle: NSUnderlineStyle) -> Attributes {
        dictionary[.strikethroughStyle] = strikeThroughStyle.rawValue
        dictionary[.baselineOffset] = NSNumber(floatLiteral: 1.5)
        return self
    }
    
    @discardableResult
    func underlineStyle(_ underlineStyle: NSUnderlineStyle) -> Attributes {
        dictionary[.underlineStyle] = underlineStyle.rawValue
        return self
    }
    
    @discardableResult
    func strokeColor(_ strokeColor: UIColor) -> Attributes {
        dictionary[.strokeColor] = strokeColor
        return self
    }
    
    @discardableResult
    func strokeWidth(_ strokewidth: Double) -> Attributes {
        dictionary[.strokeWidth] = NSNumber(floatLiteral: strokewidth)
        return self
    }
    
    @discardableResult
    func foreground(color: UIColor) -> Attributes {
        dictionary[.foregroundColor] = color
        return self
    }
    
    @discardableResult
    func background(color: UIColor) -> Attributes {
        dictionary[.backgroundColor] = color
        return self
    }
    
    @discardableResult
    func paragraphStyle(_ paragraphStyle: NSParagraphStyle) -> Attributes {
        dictionary[.paragraphStyle] = paragraphStyle
        return self
    }
    
    @discardableResult
    func shadow(_ shadow: NSShadow) -> Attributes {
        dictionary[.shadow] = shadow
        return self
    }
    
    @discardableResult
    func obliqueness(_ value: CGFloat) -> Attributes {
        dictionary[.obliqueness] = value
        return self
    }
    
    @discardableResult
    func link(_ link: String) -> Attributes {
        dictionary[.link] = link
        return self
    }
    
    @discardableResult
    func baselineOffset(_ offset: NSNumber) -> Attributes {
        dictionary[.baselineOffset] = offset
        return self
    }
}


// MARK: NSParagraphStyle related

public extension Attributes {
    
    private func modifyParagraphStyle(_ closure: (NSMutableParagraphStyle) -> Void) -> Attributes {
        let paragraphStyle = (dictionary[.paragraphStyle] ?? NSMutableParagraphStyle.default.mutableCopy()) as! NSMutableParagraphStyle
        closure(paragraphStyle)
        dictionary[.paragraphStyle] = paragraphStyle
        return self
    }
    @discardableResult
    func lineSpacing(_ lineSpacing: CGFloat) -> Attributes {
        modifyParagraphStyle {
            $0.lineSpacing = lineSpacing
        }
    }
    
    @discardableResult
    func paragraphSpacing(_ paragraphSpacing: CGFloat) -> Attributes {
        modifyParagraphStyle {
            $0.paragraphSpacing = paragraphSpacing
        }
    }
    
    @discardableResult
    func alignment(_ alignment: NSTextAlignment) -> Attributes {
        modifyParagraphStyle {
            $0.alignment = alignment
        }
    }
    
    @discardableResult
    func firstLineHeadIndent(_ firstLineHeadIndent: CGFloat) -> Attributes {
        modifyParagraphStyle {
            $0.firstLineHeadIndent = firstLineHeadIndent
        }
    }
    
    @discardableResult
    func headIndent(_ headIndent: CGFloat) -> Attributes {
        modifyParagraphStyle {
            $0.headIndent = headIndent
        }
    }
    
    @discardableResult
    func tailIndent(_ tailIndent: CGFloat) -> Attributes {
        modifyParagraphStyle {
            $0.tailIndent = tailIndent
        }
    }
    
    @discardableResult
    func lineBreakMode(_ lineBreakMode: NSLineBreakMode) -> Attributes {
        modifyParagraphStyle {
            $0.lineBreakMode = lineBreakMode
        }
    }
    
    @discardableResult
    func minimumLineHeight(_ minimumLineHeight: CGFloat) -> Attributes {
        modifyParagraphStyle {
            $0.minimumLineHeight = minimumLineHeight
        }
    }
    
    @discardableResult
    func maximumLineHeight(_ maximumLineHeight: CGFloat) -> Attributes {
        modifyParagraphStyle {
            $0.maximumLineHeight = maximumLineHeight
        }
    }
    
    @discardableResult
    func uniformLineHeight(_ uniformLineHeight: CGFloat) -> Attributes {
        modifyParagraphStyle {
            $0.maximumLineHeight = uniformLineHeight
            $0.minimumLineHeight = uniformLineHeight
        }
    }
    
    @discardableResult
    func baseWritingDirection(_ baseWritingDirection: NSWritingDirection) -> Attributes {
        modifyParagraphStyle {
            $0.baseWritingDirection = baseWritingDirection
        }
    }
    
    @discardableResult
    func lineHeightMultiple(_ lineHeightMultiple: CGFloat) -> Attributes {
        modifyParagraphStyle {
            $0.lineHeightMultiple = lineHeightMultiple
        }
    }
    
    @discardableResult
    func paragraphSpacingBefore(_ paragraphSpacingBefore: CGFloat) -> Attributes {
        modifyParagraphStyle {
            $0.paragraphSpacingBefore = paragraphSpacingBefore
        }
    }
    
    @discardableResult
    func hyphenationFactor(_ hyphenationFactor: Float) -> Attributes {
        modifyParagraphStyle {
            $0.hyphenationFactor = hyphenationFactor
        }
    }
}
