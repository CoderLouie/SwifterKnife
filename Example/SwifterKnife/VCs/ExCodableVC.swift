//
//  ExCodableVC.swift
//  SwifterKnife_Example
//
//  Created by 李阳 on 2023/10/13.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import SwifterKnife

//public protocol ExDecodable: Decodable, ExCodingKeyMap where Self.Root == Self {
//    init()
//}
//extension ExDecodable {
//    public init(from decoder: Decoder) throws {
////        self.init()
////        print("my init(from:)")
//        self.init(with: decoder, using: Self.keyMapping)
//    }
//    public init(with decoder: Decoder, using keyMapping: [KeyMap<Self>]) {
//        self.init()
//        decode(from: decoder, with: keyMapping)
//    }
//}
/// class 类型得用final修饰才能调用到这里来
//extension ExDecodable where Self: ExCodingKeyMap, Self.Root == Self, Self: AnyObject {
//    public init(from decoder: Decoder) throws {
//        print("my init(from:)")
//        self.init(with: decoder, using: Self.keyMapping)
//    }
//    public init(with decoder: Decoder, using keyMapping: [KeyMap<Self>]) {
//        self.init()
//        decode(from: decoder, with: keyMapping)
//    }
//}

//public typealias ExCodable = ExDecodable & Encodable

