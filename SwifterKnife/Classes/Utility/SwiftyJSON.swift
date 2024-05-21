//  SwiftyJSON.swift
//  SwifterKnife
//
//  Created by liyang on 08/24/2022.
//

// MARK: - Error
public enum JSONError: Int, Swift.Error {
    case unsupportedType = 999
    case indexOutOfBounds = 900
    case elementTooDeep = 902
    case wrongType = 901
    case notExist = 500
    case invalidJSON = 490
}

extension JSONError: CustomNSError {
    
    /// return the error domain of JSONError
    public static var errorDomain: String { return "com.swifterknife.SwiftyJSON" }
    
    /// return the error code of JSONError
    public var errorCode: Int { return self.rawValue }
    
    /// return the userInfo of JSONError
    public var errorUserInfo: [String: Any] {
        switch self {
        case .unsupportedType:
            return [NSLocalizedDescriptionKey: "It is an unsupported type."]
        case .indexOutOfBounds:
            return [NSLocalizedDescriptionKey: "Array Index is out of bounds."]
        case .wrongType:
            return [NSLocalizedDescriptionKey: "Couldn't merge, because the JSONs differ in type on top level."]
        case .notExist:
            return [NSLocalizedDescriptionKey: "Dictionary key does not exist."]
        case .invalidJSON:
            return [NSLocalizedDescriptionKey: "JSON is invalid."]
        case .elementTooDeep:
            return [NSLocalizedDescriptionKey: "Element too deep. Increase maxObjectDepth and make sure there is no reference loop."]
        }
    }
}

// MARK: - JSON Type

public enum JSONType {
    case number
    case string
    case bool
    case array
    case dictionary
    case null
    case unknown
}

// MARK: - JSON Base

/**
 JSON's type definitions.
 
 See http://www.json.org
 */
public enum JSON {
    
    case number(NSNumber)
    case string(String)
    case bool(Bool)
    case array([Any])
    case dictionary([String: Any])
    case null
    case error(JSONError)
    
    public init(filePath: String) throws {
        let url = URL(fileURLWithPath: filePath)
        let data = try Data(contentsOf: url)
        try self.init(data: data, options: [])
    }
    /**
     Creates a JSON using the data.
     
     - parameter data: The NSData used to convert to json.Top level object in data is an NSArray or NSDictionary
     - parameter opt: The JSON serialization reading options. `[]` by default.
     
     - returns: The created JSON
     */
    public init(data: Data, options opt: JSONSerialization.ReadingOptions = []) throws {
        let object: Any = try JSONSerialization.jsonObject(with: data, options: opt)
        self.init(jsonObject: object)
    }
    
    /**
     Creates a JSON object
     - note: this does not parse a `String` into JSON, instead use `init(parseJSON: String)`
     
     - parameter object: the object
     
     - returns: the created JSON object
     */
    public init(_ object: Any) {
        switch object {
        case let object as Data:
            do {
                try self.init(data: object)
            } catch {
                self = .error(.invalidJSON)
            }
        default:
            self.init(jsonObject: object)
        }
    }
    
    /**
     Parses the JSON string into a JSON object
     
     - parameter json: the JSON string
     
     - returns: the created JSON object
     */
    public init(parseJSON jsonString: String) {
        if let data = jsonString.data(using: .utf8) {
            do {
                try self.init(data: data)
            } catch {
                self = .error(.invalidJSON)
            }
        } else {
            self = .null
        }
    }
    
    /**
     Creates a JSON using the object.
     
     - parameter jsonObject:  The object must have the following properties: All objects are NSString/String, NSNumber/Int/Float/Double/Bool, NSArray/Array, NSDictionary/Dictionary, or NSNull; All dictionary keys are NSStrings/String; NSNumbers are not NaN or infinity.
     
     - returns: The created JSON
     */
    fileprivate init(jsonObject: Any) {
        guard let value = JSON.unwrap(jsonObject) else {
            self = .null
            return
        }
        switch value {
        case let j as JSON:
            self = j
        case let number as NSNumber:
            if number.isBool {
                self = .bool(number.boolValue)
            } else {
                self = .number(number)
            }
        case let string as String:
            self = .string(string)
        case let arr as [Any]:
            self = .array(arr)
        case let dict as [String: Any]:
            self = .dictionary(dict)
        case let error as JSONError:
            self = .error(error)
        default:
            self = .error(.unsupportedType)
        }
    }
    
   fileprivate init(error: JSONError) {
       self = .error(error)
   }
    
