//
//  UserDefaultsTest.swift
//  SwifterKnife_Example
//
//  Created by 李阳 on 2023/7/28.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import Foundation

fileprivate enum Gender: String, Codable {
    case man, woman
}
fileprivate struct Tag: RawRepresentable, Codable {
    init(rawValue: Int) {
        self.rawValue = rawValue
    }
    init(_ rawValue: Int) {
        self.rawValue = rawValue
    }
    let rawValue: Int
}
fileprivate extension DefaultsKeys {
    var reviewed: DefaultsKey<Bool?> {
        .init("reviewed")
    }
    var pCount: DefaultsKey<Int?> {
        .init("pCount")
    }
    var reviewCount: DefaultsKey<Int> {
        .init("reviewCount", defaultValue: 100)
    }
    var gender: DefaultsKey<Gender?> {
        .init("gender")
    }
    var niltag: DefaultsKey<Tag?> {
        .init("niltag")
    }
    var tag: DefaultsKey<Tag> {
        .init("tag", defaultValue: Tag(10))
    }
    var genders: DefaultsKey<[Gender]> {
        .init("genders", defaultValue: [])
    }
    var nilgenders: DefaultsKey<[Gender]?> {
        .init("nilgenders")
    }
}

private func peekus() {
    let r = Defaults[\.reviewed]
    let n = Defaults[\.reviewCount]
    let g = Defaults[\.gender]
    let t = Defaults[\.tag]
    let nilt = Defaults[\.niltag]
    let gs = Defaults[\.genders]
    let nilgs = Defaults[\.nilgenders]
    print(r, n, g, t, nilt, gs, nilgs)
}

func userdefault_test_entry() {
    
    peekus()
    Defaults[\.reviewed] = true
    Defaults[\.reviewCount] = 5
    Defaults[\.gender] = .man
    Defaults[\.tag] = Tag(20)
    Defaults[\.niltag] = Tag(8)
    Defaults[\.genders] = [.woman, .man]
    Defaults[\.nilgenders] = [.man]
    
    peekus()
}