class ExCodableVC: BaseViewController {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        test_codable5()
//        test_codable52()
        test_codable72()
    }
    private func test_codable8() {
        struct Tag: RawRepresentable {
            let rawValue: String
            init(rawValue: String) {
                self.rawValue = rawValue
            }
        }
        enum Gender {
            case man, woman
        }
        enum Country: String {
            case china, america
        }
        class LYPerson {
            var tag: Tag = .init(rawValue: "person")
            var name = "xiaohua"
            var age = 20
            var country: Country = .china
        }
        final class LYClass {
            var name = "三年级(5)班"
        }
        final class LYStudent: LYPerson, PropertyValuesConvertible {
            var theClass = LYClass()
            var score = 90
        }
        let stu = LYStudent()
        let map = stu.propertyMap
        print(map.jsonString() ?? "nil")
        let dict = map as NSDictionary
        NSLog("%@", dict)
    }
    
    private func test_codable72() {
        class Remark: ExAutoCodable, CustomDebugStringConvertible {
            @ExCodableKeyMap("r_judge")
            var judge: String = ""
            @ExCodableKeyMap("r_content")
            var content: String = ""
            
            var debugDescription: String {
                "(judge: \(judge), content: \(content))"
            }
            required init() {}
        }
        
        class Player: ExAutoCodable, DataCodable, PropertyValuesConvertible, CustomDebugStringConvertible {
            @ExCodableKeyMap("player_name")
            var name: String = ""
            @ExCodableMap
            var age: Int = 0
            @ExCodableKeyMap("is_male")
            var isMale: Bool = false
            @ExCodableKeyMap("scoreInfo.remarks")
            var remarks: [Int: Remark] = [:]
            
            var debugDescription: String {
                "name: \(name), age: \(age), isMale: \(isMale), remarks: \(remarks)"
            }
            required init() {}
        }
        
        let str = """
        {
            "player_name": "balabala Team",
            "age": "30",
            "is_male": "10",
            "scoreInfo": {
                "remarks": {
                    "1": {
                        "r_judge": "judgeOne",
                        "r_content": "good"
                    },
                    "2": {
                        "r_judge": "judgeTwo",
                        "r_content": "very good"
                    },
                    "3": {
                        "r_judge": "judgeThree",
                        "r_content": "bad"
                    }
                }
            }
        }
        """
        do {
            let player = try Player.decode(from: str)
            print(player)
            
            print(player.propertyMap.jsonString() ?? "nil")
            
            print(player.toString())
        } catch {
            print(error)
        }
    }
    private func test_codable71() {
        class Remark: ExDecodable, ExCodingKeyMap, CustomDebugStringConvertible {
            static var keyMapping: [KeyMap<Remark>] {
                [KeyMap(\.judge, to: "r_judge"),
                 KeyMap(\.content, to: "r_content")]
            }
            var judge: String = ""
            var content: String = ""
            
            var debugDescription: String {
                "(judge: \(judge), content: \(content))"
            }
            required init() {}
        }
        
        class Player: ExDecodable, ExCodingKeyMap, DataDecodable, CustomDebugStringConvertible {
            static var keyMapping: [KeyMap<Player>] {
                [KeyMap(\.name, to: "player_name"),
                 KeyMap(\.age, to: "age"),
                 KeyMap(\.isMale, to: "is_male"),
                 KeyMap(\.remarks, to: "scoreInfo.remarks")]
            }
            required init() {}
            
            var name: String = ""
            var age: Int = 0
            var isMale: Bool = false
            var remarks: [Int: Remark] = [:]
            
            var debugDescription: String {
                "name: \(name), age: \(age), isMale: \(isMale), remarks: \(remarks)"
            }
        }
        
        let str = """
        {
            "player_name": "balabala Team",
            "age": "30",
            "is_male": "10",
            "scoreInfo": {
                "remarks": {
                    "1": {
                        "r_judge": "judgeOne",
                        "r_content": "good"
                    },
                    "2": {
                        "r_judge": "judgeTwo",
                        "r_content": "very good"
                    },
                    "3": {
                        "r_judge": "judgeThree",
                        "r_content": "bad"
                    }
                }
            }
        }
        """
        do {
            let data = Data(str.utf8)
//            let player = try Player.decode(from: str)
            let player = try JSONDecoder().decode(Player.self, from: data)
            print(player)
        } catch {
            print(error)
        }
    }
    private func test_codable7() {
        final class Remark: ExCodable, ExCodingKeyMap, CustomDebugStringConvertible {
            static var keyMapping: [KeyMap<Remark>] {
                [KeyMap(\.judge, to: "r_judge"),
                 KeyMap(\.content, to: "r_content")]
            }
            var judge: String = ""
            var content: String = ""
            
            var debugDescription: String {
                "(judge: \(judge), content: \(content))"
            }
//            required init(from decoder: Decoder) throws {
//                decode(from: decoder, with: Self.keyMapping)
//            }
        }
        
        final class Player: ExCodable, ExCodingKeyMap, DataCodable, CustomDebugStringConvertible, PropertyValuesConvertible {
            static var keyMapping: [KeyMap<Player>] {
                [KeyMap(\.name, to: "player_name"),
                 KeyMap(\.age, to: "age"),
                 KeyMap(\.isMale, to: "is_male"),
                 KeyMap(\.remarks, to: "scoreInfo.remarks")]
            }
//
//            required init(from decoder: Decoder) throws {
//                decode(from: decoder, with: Self.keyMapping)
//            }
            
            var name: String = ""
            var age: Int = 0
            var isMale: Bool = false
            var remarks: [Int: Remark] = [:]
            
            var debugDescription: String {
                "name: \(name), age: \(age), isMale: \(isMale), remarks: \(remarks)"
            }
        }
        
        let str = """
        {
            "player_name": "balabala Team",
            "age": "30",
            "is_male": "10",
            "scoreInfo": {
                "remarks": {
                    "1": {
                        "r_judge": "judgeOne",
                        "r_content": "good"
                    },
                    "2": {
                        "r_judge": "judgeTwo",
                        "r_content": "very good"
                    },
                    "3": {
                        "r_judge": "judgeThree",
                        "r_content": "bad"
                    }
                }
            }
        }
        """
        do {
            let player = try Player.decode(from: str)
            print(player)
            
            print(player.propertyMap.jsonString() ?? "nil")
            
            print(player.toString())
        } catch {
            print(error)
        }
    }
    
    private func test_codable6() {
        class Remark: Codable, ExCodingKeyMap, CustomDebugStringConvertible, PropertyValuesConvertible {
            static var keyMapping: [KeyMap<Remark>] {
                [KeyMap(\.judge, to: "r_judge"),
                 KeyMap(\.content, to: "r_content")]
            }
            var judge: String = ""
            var content: String = ""
            
            var debugDescription: String {
                "(judge: \(judge), content: \(content))"
            }
            required init(from decoder: Decoder) throws {
                decode(from: decoder, with: Self.keyMapping)
            }
        }
        
        class Player: Codable, ExCodingKeyMap, DataCodable, CustomDebugStringConvertible, PropertyValuesConvertible {
            static var keyMapping: [KeyMap<Player>] {
                [KeyMap(\.name, to: "player_name"),
                 KeyMap(\.age, to: "age"),
                 KeyMap(\.remarks, to: "scoreInfo.remarks")]
            }
            
            required init(from decoder: Decoder) throws {
                decode(from: decoder, with: Self.keyMapping)
            }
            
            var name: String = ""
            var age: Int = 0
            var remarks: [Remark] = []
            
            var debugDescription: String {
                "name: \(name), age: \(age), remarks: \(remarks)"
            }
        }
        
        let str = """
        {
            "player_name": "balabala Team",
            "age": 20,
            "scoreInfo": {
                "remarks": [
                    {
                        "r_judge": "judgeOne",
                        "r_content": "good"
                    },
                    {
                        "r_judge": "judgeTwo",
                        "r_content": "very good"
                    },
                    {
                        "r_judge": "judgeThree",
                        "r_content": "bad"
                    }
                ]
            }
        }
        """
        do {
            let player = try Player.decode(from: str)
            print(player)
            
            print(player.propertyMap.jsonString() ?? "nil")
            
            print(player.toString())
        } catch {
            print(error)
        }
    }
    
    private func test_codable52() {
        final class Remark: ExCodable, ExCodingKeyMap {
            static var keyMapping: [KeyMap<Remark>] {
                [KeyMap(\.judge, to: "r_judge"),
                 KeyMap(\.content, to: "r_content")]
            }
            var judge: String = ""
            var content: String = ""
            
            var description: String {
                "(judge: \(judge), content: \(content))"
            }
            required init() {}
        }
        
        class Player: Codable, ExCodingKeyMap, DataCodable {
            static var keyMapping: [KeyMap<Player>] {
                [KeyMap(\.remark, to: "scoreInfo.remarks")]
            }
            
            required init(from decoder: Decoder) throws {
                decode(from: decoder, with: Self.keyMapping)
            }
            var remark: Remark = .init()
            
            var description: String {
                "Player with remaker \(remark)"
            }
        }
        
        let str = """
        {
            "scoreInfo": {
                "remarks": {
                        "r_judge": "judgeOne",
                        "r_content": "good"
                    }
            }
        }
        """
        do {
            let player = try Player.decode(from: str)
            print(player)
            
            print(player.toString())
        } catch {
            print(error)
        }
    }
    private func test_codable5() {
        struct Remark: ExCodable, ExCodingKeyMap, CustomDebugStringConvertible {
            static var keyMapping: [KeyMap<Remark>] {
                [KeyMap(\.judge, to: "r_judge"),
                 KeyMap(\.content, to: "r_content")]
            }
            var judge: String = ""
            var content: String = ""
            
            var debugDescription: String {
                "(judge: \(judge), content: \(content))"
            }
            init() {}
//            init(from decoder: Decoder) throws {
//                decode(from: decoder, with: Self.keyMapping)
//            }
        }
        
        struct Player: Codable, ExCodingKeyMap, DataCodable {
            static var keyMapping: [KeyMap<Player>] {
                [KeyMap(\.remark, to: "scoreInfo.remarks")]
            }
            
            init(from decoder: Decoder) throws {
                decode(from: decoder, with: Self.keyMapping)
            }
            var remark: Remark = .init()
        }
        
        let str = """
        {
            "scoreInfo": {
                "remarks": {
                        "r_judge": "judgeOne",
                        "r_content": "good"
                    }
            }
        }
        """
        do {
            let player = try Player.decode(from: str)
            print(player)
            
            print(player.toString())
        } catch {
            print(error)
        }
    }
    
    private func test_codable4() {
        struct Remark: Codable, ExCodingKeyMap, CustomDebugStringConvertible, Hashable {
            static var keyMapping: [KeyMap<Remark>] {
                [KeyMap(\.judge, to: "r_judge"),
                 KeyMap(\.content, to: "r_content")]
            }
            var judge: String = ""
            var content: String = ""
            
            var debugDescription: String {
                "(judge: \(judge), content: \(content))"
            }
            init(from decoder: Decoder) throws {
                decode(from: decoder, with: Self.keyMapping)
            }
        }
        
        struct Player: Codable, ExCodingKeyMap, DataCodable {
            static var keyMapping: [KeyMap<Player>] {
                [
                    KeyMap(\.name, to: "player_name"),
                    KeyMap(\.age, to: "age"),
                    KeyMap(\.remarks, to: "scoreInfo.remarks")]
            }
            
            init(from decoder: Decoder) throws {
                decode(from: decoder, with: Self.keyMapping)
            }
            
            var name: String = ""
            var age: Int = 0
            var remarks: Set<Remark> = []
        }
        
        let str = """
        {
            "player_name": "balabala Team",
            "age": 20,
            "scoreInfo": {
                "remarks": [
                    {
                        "r_judge": "judgeOne",
                        "r_content": "good"
                    },
                    {
                        "r_judge": "judgeTwo",
                        "r_content": "very good"
                    },
                    {
                        "r_judge": "judgeThree",
                        "r_content": "bad"
                    }
                ]
            }
        }
        """
        do {
            let player = try Player.decode(from: str)
            print(player)
            
            print(player.toString())
        } catch {
            print(error)
        }
    }
    
    private func test_codable3() {
        struct Remark: Decodable, CustomDebugStringConvertible {
            var judge: String = ""
            var content: String = ""
            var debugDescription: String {
                "(judge: \(judge), content: \(content))"
            }
        }
        
        struct Player: Decodable, ExCodingKeyMap, DataDecodable {
            static var keyMapping: [KeyMap<Player>] {
                [KeyMap(\.name, to: "player_name"),
                 KeyMap(\.age, to: "age"),
                 KeyMap(\.remarks, to: "scoreInfo.remarks")]
            }
            
            init(from decoder: Decoder) throws {
                decode(from: decoder, with: Self.keyMapping)
            }
            
            var name: String = ""
            var age: Int = 0
            var remarks: [Remark] = []
        }
        
        let str = """
        {
            "player_name": "balabala Team",
            "age": 20,
            "scoreInfo": {
                "remarks": [
                    {
                        "judge": "judgeOne",
                        "content": "good"
                    },
                    {
                        "judge": "judgeTwo",
                        "content": "very good"
                    },
                    {
                        "judge": "judgeThree",
                        "content": "bad"
                    }
                ]
            }
        }
        """
        do {
            let player = try Player.decode(from: str)
            print(player)
        } catch {
            print(error)
        }
    }
    
    private func test_codable2() {
        struct Remark: CustomDebugStringConvertible {
            var judge: String = ""
            var content: String = ""
            var debugDescription: String {
                "(judge: \(judge), content: \(content))"
            }
        }
        
        struct Player: Decodable, ExCodingKeyMap, DataDecodable {
            static var keyMapping: [KeyMap<Player>] {
                [KeyMap(\.name, to: "player_name"),
                 KeyMap(\.age, to: "age"),
                 KeyMap(\.nativePlace, to: "native_place"),
                 KeyMap(\.grossScore, to: "scoreInfo.gross_score"),
                 KeyMap(\.scores, to: "scoreInfo.scores")]
            }
            
            init(from decoder: Decoder) throws {
                decode(from: decoder, with: Self.keyMapping)
                let remarksContainer = try decoder.nestedContainer(forKey: "scoreInfo.remarks")
                //                var remarks: [Remark] = []
                for key in remarksContainer.allKeys {
                    let judge = key.stringValue
                    let judgeCon = try remarksContainer.nestedContainer(forKey: key)
                    let content: String = try judgeCon.decode(forKey: "content")
                    remarks.append(.init(judge: judge, content: content))
                }
            }
            
            var name: String = ""
            var age: Int = 0
            var nativePlace: String = ""
            var grossScore: CGFloat = 0
            var scores: [Double] = []
            var remarks: [Remark] = []
        }
        
        let str = """
        {
            "player_name": "balabala Team",
            "age": 20,
            "native_Place": "shandong",
            "scoreInfo": {
                "gross_score": 2.4,
                "scores": [
                    0.9,
                    0.8,
                    0.7
                ],
                "remarks": {
                    "judgeOne": {
                        "content": "good"
                    },
                    "judgeTwo": {
                        "content": "very good"
                    },
                    "judgeThree": {
                        "content": "bad"
                    }
                }
            }
        }
        """
        do {
            let player = try Player.decode(from: str)
            print(player)
        } catch {
            print(error)
        }
    }
    
    private func test_codable1() {
        class ZPerson: Codable, ExCodingKeyMap, DataCodable {
            private(set) var age = 20
            private(set) var name = "xiaohua"
            static var keyMapping: [KeyMap<ZPerson>] {
                [KeyMap(\.age, to: "age"),
                 KeyMap(\.name, to: "name", "nick_name")]
            }
            init() {}
            required init(from decoder: Decoder) throws {
                decode(from: decoder, with: Self.keyMapping)
            }
        }
        class ZStudent: ZPerson {
            private(set) var score = 80
            static var selfKeyMapping: [KeyMap<ZStudent>] {
                [KeyMap(\.score, to: "score")]
            }
            override init() { super.init() }
            required init(from decoder: Decoder) throws {
                try super.init(from: decoder)
                decode(from: decoder, with: Self.selfKeyMapping)
            }
            override func encode(to encoder: Encoder) throws {
                try super.encode(to: encoder)
                encode(to: encoder, with: Self.selfKeyMapping)
            }
        }
        let stu = ZStudent()
        let jsonStr = stu.toJSON().jsonString()
        print(jsonStr ?? "nil")
        
        let str = """
        {
            "nick_name": "xiaoming",
            "age": 30,
            "score": 90
        }
        """
        do {
            let stu1 = try ZStudent.decode(from: str)
            print(stu1.name, stu1.age, stu1.score)
        } catch {
            print(error)
        }
    }
}
