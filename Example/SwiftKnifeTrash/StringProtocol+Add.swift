//
//  StringProtocol+Add.swift
//  SwifterKnife
//
//  Created by liyang on 2021/10/19.
//

import Foundation

public extension StringProtocol {
 
    /// Returns a new string in which all occurrences of a regex pattern in a specified range of the receiver are replaced by the template.
    /// - Parameters:
    ///   - pattern: Regex pattern to replace.
    ///   - template: The regex template to replace the pattern.
    ///   - options: Options to use when matching the regex. Only .regularExpression, .anchored .and caseInsensitive are supported.
    ///   - searchRange: The range in the receiver in which to search.
    /// - Returns: A new string in which all occurrences of regex pattern in searchRange of the receiver are replaced by template.
    func replacingOccurrences<Target, Replacement>(
        ofPattern pattern: Target,
        withTemplate template: Replacement,
        options: String.CompareOptions = [.regularExpression],
        range searchRange: Range<Self.Index>? = nil) -> String where Target: StringProtocol,
        Replacement: StringProtocol {
        assert(
            options.isStrictSubset(of: [.regularExpression, .anchored, .caseInsensitive]),
            "Invalid options for regular expression replacement")
        return replacingOccurrences(
            of: pattern,
            with: template,
            options: options.union(.regularExpression),
            range: searchRange)
    } 
}
