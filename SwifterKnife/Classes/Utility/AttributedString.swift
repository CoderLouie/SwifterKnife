//
//  AttributedString.swift
//  SwifterKnife
//
//  Created by liyang on 2023/1/6.
//

import Foundation

public extension NSString { 
    func allRange(of searchString: String) -> [NSRange] {
        let length = self.length
        guard length > 0 else { return [] }
        var range = NSRange(location: 0, length: length)
        var res: [NSRange] = []
        while range.location != NSNotFound {
            range = self.range(of: searchString, range: range)
            if range.location != NSNotFound {
                res.append(NSRange(location: range.location, length: range.length))
                let total = range.location + range.length
                range.location = total
                range.length = length - total
            }
        }
        return res
    }
}

public extension NSAttributedString {
    func aspectFitSize(with limitSize: CGSize) -> CGSize {
        let rect = boundingRect(with: limitSize, options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil)
        let res = rect.size.adaptive(tramsform: \.pixCeil)
        return res
    }
    func aspectFitSize(for maxWidth: CGFloat) -> CGSize {
        aspectFitSize(with: CGSize(width: maxWidth, height: .greatestFiniteMagnitude))
    }
    func aspectFitHeight(for maxWidth: CGFloat) -> CGFloat {
        aspectFitSize(for: maxWidth).height
    }
    func aspectFitWidth(for font: UIFont) -> CGFloat {
        let size = CGSize(width: CGFloat.greatestFiniteMagnitude,
                          height: CGFloat.greatestFiniteMagnitude)
        return aspectFitSize(with: size).width
    }
    
}

// https://github.com/Nirma/Attributed.git

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
public extension NSMutableAttributedString {
    func modified(for substring: String, using closure: (Attributes) -> Void) -> NSMutableAttributedString {
        guard let range = string.range(of: substring) else {
            return self
        }
        let nsrange = NSRange(range, in: string)
        let attr = Attributes()
        closure(attr)
        addAttributes(attr.dictionary, range: nsrange)
        return self
    }
}

public func + (lhs: NSAttributedString, rhs: NSAttributedString) -> NSAttributedString {
    let result = NSMutableAttributedString()
    result.append(lhs)
    result.append(rhs)
    return NSAttributedString(attributedString: result)
}
public func + (lhs: NSAttributedString, rhs: String) -> NSAttributedString {
    let result = NSMutableAttributedString(attributedString: lhs)
    result.append(.init(string: rhs))
    return NSAttributedString(attributedString: result)
}

public extension String {
    var build: NSMutableAttributedString {
        NSMutableAttributedString(string: self)
    } 
    func build(with attributes: Attributes) -> NSAttributedString {
        NSAttributedString(string: self, attributes: attributes.dictionary)
    }
    func build(with closure: (Attributes) -> Void) -> NSAttributedString {
        let attr = Attributes.one
        closure(attr)
        return NSAttributedString(string: self, attributes: attr.dictionary)
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
    
    public var copied: Attributes {
        let copied = Attributes()
        copied.dictionary = dictionary
        return copied
    }
    
    public func apply(_ string: String) -> NSAttributedString {
        NSAttributedString(string: string, attributes: dictionary)
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
    func fgColor(_ color: UIColor) -> Attributes {
        dictionary[.foregroundColor] = color
        return self
    }
    
    @discardableResult
    func bgColor(_ color: UIColor) -> Attributes {
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

@resultBuilder
public enum AttributedStringBuilder {
    public static func buildBlock(_ components: NSAttributedString...) -> NSAttributedString {
        components.reduce(into: NSMutableAttributedString()) {
            $0.append($1)
        }
    }
    public static func buildOptional(_ component: NSAttributedString?) -> NSAttributedString {
        component ?? NSAttributedString(string: "")
    }
    
    public static func buildEither(first component: NSAttributedString) -> NSAttributedString {
        component
    }
    
    public static func buildEither(second component: NSAttributedString) -> NSAttributedString {
        component
    }
    
    public static func buildArray(_ components: [NSAttributedString]) -> NSAttributedString {
        components.reduce(into: NSMutableAttributedString()) {
            $0.append($1)
        }
    }
    
    public static func buildExpression(_ expression: String) -> NSAttributedString {
        NSAttributedString(string: expression)
    }
    
    public static func buildExpression(_ expression: NSAttributedString) -> NSAttributedString {
        expression
    }
}


public func attributed(@AttributedStringBuilder body: () -> NSAttributedString) -> NSAttributedString {
    body() 
}