    /**
     Merges another JSON into this JSON, whereas primitive values which are not present in this JSON are getting added,
     present values getting overwritten, array values getting appended and nested JSONs getting merged the same way.
     
     - parameter other: The JSON which gets merged into this JSON
     
     - throws `ErrorWrongType` if the other JSONs differs in type on the top level.
     */
    public mutating func merge(with other: JSON) throws {
        try self.merge(with: other, typecheck: true)
    }
    
    /**
     Merges another JSON into this JSON and returns a new JSON, whereas primitive values which are not present in this JSON are getting added,
     present values getting overwritten, array values getting appended and nested JSONS getting merged the same way.
     
     - parameter other: The JSON which gets merged into this JSON
     
     - throws `ErrorWrongType` if the other JSONs differs in type on the top level.
     
     - returns: New merged JSON
     */
    public func merged(with other: JSON) throws -> JSON {
        var merged = self
        try merged.merge(with: other, typecheck: true)
        return merged
    }
    
    /**
     Private woker function which does the actual merging
     Typecheck is set to true for the first recursion level to prevent total override of the source JSON
     */
    fileprivate mutating func merge(with other: JSON, typecheck: Bool) throws {
        if type == other.type {
            switch self {
            case .dictionary:
                for (key, _) in other {
                    try self[key].merge(with: other[key], typecheck: false)
                }
            case .array:
                self = JSON(arrayValue + other.arrayValue)
            default:
                self = other
            }
        } else {
            if typecheck {
                throw JSONError.wrongType
            } else {
                self = other
            }
        }
    }
    
    public var error: JSONError? {
        if case .error(let err) = self {
            return err
        }
        return nil
    }
    public var type: JSONType {
        switch self {
        case .number: return .number
        case .string: return .string
        case .bool: return .bool
        case .array: return .array
        case .dictionary: return .dictionary
        case .null: return .null
        case .error: return .unknown
        }
    }
    
    /// Object in JSON
    public var object: Any {
        get {
            switch self {
            case .number(let num): return num
            case .string(let string): return string
            case .bool(let bool): return bool
            case .array(let array): return array
            case .dictionary(let dict): return dict
            case .null, .error: return NSNull()
            }
        }
        set {
            self = JSON(jsonObject: newValue)
        }
    }
     
    fileprivate func orError(_ error: JSONError) -> JSON {
        return JSON(error: self.error ?? error)
    }
}
 

public enum Index<T: Any>: Comparable {
    case array(Int)
    case dictionary(DictionaryIndex<String, T>)
    case null
    
    static public func == (lhs: Index, rhs: Index) -> Bool {
        switch (lhs, rhs) {
        case (.array(let left), .array(let right)):
            return left == right
        case (.dictionary(let left), .dictionary(let right)):
            return left == right
        case (.null, .null): return true
        default: return false
        }
    }
    
    static public func < (lhs: Index, rhs: Index) -> Bool {
        switch (lhs, rhs) {
        case (.array(let left), .array(let right)):
            return left < right
        case (.dictionary(let left), .dictionary(let right)):
            return left < right
        default: return false
        }
    }
}

public typealias JSONIndex = Index<JSON>
public typealias JSONRawIndex = Index<Any>

extension JSON: Swift.Collection {
    public typealias Element = (String, JSON)
    
    public typealias Index = JSONRawIndex
    
    public var startIndex: Index {
        switch self {
        case .array(let array):
            return .array(array.startIndex)
        case .dictionary(let dict):
            return .dictionary(dict.startIndex)
        default: return .null
        }
    }
    
    public var endIndex: Index {
        switch self {
        case .array(let array):
            return .array(array.endIndex)
        case .dictionary(let dict):
            return .dictionary(dict.endIndex)
        default: return .null
        }
    }
    
    public func index(after i: Index) -> Index {
        switch i {
        case .array(let idx):
            if case .array(let array) = self {
                return .array(array.index(after: idx))
            } else {
                return .null
            }
        case .dictionary(let idx):
            if case .dictionary(let dict) = self {
                return .dictionary(dict.index(after: idx))
            } else {
                return .null
            }
        default: return .null
        }
    }
    
    public subscript (position: Index) -> (String, JSON) {
        switch position {
        case .array(let idx):
            if case .array(let array) = self {
                return (String(idx), JSON(array[idx]))
            } else {
                return ("", JSON.null)
            }
        case .dictionary(let idx):
            if case .dictionary(let dict) = self {
                let pair = dict[idx]
                return (pair.key, JSON(pair.value))
            } else {
                return ("", JSON.null)
            }
        default: return ("", JSON.null)
        }
    }
}

// MARK: - Subscript

/**
 *  To mark both String and Int can be used in subscript.
 */
public enum JSONKey {
    case index(Int)
    case key(String)
}

public protocol JSONSubscriptType {
    var jsonKey: JSONKey { get }
}

