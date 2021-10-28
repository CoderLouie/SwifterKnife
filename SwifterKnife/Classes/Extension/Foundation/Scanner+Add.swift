//
//  Scanner+Add.swift
//  SwifterKnife
//
//  Created by liyang on 2021/10/19.
//

import Foundation

public extension Scanner {
    // 方便 Debug时查看当前扫描到哪里了
    func peek(range: ClosedRange<Int>) -> String? {
        let i = scanLocation
        return string[safe: i+range.lowerBound...i+range.upperBound]
    }
    
    @discardableResult
    func move(to string: String) -> String? {
        var result: NSString? = nil
        while !isAtEnd {
            if scanString(string, into: &result) {
                return result as String?
            }
            scanLocation += 1
        }
        return nil
    }
    
    @discardableResult
    func moveUpTo(_ string: String) -> String? {
        var result: NSString? = nil
        while !isAtEnd {
            if scanUpTo(string, into: &result) {
                return result as String?
            }
            scanLocation += 1
        }
        return nil
    }
    
    @discardableResult
    func moveToCharacters(of set: CharacterSet) -> String? {
        var result: NSString? = nil
        while !isAtEnd {
            if scanCharacters(from: set, into: &result) {
                return result as String?
            }
            scanLocation += 1
        }
        return nil
    }
    @discardableResult
    func moveToCharacters(in string: String) -> String? {
        return moveToCharacters(of: .init(charactersIn: string))
    }
    
    @discardableResult
    func moveUpToCharacters(of set: CharacterSet) -> String? {
        var result: NSString? = nil
        while !isAtEnd {
            if scanUpToCharacters(from: set, into: &result) {
                return result as String?
            }
            scanLocation += 1
        }
        return nil
    }
    @discardableResult
    func moveUpToCharacters(in string: String) -> String? {
        return moveUpToCharacters(of: .init(charactersIn: string))
    }
     
    func scanQuoteWithInfo() -> (value: String, li: Int, ri: Int)? {
        let quote = "\"“”"
        guard moveToCharacters(in: quote) != nil else { return nil }
        let li = scanLocation
        guard let result = moveUpToCharacters(in: quote) else { return nil }
        return (result, li, scanLocation)
    }
    func scanQuote() -> String? {
        scanQuoteWithInfo()?.value
    }
}
