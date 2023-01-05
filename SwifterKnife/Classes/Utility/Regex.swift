//
//  Regex.swift
//  SwifterKnife
//
//  Created by liyang on 2022/12/28.
//  Originally from: https://github.com/sharplet/Regex (modified to remove some weight).
//

// https://github.com/FlineDev/HandySwift
// https://github.com/sindresorhus/Regex
import Foundation

fileprivate extension NSRange {
    var swifty: Range<Int> {
        location..<location + length
    }
}

fileprivate extension String {
    
    /**
     Get a string range from a `NSRange`.
     This works better than the built-in `Range(nsRange, in: string)`, which doesn't correctly handle some Unicode compositions.
     */
    func rangeBetter(from nsRange: NSRange) -> Range<Index> {
//        return Range(nsRange, in: self)
        let startIndex = utf16.index(utf16.startIndex, offsetBy: nsRange.lowerBound)
        let endIndex = utf16.index(startIndex, offsetBy: nsRange.length)
        return rangeOfComposedCharacterSequences(for: startIndex..<endIndex)
    }
    
    var nsrange: NSRange {
//        NSRange(location: 0, length: string.utf16.count)
        NSRange(startIndex..<endIndex, in: self)
    }
}

/// `Regex` is a swifty regex engine built on top of the NSRegularExpression api.
public struct Regex {
    
    public typealias Options = NSRegularExpression.Options
    public typealias MatchingOptions = NSRegularExpression.MatchingOptions
    
    // MARK: - Properties
    private let nsRegex: NSRegularExpression
    
    public var pattern: String {
        nsRegex.pattern
    }
    public var options: Options {
        nsRegex.options
    }
    // MARK: - Initializers
    /// Create a `Regex` based on a pattern string.
    ///
    /// If `pattern` is not a valid regular expression, an error is thrown
    /// describing the failure.
    ///
    /// - parameters:
    ///     - pattern: A pattern string describing the regex.
    ///     - options: Configure regular expression matching options.
    ///       For details, see `Regex.Options`.
    ///
    /// - throws: A value of `ErrorType` describing the invalid regular expression.
    public init(_ pattern: String, options: Options = []) throws {
        nsRegex = try NSRegularExpression(
            pattern: pattern,
            options: options
        )
    }
    
    // MARK: - Methods: Matching
    /// Returns `true` if the regex matches `string`, otherwise returns `false`.
    ///
    /// - parameter string: The string to test.
    ///
    /// - returns: `true` if the regular expression matches, otherwise `false`.
    public func matches(_ string: String,
                        options: MatchingOptions = []) -> Bool {
        nsRegex
            .firstMatch(in: string, options: options, range: string.nsrange) != nil
    }
    
    /// If the regex matches `string`, returns a `Match` describing the
    /// first matched string and any captures. If there are no matches, returns
    /// `nil`.
    ///
    /// - parameter string: The string to match against.
    ///
    /// - returns: An optional `Match` describing the first match, or `nil`.
    public func firstMatch(in string: String,
                           options: MatchingOptions = []) -> Match? {
        nsRegex
            .firstMatch(in: string, options: options, range: string.nsrange)
            .map { Match(result: $0, in: string) }
    }
    
    /// If the regex matches `string`, returns an array of `Match`, describing
    /// every match inside `string`. If there are no matches, returns an empty
    /// array.
    ///
    /// - parameter string: The string to match against.
    ///
    /// - returns: An array of `Match` describing every match in `string`.
    public func matches(in string: String,
                        options: MatchingOptions = []) -> [Match] {
        nsRegex
            .matches(in: string, options: options, range: string.nsrange)
            .map { Match(result: $0, in: string) }
    }
    
