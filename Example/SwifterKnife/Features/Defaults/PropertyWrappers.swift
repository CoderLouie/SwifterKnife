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

#if swift(>=5.1)
@propertyWrapper
public struct SwiftyDefaults<T: DefaultsSerializable> where T.T == T {
    private let _key: String
    private var _value: T.T
    public var wrappedValue: T.T {
        get { _value }
        set {
            _value = newValue
            T._defaults.save(key: _key, value: newValue, userDefaults: .standard)
        }
    }
    public init(keyPath: KeyPath<DefaultsKeys, DefaultsKey<T>>) {
        let key = Defaults.keyStore[keyPath: keyPath]
        self.init(key: key._key, defaultValue: key.defaultValue)
    }
    public init(key: String, defaultValue value: T) {
        _key = key
        _value = T._defaults.get(key: key, userDefaults: .standard) ?? value
    }
}
extension SwiftyDefaults where T.T == T, T: OptionalType, T.Wrapped: DefaultsSerializable, T: ExpressibleByNilLiteral {
    public init(key: String) {
        self.init(key: key, defaultValue: nil)
    }
}
#endif
