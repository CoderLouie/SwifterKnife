//
//  UserDefaults+Add.swift
//  SwifterKnife
//
//  Created by liyang on 2022/1/19.
//

import Foundation


public extension UserDefaults {
    func removeAll(where shouldBeRemoved: (String) throws -> Bool) rethrows {
        for (key, _) in dictionaryRepresentation() {
            if try shouldBeRemoved(key) {
                removeObject(forKey: key)
            }
        }
    }
    
    func number(forKey key: String) -> NSNumber? {
        return object(forKey: key) as? NSNumber
    }
    
//    func decodable<T: Decodable>(forKey key: String) -> T? {
//        guard let decodableData = data(forKey: key) else { return nil }
//
//        return try? JSONDecoder().decode(T.self, from: decodableData)
//    }

    /// Encodes passed `encodable` and saves the resulting data into the user defaults for the key `key`.
    /// Any error encoding will result in an assertion failure.
//    func set<T: Encodable>(encodable: T, forKey key: String) {
//        do {
//            let data = try JSONEncoder().encode(encodable)
//            set(data, forKey: key)
//        } catch {
//            assertionFailure("Failure encoding encodable of type \(T.self): \(error.localizedDescription)")
//        }
//    }
}
