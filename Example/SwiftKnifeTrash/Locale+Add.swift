//
//  Locale+Add.swift
//  SwifterKnife
//
//  Created by liyang on 2021/10/19.
//

import Foundation

public extension Locale {
    /// UNIX representation of locale usually used for normalizing.
    static var posix: Locale {
        return Locale(identifier: "en_US_POSIX")
    }

    /// Returns bool value indicating if locale has 12h format.
    var is12HourTimeFormat: Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        dateFormatter.dateStyle = .none
        dateFormatter.locale = self
        let dateString = dateFormatter.string(from: Date())
        return dateString.contains(dateFormatter.amSymbol) || dateString.contains(dateFormatter.pmSymbol)
    }
}