extension Int: JSONSubscriptType {
    public var jsonKey: JSONKey {
        return .index(self)
    }
}

extension String: JSONSubscriptType {
    public var jsonKey: JSONKey {
        return .key(self)
    }
}

extension JSON {
    
    /// If `type` is `.array`, return json whose object is `array[index]`, otherwise return null json with error.
    fileprivate subscript(index index: Int) -> JSON {
        get {
            if case .array(let array) = self {
                if array.indices.contains(index) {
                    return JSON(array[index])
                } else {
                    return .error(.indexOutOfBounds)
                }
            } else {
                return orError(.wrongType)
            }
        }
        set {
            if case .array(var array) = self,
               array.indices.contains(index) {
                array[index] = newValue.object
                self = .array(array)
            }
        }
    }
    
    /// If `type` is `.dictionary`, return json whose object is `dictionary[key]` , otherwise return null json with error.
    fileprivate subscript(key key: String) -> JSON {
        get {
            if case .dictionary(let dict) = self {
                if let o = dict[key] {
                    return JSON(o)
                } else {
                    return .error(.notExist)
                }
            } else {
                return orError(.wrongType)
            }
        }
        set {
            if case .dictionary(var dict) = self {
                dict[key] = newValue.object
                self = .dictionary(dict)
            }
        }
    }
    
    /// If `sub` is `Int`, return `subscript(index:)`; If `sub` is `String`,  return `subscript(key:)`.
    fileprivate subscript(sub sub: JSONSubscriptType) -> JSON {
        get {
            switch sub.jsonKey {
            case .index(let index):
                return self[index: index]
            case .key(let key):
                return self[key: key]
            }
        }
        set {
            switch sub.jsonKey {
            case .index(let index):
                self[index: index] = newValue
            case .key(let key):
                self[key: key] = newValue
            }
        }
    }
    
    /**
     Find a json in the complex data structures by using array of Int and/or String as path.
     
     Example:
     
     ```
     let json = JSON(data)
     let path = [9,"list","person","name"]
     let name = json[path]
     ```
     
     The same as: let name = json[9]["list"]["person"]["name"]
     
     - parameter path: The target json's path.
     
     - returns: Return a json found by the path or a null json with error
     */
    public subscript(path: [JSONSubscriptType]) -> JSON {
        get {
            return path.reduce(self) { $0[sub: $1] }
        }
        set {
            switch path.count {
            case 0: return
            case 1: self[sub: path[0]].object = newValue.object
            default:
                var aPath = path
                let first = aPath.removeFirst()
                var nextJSON = self[sub: first]
                /// 产生递归调用
                nextJSON[aPath] = newValue
                self[sub: first] = nextJSON
            }
        }
    }
    
    /**
     Find a json in the complex data structures by using array of Int and/or String as path.
     
     - parameter path: The target json's path. Example:
     
     let name = json[9,"list","person","name"]
     
     The same as: let name = json[9]["list"]["person"]["name"]
     
     - returns: Return a json found by the path or a null json with error
     */
    public subscript(path: JSONSubscriptType...) -> JSON {
        get { self[path] }
        set { self[path] = newValue }
    }
    
    public subscript(parse key: String) -> JSON {
        guard case .dictionary(let dict) = self else {
            return orError(.wrongType)
        }
        if let o = dict[key] {
            if let str = o as? String {
                let parseV = JSON(parseJSON: str)
                return parseV.isValid ? parseV : .string(str)
            }
            return JSON(o)
        } else {
            return .error(.notExist)
        }
    }
    public subscript(parse index: Int) -> JSON {
        guard case .array(let array) = self else {
            return orError(.wrongType)
        }
        if array.indices.contains(index) {
            let o = array[index]
            if let str = o as? String {
                let parseV = JSON(parseJSON: str)
                return parseV.isValid ? parseV : .string(str)
            }
            return JSON(o)
        } else {
            return .error(.indexOutOfBounds)
        }
    }
    
    public subscript(caseInsensitive key: String) -> JSON {
        get {
            guard case .dictionary(let dict) = self else {
                return orError(.wrongType)
            }
            for (k, v) in dict {
                if k.compare(key, options: [.caseInsensitive]) == .orderedSame {
                    return JSON(v)
                }
            }
            return .error(.notExist)
        }
        set {
            if case .dictionary(var dict) = self {
                for k in dict.keys {
                    if k.compare(key, options: [.caseInsensitive]) == .orderedSame {
                        dict.removeValue(forKey: k)
                    }
                }
                dict[key] = newValue.object
                self = .dictionary(dict)
            }
        }
    }
    public subscript(multiKeys keys: [String]) -> JSON {
        get {
            guard case .dictionary(let dict) = self else {
                return orError(.wrongType)
            }
            for key in keys {
                if let o = dict[key] { return JSON(o) }
            }
            return .error(.notExist)
        }
        set {
            if case .dictionary(var dict) = self,
               let key = keys.first {
                dict[key] = newValue.object
                self = .dictionary(dict)
            }
        }
    }
    
