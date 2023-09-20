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


public let Defaults = DefaultsAdapter<DefaultsKeys>(defaults: .standard, keyStore: .init())

@dynamicMemberLookup
public struct DefaultsAdapter<KeyStore: DefaultsKeyStore> {

    public let defaults: UserDefaults
    public let keyStore: KeyStore

    public init(defaults: UserDefaults, keyStore: KeyStore) {
        self.defaults = defaults
        self.keyStore = keyStore
    }

    @available(*, unavailable)
    public subscript(dynamicMember member: String) -> Never {
        fatalError()
    }

    public func hasKey<T: DefaultsSerializable>(_ key: DefaultsKey<T>) -> Bool {
        return defaults.object(forKey: key._key) != nil
    }

    public func hasKey<T: DefaultsSerializable>(_ keyPath: KeyPath<KeyStore, DefaultsKey<T>>) -> Bool {
        return hasKey(keyStore[keyPath: keyPath])
    }

    public func remove<T: DefaultsSerializable>(_ key: DefaultsKey<T>) {
        defaults.removeObject(forKey: key._key)
    }

    public func remove<T: DefaultsSerializable>(_ keyPath: KeyPath<KeyStore, DefaultsKey<T>>) {
        remove(keyStore[keyPath: keyPath])
    }

    public func removeAll() {
        for (key, _) in defaults.dictionaryRepresentation() {
            defaults.removeObject(forKey: key)
        }
    }
}

extension DefaultsAdapter {
    public subscript<T: DefaultsSerializable>(key key: DefaultsKey<T>) -> T where T.T == T {
        get {
            return defaults[key]
        }
        nonmutating set {
            defaults[key] = newValue
        }
    }

    public subscript<T: DefaultsSerializable>(keyPath: KeyPath<KeyStore, DefaultsKey<T>>) -> T where T.T == T {
        get {
            return defaults[keyStore[keyPath: keyPath]]
        }
        nonmutating set {
            defaults[keyStore[keyPath: keyPath]] = newValue
        }
    }

    public subscript<T: DefaultsSerializable>(dynamicMember keyPath: KeyPath<KeyStore, DefaultsKey<T>>) -> T where T.T == T {
        get {
            return self[keyPath]
        }
        nonmutating set {
            self[keyPath] = newValue
        }
    }
    public subscript<T: DefaultsSerializable>(key: String) -> T? where T.T == T {
        get { return defaults[key] } 
        nonmutating set {
            defaults[key] = newValue
        }
    }
}

public extension UserDefaults {

    subscript<T: DefaultsSerializable>(key: DefaultsKey<T>) -> T where T.T == T {
        get {
            if let value = T._defaults.get(key: key._key, userDefaults: self) {
                return value
            } else {
                return key.defaultValue
            }
        }
        set {
            T._defaults.save(key: key._key, value: newValue, userDefaults: self)
        }
    }
    subscript<T: DefaultsSerializable>(key: String) -> T? where T.T == T {
        get {
            T._defaults.get(key: key, userDefaults: self)
        }
        set {
            T._defaults.save(key: key, value: newValue, userDefaults: self)
        }
    }
}