    public func split(_ string: String,
                      options: MatchingOptions = []) -> [Split] {
        var loc = 0
        let splits = nsRegex
            .matches(in: string, options: options, range: string.nsrange)
            .compactMap { (result) -> Split? in
                let r1 = result.range
                if r1.location == NSNotFound ||
                    r1.location == loc ||
                    r1.length == 0 { return nil }
                let r2 = NSRange(location: loc, length: r1.location - loc)
                loc = r1.location + r1.length
                return Split(baseString: string, range: r2)
            }
        let length = (string as NSString).length
        if loc == length { return splits }
        return splits + [Split(baseString: string, range: NSRange(location: loc, length: length - loc))]
    }
    
    
    // MARK: Replacing
    /*
     let regex: Regex = #"\d+"#
     let str = "ab12c3d456efg7h89i1011jk12lmn"
     let res = regex.replacingMatches(in: str, count: .max) {
         String(repeating: "*", count: $0.intRange.count)
     }
     res is "ab**c*d***efg*h**i****jk**lmn"
     */
    /// Returns a new string where each substring matched by `regex` is replaced
    /// with `template`.
    ///
    /// The template string may be a literal string, or include template variables:
    /// the variable `$0` will be replaced with the entire matched substring, `$1`
    /// with the first capture group, etc.
    ///
    /// For example, to include the literal string "$1" in the replacement string,
    /// you must escape the "$": `\$1`.
    ///
    /// - parameters:
    ///     - input: A regular expression to match against `self`.
    ///     - count: The maximum count of matches to replace, beginning with the first match.
    ///     - template: A template string used to replace matches.
    ///
    /// - returns: A string with all matches of `regex` replaced by `template`.
    public func replacingMatches(in input: String,
                                 count: Int,
                                 with template: (Match) -> String,
                                 options: MatchingOptions = []) -> String {
        if count < 1 { return input }
        let matches = self.matches(in: input, options: options)
        let rangedMatches = Array(matches[0..<min(matches.count, count)])
        if rangedMatches.isEmpty { return input }
        var output = input
        for match in rangedMatches.reversed() {
            let replacement = match.string(applyingTemplate: template(match))
            output.replaceSubrange(match.range, with: replacement)
        }

        return output
    }
    
    public func replacingAllMatches(in input: String,
                                    with template: String,
                                    options: MatchingOptions = []) -> String {
        return nsRegex.stringByReplacingMatches(in: input, options: options, range: input.nsrange, withTemplate: template)
    }
    public func replacingFirstMatch(in input: String,
                                    with template: String,
                                    options: MatchingOptions = []) -> String {
        guard let result = nsRegex
                .firstMatch(in: input, options: options, range: input.nsrange) else {
            return input
        }
        var output = input
        let replacement = nsRegex.replacementString(for: result, in: input, offset: 0, template: template)
        output.replaceSubrange(input.rangeBetter(from: result.range), with: replacement)
        return output
    }
}

extension Regex {
    /// Returns a string by adding backslash escapes as necessary to protect any characters that would match as pattern metacharacters.
    public static func escapingPattern(for string: String) -> String {
        NSRegularExpression.escapedPattern(for: string)
    }
}
extension Regex: ExpressibleByStringLiteral {
    public init(stringLiteral: String) {
        try! self.init(stringLiteral, options: [])
    }
}

// MARK: - CustomStringConvertible
extension Regex: CustomStringConvertible {
    /// Returns a string describing the regex using its pattern string.
    public var description: String {
        "Regex<\"\(nsRegex.pattern)\">"
    }
}

// MARK: - Equatable
extension Regex: Equatable {
    /// Determines the equality of to `Regex`` instances.
    /// Two `Regex` are considered equal, if both the pattern string and the options
    /// passed on initialization are equal.
    public static func == (lhs: Regex, rhs: Regex) -> Bool {
        lhs.nsRegex.pattern == rhs.nsRegex.pattern &&
        lhs.nsRegex.options == rhs.nsRegex.options
    }
}

// MARK: - Hashable
extension Regex: Hashable {
    /// Manages hashing of the `Regex` instance.
    public func hash(into hasher: inout Hasher) {
        hasher.combine(nsRegex)
    }
}