    public subscript(multiKeys keys: String...) -> JSON {
        get { self[multiKeys: keys] }
        set { self[multiKeys: keys] = newValue }
    }
    
    public func searchIgnoreCase(_ keys: String...) -> JSON {
        guard case .dictionary(var dict) = self else {
            return orError(.wrongType)
        }
        dict = dict.mapKeysAndValues {
            ($0.key.lowercased(), $0.value)
        }
        for key in keys.map({ $0.lowercased() }) {
            if let o = dict[key] { return JSON(o) }
        }
        return .error(.notExist)
    }
    
    public var isValid: Bool {
        switch self {
        case .error, .null: return false
        default: return true
        }
    }
}

// MARK: - LiteralConvertible

extension JSON: Swift.ExpressibleByStringLiteral {
    public init(stringLiteral value: StringLiteralType) {
        self = .string(value)
    }
    public init(extendedGraphemeClusterLiteral value: StringLiteralType) {
        self = .string(value)
    }
    public init(unicodeScalarLiteral value: StringLiteralType) {
        self = .string(value)
    }
}
extension JSON: Swift.ExpressibleByIntegerLiteral {
    public init(integerLiteral value: IntegerLiteralType) {
        self = .number(NSNumber(value: value))
    }
}
extension JSON: Swift.ExpressibleByBooleanLiteral {
    public init(booleanLiteral value: BooleanLiteralType) {
        self = .bool(value)
    }
}
extension JSON: Swift.ExpressibleByFloatLiteral {
    public init(floatLiteral value: FloatLiteralType) {
        self = .number(NSNumber(value: value))
    }
}
extension JSON: Swift.ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (String, Any)...) {
        let dictionary = elements.reduce(into: [String: Any](), { $0[$1.0] = $1.1})
        self = .dictionary(dictionary)
    }
}
extension JSON: Swift.ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: Any...) {
        self = .array(elements)
    }
}

// MARK: - Raw

extension JSON: Swift.RawRepresentable {
//    public init?(rawValue: Any)  {
//        let json = JSON(jsonObject: rawValue)
//        if case .error = json { return nil }
//        self = json
//    }
    public init(rawValue: Any)  {
        self.init(jsonObject: rawValue)
    }
    public var rawValue: Any {
        object
    }
    
    public func rawData(options opt: JSONSerialization.WritingOptions = []) throws -> Data {
        
        guard JSONSerialization.isValidJSONObject(object) else {
            throw JSONError.invalidJSON
        }
        var options: JSONSerialization.WritingOptions = [.sortedKeys]
        if #available(iOS 13.0, *) {
            options.insert(.withoutEscapingSlashes)
        }
        options.formUnion(opt)
        return try JSONSerialization.data(withJSONObject: object, options: options)
    } 
}

// MARK: - Printable, DebugPrintable

extension JSON: Swift.CustomStringConvertible, Swift.CustomDebugStringConvertible {
    
    public var formatJSONString: String? {
        guard let data = try? rawData(),
              let raw = String(data: data, encoding: .utf8) else { return nil }
        return raw
    }

    public var description: String {
        switch self {
        case let .number(num): return "number(\(num.description))"
        case let .string(str): return "string(\(str.description))"
        case let .bool(bool): return "bool(\(bool.description))"
        case let .array(arr):
            let json = formatJSONString ?? arr.description
            return "array(\(json))"
        case let .dictionary(dict):
            let json = formatJSONString ?? dict.description
            return "dictionary(\(json))"
        case .null: return "null"
        case let .error(error): return "error\(error.localizedDescription)"
        }
    }
    
    public var debugDescription: String {
        switch self {
        case let .number(num): return "number(\(num.description))"
        case let .string(str): return "string(\(str.debugDescription))"
        case let .bool(bool): return "bool(\(bool.description))"
        case let .array(arr):
            let json = formatJSONString ?? arr.debugDescription
            return "array(\(json))"
        case let .dictionary(dict):
            let json = formatJSONString ?? dict.description
            return "dictionary(\(json))"
        case .null: return "null"
        case let .error(error): return "error(\(error.localizedDescription))"
        }
    }
}

// MARK: - Array

extension JSON {
    //Optional [JSON]
    public var array: [JSON]? {
        if case .array(let array) = self {
            return array.map { JSON($0) }
        }
//        if case .string(let string) = self {
//            return JSON(parseJSON: string).array
//        }
        return nil
    }
    //Non-optional [JSON]
    public var arrayValue: [JSON] {
        return array ?? []
    }
    
