//
//  Formatter.swift
//  SwifterKnife
//
//  Created by 李阳 on 2024/5/16.
//

import Foundation


public enum Format {
    private static var _date = DateFormatter()
    public static var date: DateFormatter {
        let fmt = _date
        fmt.dateFormat = nil
        fmt.timeZone = nil
        fmt.locale = nil
        return fmt
    }
    public static var number = NumberFormatter()
    public static var dateComponent = DateComponentsFormatter()
    public static var dateInterval = DateIntervalFormatter()
    
}

extension Format {
    
    public static func string(from date: Date = Date(), config: (DateFormatter) -> Void) -> String {
        config(Self.date)
        return Self.date.string(from: date)
    }
    public static func date(from string: String, config: (DateFormatter) -> Void) -> Date? {
        config(Self.date)
        return Self.date.date(from: string)
    }
     
}