// MARK: - Split
extension Regex {
    public struct Split: CustomStringConvertible {
        public let value: String
         
        public let range: Range<String.Index>
        
        public let intRange: Range<Int>
        fileprivate init(baseString: String, range: NSRange) {
            self.range = baseString.rangeBetter(from: range)
            self.value = String(baseString[self.range])
            self.intRange = range.swifty
        }
        public var description: String {
            "Split<\"\(value)\" \(intRange)>"
        }
    }
}

// MARK: - Match
extension Regex {
    /// A `Match` encapsulates the result of a single match in a string,
    /// providing access to the matched string, as well as any capture groups within
    /// that string.
    public final class Match: CustomStringConvertible {
        
        
        // MARK: Properties
        /// The entire matched string.
        public private(set) lazy var value = String(baseString[range])
        
        /// The range of the matched string.
        public private(set) lazy var range = baseString.rangeBetter(from: result.range)
        
        public var intRange: Range<Int> {
            result.range.swifty
        }
        
        /// A regex match capture group.
        public struct Group: CustomStringConvertible {
            
            /// The  capture group string.
            public let value: String
            
            // The range of the capture group string in the original string.
            public let range: Range<String.Index>
            
            public let intRange: Range<Int>
            
            fileprivate init?(baseString: String, range: NSRange) {
                if range.location == NSNotFound,
                   range.length > 0 { return nil }
                self.range = baseString.rangeBetter(from: range)
                self.value = String(baseString[self.range])
                self.intRange = range.swifty
            }
            
            public var description: String {
                "Group<\"\(value)\" \(intRange)>"
            }
        }
        /// The matching string for each capture group in the regular expression
        /// (if any).
        ///
        /// **Note:** Usually if the match was successful, the captures will by
        /// definition be non-nil. However if a given capture group is optional, the
        /// captured string may also be nil, depending on the particular string that
        /// is being matched against.
        ///
        /// Example:
        ///
        ///     let regex = Regex("(a)?(b)")
        ///
        ///     regex.matches(in: "ab")first?.groups // [Optional("a"), Optional("b")]
        ///     regex.matches(in: "b").first?.groups // [nil, Optional("b")]
        public private(set) lazy var groups: [Group?] = {
            return (1..<result.numberOfRanges)
                .map(result.range)
                .map { Group(baseString: baseString, range: $0) }
        }()
        public var groupValues: [Group] {
            groups.compactMap { $0 }
        }
        
        @available(iOS 11.0, *)
        public func group(named name: String) -> Group? {
            let range = result.range(withName: name)
            return Group(baseString: baseString, range: range)
        }
        
        private let result: NSTextCheckingResult
        
        private let baseString: String
        
        // MARK: - Initializers
        @usableFromInline
        internal init(result: NSTextCheckingResult, in string: String) {
            precondition(
                result.regularExpression != nil,
                "NSTextCheckingResult must originate from regular expression parsing."
            )
            
            self.result = result
            self.baseString = string
        }
        
        // MARK: - Methods
        /// Returns a new string where the matched string is replaced according to the `template`.
        ///
        /// The template string may be a literal string, or include template variables:
        /// the variable `$0` will be replaced with the entire matched substring, `$1`
        /// with the first capture group, etc.
        ///
        /// For example, to include the literal string "$1" in the replacement string,
        /// you must escape the "$": `\$1`.
        ///
        /// - parameters:
        ///     - template: The template string used to replace matches.
        ///
        /// - returns: A string with `template` applied to the matched string.
        public func string(applyingTemplate template: String) -> String {
            result.regularExpression!.replacementString(for: result, in: baseString, offset: 0, template: template)
        }
        
        // MARK: - CustomStringConvertible
        /// Returns a string describing the match.
        public var description: String {
            "Match<\"\(value)\" \(intRange)>"
        }
    }
}