    //Optional [Any]
    public var arrayObject: [Any]? {
        get {
            if case .array(let array) = self { return array }
//            if case .string(let string) = self {
//                return JSON(parseJSON: string).arrayObject
//            }
            return nil
        }
        set {
            if let v = newValue { self = .array(v) }
            else { self = .null }
        }
    }
}

// MARK: - Dictionary

extension JSON {
    
    //Optional [String : JSON]
    public var dictionary: [String: JSON]? {
        if case .dictionary(let dict) = self {
            var d = [String: JSON](minimumCapacity: dict.count)
            dict.forEach { pair in
                d[pair.key] = JSON(pair.value)
            }
            return d
        }
//        if case .string(let string) = self {
//            return JSON(parseJSON: string).dictionary
//        }
        return nil
    }
    
    //Non-optional [String : JSON]
    public var dictionaryValue: [String: JSON] {
        return dictionary ?? [:]
    }
    
    //Optional [String : Any]
    public var dictionaryObject: [String: Any]? {
        get {
            if case .dictionary(let dict) = self { return dict }
//            if case .string(let string) = self {
//                return JSON(parseJSON: string).dictionaryObject
//            }
            return nil
        }
        set {
            if let v = newValue { self = .dictionary(v) }
            else { self = .null }
        }
    }
}

// MARK: - Bool

extension JSON { // : Swift.Bool
    
    //Optional bool
    public var bool: Bool? {
        get {
            switch self {
            case .bool(let bool): return bool
            case .number(let num): return num.boolValue
            case .string(let string):
                let target = string.lowercased()
                if ["true", "t", "y", "yes", "1"].contains(target) { return true }
                if ["false", "f", "n", "no", "0"].contains(target) { return false }
                let num = NSDecimalNumber(string: string)
                return num == .notANumber ? nil : num.boolValue
            default: return nil
            }
        }
        set {
            if let v = newValue { self = .bool(v) }
            else { self = .null }
        }
    }
    
    //Non-optional bool
    public var boolValue: Bool {
        get { return bool ?? false }
        set { self = .bool(newValue) }
    }
}


// MARK: - String

extension JSON {
    
    //Optional string
    public var string: String? {
        get {
            switch self {
            case .string(let string): return string
            case .number(let num): return num.stringValue
            case .bool(let bool): return String(bool)
            default: return nil
            }
        }
        set {
            if let v = newValue { self = .string(v) }
            else { self = .null }
        }
    }
    
    //Non-optional string
    public var stringValue: String {
        get { return string ?? "" }
        set { self = .string(newValue) }
    }
}

// MARK: - Number

extension JSON {
    
    //Optional number
    public var number: NSNumber? {
        get {
            switch self {
            case .string(let string):
                let decimal = NSDecimalNumber(string: string)
                return decimal == .notANumber ? nil : decimal
            case .number(let num): return num
            case .bool(let bool): return NSNumber(value: bool ? 1 : 0)
            default: return nil
            }
        }
        set {
            if let v = newValue { self = .number(v) }
            else { self = .null }
        }
    }
    
    //Non-optional number
    public var numberValue: NSNumber {
        get { number ?? NSNumber(value: 0.0) }
        set { self = .number(newValue) }
    }
}

// MARK: - Null

extension JSON {
    public var null: NSNull? {
        get {
            if case .null = self { return NSNull() }
            return nil
        }
        set { self = .null }
    }
}

// MARK: - URL

extension JSON {
    
    //Optional URL
    public var url: URL? {
        get {
            switch self {
            case .string(let string):
                // Check for existing percent escapes first to prevent double-escaping of % character
                if string.range(of: "%[0-9A-Fa-f]{2}", options: .regularExpression, range: nil, locale: nil) != nil {
                    return Foundation.URL(string: string)
                } else if let encodedString_ = string.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) {
                    // We have to use `Foundation.URL` otherwise it conflicts with the variable name.
                    return Foundation.URL(string: encodedString_)
                } else {
                    return nil
                }
            default:
                return nil
            }
        }
        set {
            string = newValue?.absoluteString
        }
    }
}

// MARK: - Int, Double, Float, Int8, Int16, Int32, Int64

extension JSON {
    
    public var double: Double? {
        get {
            return number?.doubleValue
        }
        set {
            number = newValue.map(NSNumber.init)
        }
    }
    
    public var doubleValue: Double {
        get {
            return numberValue.doubleValue
        }
        set {
            numberValue = NSNumber(value: newValue)
        }
    }
    
    public var float: Float? {
        get {
            return number?.floatValue
        }
        set {
            number = newValue.map(NSNumber.init)
        }
    }
    
