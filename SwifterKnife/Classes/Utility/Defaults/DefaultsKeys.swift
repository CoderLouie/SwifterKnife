//
// SwiftyUserDefaults
//
// Copyright (c) 2015-present Radosław Pietruszewski, Łukasz Mróz
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

import Foundation

public protocol DefaultsKeyStore {}

public struct DefaultsKeys: DefaultsKeyStore {
    public init() {}
}


// MARK: - Static keys

/// Specialize with value type
/// and pass key name to the initializer to create a key.
public struct DefaultsKey<Value: DefaultsSerializable> where Value.T == Value {

    public let _key: String
    public let defaultValue: Value

    public init(_ key: String, defaultValue: Value) {
        self._key = key
        self.defaultValue = defaultValue
    }
}

public extension DefaultsKey where Value.T == Value, Value: OptionalType, Value.Wrapped: DefaultsSerializable {

    init(_ key: String) {
        self.init(key, defaultValue: nil)
    }
}
