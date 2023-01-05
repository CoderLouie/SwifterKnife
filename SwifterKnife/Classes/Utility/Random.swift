//
//  Random.swift
//  SwifterKnife
//
//  Created by liyang on 2023/1/4.
//

//
//  SwiftRandom.swift
//
//  Created by Furkan Yilmaz on 7/10/15.
//  Copyright (c) 2015 Furkan Yilmaz. All rights reserved.
//

import UIKit

public protocol Randomizable: Comparable {
    static func random(in range: Range<Self>) -> Self
    static func random(in range: ClosedRange<Self>) -> Self
}
public extension Randomizable {
    /// [from, to)
    static func random(from: Self, to: Self) -> Self {
        .random(in: from..<to)
    }
    /// [from, through)
    static func random(from: Self, through: Self) -> Self {
        .random(in: from...through)
    }
}

extension Int: Randomizable {}
extension Double: Randomizable {}
extension Float: Randomizable {}
extension CGFloat: Randomizable {}

extension Date: Randomizable {
    
    static func randomWithinDaysBeforeToday(_ days: Int) -> Date {
        let today = Date()
        let earliest = today.addingTimeInterval(TimeInterval(-days*24*60*60))
        return Date.random(in: earliest...today)
    }

    static func random() -> Date {
        let randomTime = TimeInterval(arc4random_uniform(UInt32.max))
        return Date(timeIntervalSince1970: randomTime)
    }
    /// Returns a random date within the specified range.
    ///
    /// - Parameter range: The range in which to create a random date. `range` must not be empty.
    /// - Returns: A random date within the bounds of `range`.
    public static func random(in range: Range<Date>) -> Date {
        return Date(timeIntervalSinceReferenceDate:
                        TimeInterval.random(in: range.lowerBound.timeIntervalSinceReferenceDate..<range.upperBound.timeIntervalSinceReferenceDate))
    }
    
    /// Returns a random date within the specified range.
    ///
    /// - Parameter range: The range in which to create a random date.
    /// - Returns: A random date within the bounds of `range`.
    public static func random(in range: ClosedRange<Date>) -> Date {
        return Date(timeIntervalSinceReferenceDate:
                        TimeInterval.random(in: range.lowerBound.timeIntervalSinceReferenceDate...range.upperBound.timeIntervalSinceReferenceDate))
    }
}

public extension String {
     
    static func random(ofLength length: Int) -> String {
        return random(minLength: length, maxLength: length)
    }
     
    static func random(minLength min: Int, maxLength max: Int) -> String {
        randomCharactersInString("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789", minLength: min, maxLength: max)
    }
     
    static func randomCharactersInString(_ string: String, ofLength length: Int) -> String {
        return randomCharactersInString(string, minLength: length, maxLength: length)
    }
     
    static func randomCharactersInString(_ string: String, minLength min: Int, maxLength max: Int) -> String {
        guard min > 0 && max >= min else { return "" }
        
        let length: Int = (min < max) ? .random(in: min...max) : max
        var randomString = ""
        
        (1...length).forEach { _ in
            let index = string.randomIndex
            randomString.append(string[index])
        }
        
        return randomString
    }
    
    private var randomIndex: Index {
        index(startIndex, offsetBy: Int.random(in: 0..<count))
    }
}

public extension UIColor {
    
    /// Random color.
    static func random(_ randomAlpha: Bool = false) -> UIColor {
        UIColor(red: .random(in: 0...1),
                green: .random(in: 0...1),
                blue: .random(in: 0...1),
                alpha: randomAlpha ? CGFloat.random(in: 0...1) : 1.0)
    }
}

public enum Random {}

public extension Random {
    static var bool: Bool {
        Bool.random()
    }
    
    static func one<T: Randomizable>(_ lower: T, _ upper: T) -> T {
        T.random(in: lower..<upper)
    }
    
    static var int: Int {
        .random(in: 0..<100)
    }
    static var double: Double {
        .random(in: 0..<1)
    }
    static var float: Double {
        .random(in: 0..<1)
    }
    static var cgfloat: Double {
        .random(in: 0..<1)
    }
    
    static func string(ofLength length: Int) -> String {
        String.random(ofLength: length)
    }
    
    static func string(withCharactersInString string: String, ofLength length: Int) -> String {
        return String.randomCharactersInString(string, ofLength: length)
    }
    
    static func string(withCharactersInString string: String, minLength min: Int, maxLength max: Int) -> String {
        return String.randomCharactersInString(string, minLength: min, maxLength: max)
    }
    
    static var color: UIColor {
        UIColor.random()
    }
    static var alphaColor: UIColor {
        UIColor.random(true)
    }
    
    static var date: Date {
        Date.random()
    }
    
    static func date(from past: TimeInterval, to future: TimeInterval) -> Date {
        return Date().addingTimeInterval(.random(in: past...future))
    }
}