    public var floatValue: Float {
        get {
            return numberValue.floatValue
        }
        set {
            numberValue = NSNumber(value: newValue)
        }
    }
    
    public var int: Int? {
        get {
            return number?.intValue
        }
        set {
            number = newValue.map(NSNumber.init)
        }
    }
    
    public var intValue: Int {
        get {
            return numberValue.intValue
        }
        set {
            numberValue = NSNumber(value: newValue)
        }
    }
    
    public var uInt: UInt? {
        get {
            return number?.uintValue
        }
        set {
            number = newValue.map(NSNumber.init)
        }
    }
    
    public var uIntValue: UInt {
        get {
            return numberValue.uintValue
        }
        set {
            numberValue = NSNumber(value: newValue)
        }
    }
    
    public var int8: Int8? {
        get {
            return number?.int8Value
        }
        set {
            number = newValue.map(NSNumber.init)
        }
    }
    
    public var int8Value: Int8 {
        get {
            return numberValue.int8Value
        }
        set {
            numberValue = NSNumber(value: Int(newValue))
        }
    }
    
    public var uInt8: UInt8? {
        get {
            return number?.uint8Value
        }
        set {
            number = newValue.map(NSNumber.init)
        }
    }
    
    public var uInt8Value: UInt8 {
        get {
            return numberValue.uint8Value
        }
        set {
            numberValue = NSNumber(value: newValue)
        }
    }
    
    public var int16: Int16? {
        get {
            return number?.int16Value
        }
        set {
            number = newValue.map(NSNumber.init)
        }
    }
    
    public var int16Value: Int16 {
        get {
            return numberValue.int16Value
        }
        set {
            numberValue = NSNumber(value: newValue)
        }
    }
    
    public var uInt16: UInt16? {
        get {
            return number?.uint16Value
        }
        set {
            number = newValue.map(NSNumber.init)
        }
    }
    
    public var uInt16Value: UInt16 {
        get {
            return numberValue.uint16Value
        }
        set {
            numberValue = NSNumber(value: newValue)
        }
    }
    
    public var int32: Int32? {
        get {
            return number?.int32Value
        }
        set {
            number = newValue.map(NSNumber.init)
        }
    }
    
    public var int32Value: Int32 {
        get {
            return numberValue.int32Value
        }
        set {
            numberValue = NSNumber(value: newValue)
        }
    }
    
    public var uInt32: UInt32? {
        get {
            return number?.uint32Value
        }
        set {
            number = newValue.map(NSNumber.init)
        }
    }
    
    public var uInt32Value: UInt32 {
        get {
            return numberValue.uint32Value
        }
        set {
            numberValue = NSNumber(value: newValue)
        }
    }
    
    public var int64: Int64? {
        get {
            return number?.int64Value
        }
        set {
            number = newValue.map(NSNumber.init)
        }
    }
    
    public var int64Value: Int64 {
        get {
            return numberValue.int64Value
        }
        set {
            numberValue = NSNumber(value: newValue)
        }
    }
    
    public var uInt64: UInt64? {
        get {
            return number?.uint64Value
        }
        set {
            number = newValue.map(NSNumber.init)
        }
    }
    
    public var uInt64Value: UInt64 {
        get {
            return numberValue.uint64Value
        }
        set {
            numberValue = NSNumber(value: newValue)
        }
    }
}

// MARK: - Comparable

extension JSON: Swift.Comparable {}

public func == (lhs: JSON, rhs: JSON) -> Bool {
    
    switch (lhs, rhs) {
    case let (.number(num1), .number(num2)):
        return num1 == num2
    case let (.string(string1), .string(string2)):
        return string1 == string2
    case let (.bool(bool1), .bool(bool2)):
        return bool1 == bool2
    case let (.array(array1), .array(array2)):
        return array1 as NSArray == array2 as NSArray
    case let (.dictionary(dict1), .dictionary(dict2)):
        return dict1 as NSDictionary == dict2 as NSDictionary
    case (.null, .null): return true
    default: return false
    }
}

public func <= (lhs: JSON, rhs: JSON) -> Bool {
    
    switch (lhs, rhs) {
    case let (.number(num1), .number(num2)):
        return num1 <= num2
    case let (.string(string1), .string(string2)):
        return string1 <= string2
    case let (.bool(bool1), .bool(bool2)):
        return bool1 == bool2
    case let (.array(array1), .array(array2)):
        return array1 as NSArray == array2 as NSArray
    case let (.dictionary(dict1), .dictionary(dict2)):
        return dict1 as NSDictionary == dict2 as NSDictionary
    case (.null, .null): return true
    default: return false
    }
}

