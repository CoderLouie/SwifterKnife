//
//  NSAttributedString+Add.swift
//  SwifterKnife
//
//  Created by 李阳 on 2022/8/24.
//

import Foundation
import UIKit

extension NSMutableAttributedString {
    public enum AttributedComponent {
        case link(URL?)
        
        case font(UIFont?)
        case kern(Double?)
        case color(UIColor?)
        case backgroundColor(UIColor?)
        case strokeColor(UIColor?)
        case strokeWidth(Double?)
        case shadow(NSShadow?)
        
        case strikethroughStyle(NSUnderlineStyle?)
        case strikethroughColor(UIColor?)
        case underlineStyle(NSUnderlineStyle?)
        case underlineColor(UIColor?)
        case ligature(Double?)
        
        case baselineOffset(Double?)
        case verticalGlyphForm(Bool?)
        
        case paragraphStyle(NSParagraphStyle?)
        
        var key: NSMutableAttributedString.Key {
            switch self {
            case .link: return .link
            case .font: return .font
            case .kern: return .kern
            case .color: return .foregroundColor
            case .backgroundColor: return .backgroundColor
            case .strokeColor: return .strokeColor
            case .strokeWidth: return .strokeWidth
            case .shadow: return .shadow
            case .strikethroughStyle: return .strikethroughStyle
            case .strikethroughColor: return .strikethroughColor
            case .underlineStyle: return .underlineStyle
            case .underlineColor: return .underlineColor
            case .ligature: return .ligature
            case .baselineOffset: return .baselineOffset
            case .verticalGlyphForm: return .verticalGlyphForm
            case .paragraphStyle: return .paragraphStyle
            }
        }
        var value: Any? {
            switch self {
            case .link(let url): return url
            case .font(let font): return font
            case .kern(let v): return v.map { NSNumber(floatLiteral: $0) }
            case .color(let color): return color
            case .backgroundColor(let color): return color
            case .strokeColor(let color): return color
            case .strokeWidth(let v): return v.map { NSNumber(floatLiteral: $0) }
            case .shadow(let s): return s
            case .strikethroughStyle(let style): return style
            case .strikethroughColor(let color): return color
            case .underlineStyle(let style): return style
            case .underlineColor(let color): return color
            case .ligature(let v): return v.map { NSNumber(floatLiteral: $0) }
            case .baselineOffset(let v): return v.map { NSNumber(floatLiteral: $0) }
            case .verticalGlyphForm(let flag): return flag
            case .paragraphStyle(let style): return style
            }
        }
    }
    public var fullNSRange: NSRange {
        NSRange(string.startIndex..<string.endIndex, in: string)
    }
    public func nsrange(of string: String) -> NSRange? {
        guard let r = self.string.range(of: string) else { return nil }
        return NSRange(r, in: self.string)
    }
    public func addAttribute(_ component: AttributedComponent,
                             target substring: String? = nil) {
        let key = component.key
        let range = substring.flatMap {
            self.nsrange(of: $0)
        } ?? fullNSRange
        if let value = component.value {
            addAttribute(key, value: value, range: range)
        } else {
            removeAttribute(key, range: range)
        }
    }
}
