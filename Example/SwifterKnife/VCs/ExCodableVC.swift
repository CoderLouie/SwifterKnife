//
//  ExCodableVC.swift
//  SwifterKnife_Example
//
//  Created by 李阳 on 2023/10/13.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import SwifterKnife

class ExCodableVC: BaseViewController {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        test_codable6()
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
                try decode(from: decoder, with: Self.keyMapping)
            }
        }
        
        class Player: Codable, ExCodingKeyMap, DataCodable, CustomDebugStringConvertible, PropertyValuesConvertible {
            static var keyMapping: [KeyMap<Player>] {
                [KeyMap(\.name, to: "player_name"),
                 KeyMap(\.age, to: "age"),
                 KeyMap(models: \.remarks, to: "scoreInfo.remarks")]
            }
            
            required init(from decoder: Decoder) throws {
                try decode(from: decoder, with: Self.keyMapping)
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
            
            print(player.propertyValues.jsonString() ?? "nil")
            
            print(player.toString())
        } catch {
            print(error)
        }
    }
    
    private func test_codable5() {
        struct Remark: Codable, ExCodingKeyMap, CustomDebugStringConvertible {
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
            init(from decoder: Decoder) throws {
                try decode(from: decoder, with: Self.keyMapping)
            }
        }
        
        struct Player: Codable, ExCodingKeyMap, DataCodable {
            static var keyMapping: [KeyMap<Player>] {
                [KeyMap(model: \.remark, to: "scoreInfo.remarks")]
            }
            
            init(from decoder: Decoder) throws {
                try decode(from: decoder, with: Self.keyMapping)
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
        struct Remark: Codable, ExCodingKeyMap, CustomDebugStringConvertible {
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
                try decode(from: decoder, with: Self.keyMapping)
            }
        }
        
        struct Player: Codable, ExCodingKeyMap, DataCodable {
            static var keyMapping: [KeyMap<Player>] {
                [
                    KeyMap(\.name, to: "player_name"),
                    KeyMap(\.age, to: "age"),
                    KeyMap(models: \.remarks, to: "scoreInfo.remarks")]
            }
            
            init(from decoder: Decoder) throws {
                try decode(from: decoder, with: Self.keyMapping)
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
                try decode(from: decoder, with: Self.keyMapping)
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
                try decode(from: decoder, with: Self.keyMapping)
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
                try decode(from: decoder, with: Self.keyMapping)
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
                try decode(from: decoder, with: Self.selfKeyMapping)
            }
            override func encode(to encoder: Encoder) throws {
                try super.encode(to: encoder)
                try encode(to: encoder, with: Self.selfKeyMapping)
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