public func >= (lhs: JSON, rhs: JSON) -> Bool {
    
    switch (lhs, rhs) {
    case let (.number(num1), .number(num2)):
        return num1 >= num2
    case let (.string(string1), .string(string2)):
        return string1 >= string2
    case let (.bool(bool1), .bool(bool2)):
        return bool1 == bool2
    case let (.array(array1), .array(array2)):
        return array1 as NSArray == array2 as NSArray
    case let (.dictionary(dict1), .dictionary(dict2)):
        return dict1 as NSDictionary == dict2 as NSDictionary
    case (.null, .null): return true
    default: return false
    }
}

public func > (lhs: JSON, rhs: JSON) -> Bool {
    
    switch (lhs, rhs) {
    case let (.number(num1), .number(num2)):
        return num1 > num2
    case let (.string(string1), .string(string2)):
        return string1 > string2
    default: return false
    }
}

public func < (lhs: JSON, rhs: JSON) -> Bool {
    
    switch (lhs, rhs) {
    case let (.number(num1), .number(num2)):
        return num1 < num2
    case let (.string(string1), .string(string2)):
        return string1 < string2
    default: return false
    }
}


// MARK: - NSNumber: Comparable

extension NSNumber {
    fileprivate var isBool: Bool {
        String(cString: objCType) == "c"
    }
}

func == (lhs: NSNumber, rhs: NSNumber) -> Bool {
    switch (lhs.isBool, rhs.isBool) {
    case (false, true): return false
    case (true, false): return false
    default: return lhs.compare(rhs) == .orderedSame
    }
}

func != (lhs: NSNumber, rhs: NSNumber) -> Bool {
    return !(lhs == rhs)
}

func < (lhs: NSNumber, rhs: NSNumber) -> Bool {
    switch (lhs.isBool, rhs.isBool) {
    case (false, true): return false
    case (true, false): return false
    default: return lhs.compare(rhs) == .orderedAscending
    }
}

func > (lhs: NSNumber, rhs: NSNumber) -> Bool {
    switch (lhs.isBool, rhs.isBool) {
    case (false, true): return false
    case (true, false): return false
    default: return lhs.compare(rhs) == ComparisonResult.orderedDescending
    }
}

func <= (lhs: NSNumber, rhs: NSNumber) -> Bool {
    switch (lhs.isBool, rhs.isBool) {
    case (false, true): return false
    case (true, false): return false
    default: return lhs.compare(rhs) != .orderedDescending
    }
}

func >= (lhs: NSNumber, rhs: NSNumber) -> Bool {
    switch (lhs.isBool, rhs.isBool) {
    case (false, true): return false
    case (true, false): return false
    default: return lhs.compare(rhs) != .orderedAscending
    }
}

// MARK: - JSON: Codable
extension JSON: Codable {
    private static var codableTypes: [Codable.Type] {
        return [
            Bool.self,
            Int.self,
            Int8.self,
            Int16.self,
            Int32.self,
            Int64.self,
            UInt.self,
            UInt8.self,
            UInt16.self,
            UInt32.self,
            UInt64.self,
            Double.self,
            String.self,
            [JSON].self,
            [String: JSON].self
        ]
    }
    public init(from decoder: Decoder) throws {
        var object: Any?
        
        if let container = try? decoder.singleValueContainer(), !container.decodeNil() {
            for type in JSON.codableTypes {
                if object != nil { break }
                // try to decode value
                switch type {
                case let boolType as Bool.Type:
                    object = try? container.decode(boolType)
                case let intType as Int.Type:
                    object = try? container.decode(intType)
                case let int8Type as Int8.Type:
                    object = try? container.decode(int8Type)
                case let int32Type as Int32.Type:
                    object = try? container.decode(int32Type)
                case let int64Type as Int64.Type:
                    object = try? container.decode(int64Type)
                case let uintType as UInt.Type:
                    object = try? container.decode(uintType)
                case let uint8Type as UInt8.Type:
                    object = try? container.decode(uint8Type)
                case let uint16Type as UInt16.Type:
                    object = try? container.decode(uint16Type)
                case let uint32Type as UInt32.Type:
                    object = try? container.decode(uint32Type)
                case let uint64Type as UInt64.Type:
                    object = try? container.decode(uint64Type)
                case let doubleType as Double.Type:
                    object = try? container.decode(doubleType)
                case let stringType as String.Type:
                    object = try? container.decode(stringType)
                case let jsonValueArrayType as [JSON].Type:
                    if let arr = try? container.decode(jsonValueArrayType) {
                        object = arr.map(\.object)
                    }
                case let jsonValueDictType as [String: JSON].Type:
                    if let dict = try? container.decode(jsonValueDictType) {
                        object = dict.mapValues(\.object)
                    }
                default: break
                }
            }
        }
        self.init(object ?? NSNull())
    }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if object is NSNull {
            try container.encodeNil()
            return
        }
        switch object {
        case let intValue as Int:
            try container.encode(intValue)
        case let int8Value as Int8:
            try container.encode(int8Value)
        case let int32Value as Int32:
            try container.encode(int32Value)
        case let int64Value as Int64:
            try container.encode(int64Value)
        case let uintValue as UInt:
            try container.encode(uintValue)
        case let uint8Value as UInt8:
            try container.encode(uint8Value)
        case let uint16Value as UInt16:
            try container.encode(uint16Value)
        case let uint32Value as UInt32:
            try container.encode(uint32Value)
        case let uint64Value as UInt64:
            try container.encode(uint64Value)
        case let doubleValue as Double:
            try container.encode(doubleValue)
        case let boolValue as Bool:
            try container.encode(boolValue)
        case let stringValue as String:
            try container.encode(stringValue)
        case is [Any]:
            let jsonValueArray = array ?? []
            try container.encode(jsonValueArray)
        case is [String: Any]:
            let jsonValueDictValue = dictionary ?? [:]
            try container.encode(jsonValueDictValue)
        default:
            break
        }
    }
}


