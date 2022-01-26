//
//  UserDefaults+Add.swift
//  SwifterKnife
//
//  Created by liyang on 2022/1/19.
//

import Foundation


extension UserDefaults {
    func removeAll(where shouldBeRemoved: (String) throws -> Bool) rethrows {
        for (key, _) in dictionaryRepresentation() {
            if try shouldBeRemoved(key) {
                removeObject(forKey: key)
            }
        }
    }
}