public extension JSON {
    static func data(of object: Any?, prettify: Bool = false) -> Data? {
        guard let obj = object else { return nil }
        guard JSONSerialization.isValidJSONObject(obj) else { return nil }
        var options: JSONSerialization.WritingOptions = [.sortedKeys]
        if prettify { options.insert(.prettyPrinted) }
        if #available(iOS 13.0, *) {
            options.insert(.withoutEscapingSlashes)
        }
        return try? JSONSerialization.data(withJSONObject: obj, options: options)
    }
    static func string(of object: Any?, prettify: Bool = false) -> String? {
        guard let data = data(of: object, prettify: prettify) else { return nil }
        return String(data: data, encoding: .utf8)
    }
    static func sureString(of object: Any?, prettify: Bool = false, or replace: @autoclosure () -> String = "Empty") -> String {
        string(of: object, prettify: prettify) ?? replace()
    }
}

private protocol _OptionalProtocol {
    var _deepUnwrapped: Any? { get }
}
extension Optional: _OptionalProtocol {
    fileprivate var _deepUnwrapped: Any? {
        if let wrapped = self {
            if let op = wrapped as? _OptionalProtocol {
                return op._deepUnwrapped
            } else {
                return wrapped
            }
        }
        return nil
    }
}

extension JSON {
    public static func unwrap(_ object: Any, _ tractAsNil: [String] = []) -> Any? {
        switch object {
        case let str as String:
            let lowstr = str.lowercased()
            if lowstr == "nil" || lowstr == "null" ||
                tractAsNil.contains(lowstr) { return nil }
            return str
        case _ as NSNull: return nil
        case let opVal as _OptionalProtocol:
            if let v = opVal._deepUnwrapped {
                return unwrap(v, tractAsNil)
            } else {
                return nil
            }
        default: return object
        }
    }
     
    public static func deepUnwrap(_ value: Any, _ tractAsNil: [String] = []) -> Any? {
        guard let json = unwrap(value, tractAsNil) else {
            return nil
        }
        switch json {
        case let array as [Any]:
            return array.compactMap { deepUnwrap($0, tractAsNil) }
        case let dictionary as [AnyHashable: Any]:
            return dictionary.compactMapValues{ deepUnwrap($0, tractAsNil) }
        default: return value
        }
    }
    
    private static func rawValue(of val: Any) -> Any {
        if let raw = val as? (any RawRepresentable) {
            return raw.rawValue
        }
        if let dict = val as? [AnyHashable: Any] {
            return dict.reduce(into: [String: Any]()) {
                $0[$1.key.description] = rawValue(of: $1.value)
            }
        }
        if let array = val as? [Any] {
            return array.map(rawValue)
        }
        let mirror = Mirror(reflecting: val)
        if mirror.displayStyle == .enum {
            return String(describing: val)
        }
        let childs = sequence(first: mirror, next: \.superclassMirror).flatMap(\.children)
        if childs.isEmpty { return val }
        var res: [String: Any] = [:]
        for child in childs {
            guard case let (label?, value) = child else { continue }
            guard let x = unwrap(value) else { continue }
            let lbl = label.hasPrefix("_") ? String(label.dropFirst()) : label
            res[lbl] = rawValue(of: x)
        }
        return res
    }
    public static func keyValues(of val: Any) -> [String: Any] {
        let map = (rawValue(of: val) as? [String: Any]) ?? [:]
        return map
    }
}
