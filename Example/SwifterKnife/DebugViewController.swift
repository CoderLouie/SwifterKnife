//
//  DebugViewController.swift
//  SwifterKnife_Example
//
//  Created by 李阳 on 2022/11/20.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import SwifterKnife
import Photos

extension String {
    var negativeWord: String? {
        let path = "censorship.txt".filePath(under: .bundle)
        return SandBox.readLines(path) {
            contains($0)
        }
    }
}


import Lottie

extension LottieAnimationView {
    static var frog: LottieAnimationView {
        LottieAnimationView(name: "青蛙").then {
            $0.contentMode = .scaleAspectFill
            $0.backgroundColor = .clear
            $0.loopMode = .loop
            $0.backgroundBehavior = .pauseAndRestore
        }
    }
}

fileprivate class TestCaseCell: UITableViewCell, Reusable {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
    }
}
 
fileprivate enum TestCase: String, CaseIterable {
    case negative = "敏感词汇"
    case shuffled
    case watermark
    case overlay
    case overlay1
    case overlay2
    case defaults = "UserDefaults"
    
    case statement = "Statement"
    case home = "Home"
    case fitImageView
    case other
    case dictation = "语音输入"
    case testUI = "Test UI"
    case codable = "Codable"
    case excodable = "ExCodable"
    case permission = "Permission"
    var token: String {
        return "\(#fileID)_\(#function)_\(#line)"
    }
    
    func perform(from vc: DebugViewController) {
        switch self {
        case .shuffled:
//            let nums = [0, 2, 4, 7, 6]
//            nums.forEach(slice: 2) { print($0) }
            print(AssociationKey.current())
            print(AssociationKey.current())
            print(token)
//            let nums = Array(0...5)
//            print(nums.shuffledOfLength(8))
//            print(nums.shuffledOfLength(7))
//            print(nums.shuffledOfLength(6))
//            print(nums.shuffledOfLength(4))
//            print(nums.shuffledOfLength(3))
//            print(nums.shuffledOfLength(1))
//            print(nums.shuffledOfLength(0))
        case .negative:
            let word = "(1man), (male:1.2), youthful face, finely detailed eyes and face, unique and captivating look, exudes an air of sophistication, sienna skin, ombre spiky hair, silver eyes, Style-GravityMagic, focus on character, portrait, looking down, solo, ((upper body)), detailed background, ( (DarkFantasy:0.8), dark fantasy theme:1.1), privateer, rich Musket Brown pirate sailor outfit, bandana, evil grin, high seas, jolly roger flag, flintlock pistol, whirlpool, dark storm, rum, sunrise, pirate fantasy atmosphere, finely detailed background, Depth of Field, VFX',10:'Portrait photo of muscular bearded guy in a worn mech suit, ((light bokeh)), intricate, (steel metal [rust]), elegant, sharp focus, photo by greg rutkowski, soft lighting, vibrant colors, (masterpiece), ((streets)), (detailed face:1.2), (glowing blue eyes:1.1)"
            print("[negativeWord]", word.negativeWord ?? "nil")
        case .dictation:
            let nextVc = DictationVC()
            vc.navigationController?.pushViewController(nextVc, animated: true)
        case .overlay2:
            let videoPath = "inputResources.mp4".filePath(under: .bundle)
            let destPath = "watermark.mp4".filePath(under: .temporary)
//            LottieConfiguration.shared.renderingEngine = .mainThread
            let mark = LottieAnimationView.frog.then {
                $0.animationSpeed = 5
                $0.frame = CGRect(x: 150, y: 340, width: 80, height: 80)
                $0.play { _ in
                    print("lottie play finish")
                }
            }
            let begin = CACurrentMediaTime()
            let editor = YiVideoEditor(videoURL: .init(fileURLWithPath: videoPath))
            editor.addOverlay { _ in mark.layer }
            let destUrl = URL(fileURLWithPath: destPath)
            editor.export(at: destUrl) { session in
                let error = session.error
                print("[export finish]", begin.coseTime, error ??? "nil")
                if error == nil {
                    PhotoManager.saveVideoToAlbum(url: destUrl) { success in
                        print("[Save finish]", success.opDescription, begin.coseTime)
                    }
                }
            }
        case .overlay1:
            let videoPath = "inputResources.mp4".filePath(under: .bundle)
            let destPath = "watermark.mp4".filePath(under: .temporary)
//            LottieConfiguration.shared.renderingEngine = .mainThread
            let mark = LottieAnimationView.frog.then {
                $0.animationSpeed = 5
                $0.frame = CGRect(x: 150, y: 340, width: 80, height: 80)
                $0.play { _ in
                    print("lottie play finish")
                }
            }
            let begin = CACurrentMediaTime()
            let flag = VideoEditor.addOverlay(mark.layer, to: videoPath, exportAt: destPath) { error in
                print("[export finish]", begin.coseTime, error ??? "nil", mark.frame)
                if error == nil {
                    PhotoManager.saveVideoToAlbum(url: URL(fileURLWithPath: destPath)) { success in
                        print("[Save finish]", success.opDescription, begin.coseTime)
                    }
                }
            }
            print("[Add Overlay]", flag.opDescription)
        case .overlay:
            let videoPath = "apple.mp4".filePath(under: .bundle)
            let destPath = "watermarkapple3.mp4".filePath(under: .document)
            let begin = CACurrentMediaTime()
            let flag = VideoEditor.addOverlay({ bounds in
                let layer = CALayer().then {
                    $0.backgroundColor = UIColor.red.cgColor
                    $0.frame = CGRect(x: 10, y: 10, width: 60, height: 30)
                }
                return [layer]
            }, to: videoPath, exportAt: destPath) { error in
                print("[export finish]", begin.coseTime, error ??? "nil")
                if error == nil {
                    PhotoManager.saveVideoToAlbum(url: URL(fileURLWithPath: destPath)) { success in
                        print("[Save finish]", success.opDescription, begin.coseTime)
                    }
                }
            }
            print("[Add Overlay]", flag.opDescription)
        case .watermark:
            let filename = "apple.mp4"
//            let filename = "IMG_4396.MOV"
            let tmpUrl = URL(fileURLWithPath: filename.filePath(under: .bundle))
            let videoEditor = YiVideoEditor(videoURL: tmpUrl)
            videoEditor.addOverlay { _ in
                CALayer().then {
                    $0.backgroundColor = UIColor.red.cgColor
                    $0.frame = CGRect(x: 10, y: 10, width: 40, height: 20)
                }
            }
            let destPath = "watermarkapple1.mp4".filePath(under: .document)
            let destUrl = URL(fileURLWithPath: destPath)
            videoEditor.export(at: destUrl) { session in
                print("[AIDream] export finished", session.status.rawValue, session.error ??? "nil")
                if session.status == .completed {
                    PhotoManager.saveVideoToAlbum(url: destUrl) { success in
                        if success {
                            print("save success")
                        }
                    }
                }
            }
        case .statement:
            statement_test_entry()
        case .defaults:
            userdefault_test_entry()
        case .home:
            let nextVc = HomeViewController()
            vc.navigationController?.pushViewController(nextVc, animated: true)
        case .fitImageView:
            let nextVc = FitImageViewVC()
            vc.navigationController?.pushViewController(nextVc, animated: true)
        case .testUI:
            let nextVc = TestUIVC()
            vc.navigationController?.pushViewController(nextVc, animated: true)
        case .codable:
            let nextVc = CodableVC()
            vc.navigationController?.pushViewController(nextVc, animated: true)
        case .excodable:
            let nextVc = ExCodableVC()
            vc.navigationController?.pushViewController(nextVc, animated: true)
        case .other:
//            print(Facecore.celebrity.timeoutInterval)
//            let nextVc = ViewController()
//            vc.navigationController?.pushViewController(nextVc, animated: true)
//            testConsole()
            testJSON()
            break
        case .permission:
            print("permission")
            let nextVc = WaterflowVC()
            vc.navigationController?.pushViewController(nextVc, animated: true)
//            Promise<Int>.repeatWhile { index, finish in
//                Console.trace("begin request", index)
//                if index == 3 { finish(.fulfill(10)) }
//                else {  finish(.retry(after: 1))  }
//            }.then { val in
//                Console.trace("fulfill with", val)
//            } onRejected: { err in
//                Console.trace("reject with", err)
//            }
//            let status: PHAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
//            var i = 0
//            Permission.request(exis: status, map: \.myStatus) { status, isFirst in
//                Console.trace(status, isFirst)
//            } work: { finish in
//                Console.trace("start request", i)
//                if i == 3 { finish(.authorized) }
//                else { finish(.notDetermined) }
//                i += 1
//            }
        }
    }
    
    
    private func testWeakArray() {
        var nums: [Int] = []
        var table = WeakTable<XXXXDog>()
        let val = table.remove(at: 0)
//        table.append(<#T##newElement: XXXXDog?##XXXXDog?#>)
//        var weaArr: WeakArray<XXXXDog> = .init(XXXXDog(), XXXXDog())
//        weaArr.append(.init(.init()))
//        weaArr.append(.init())
//        let vc = weaArr[weak: 10]
    }
    private func testJSON() {
//        let str = """
//{"error_code":0,"data":{"task_id":6,"graphics_type":43,"status":3,"process_result":"{\"error_code\":0,\"data\":{\"request_id\":\"vd.43.9a4c89f798daaee66095514fa03f4221174ef83c\",\"result_list\":[{\"style_code\":\"c57c2afd03a144e5\",\"strength\":0.0,\"generate_size\":1,\"image_list\":[\"http://osscdn-va.changxinteam.com/graphics2/portrait/temp/2023-12-13/2c50454d-1c0f-4464-9e41-79d3815f5004.jpg\"]}]}}"}}
//"""
        let dict: [String: Any] = [
            "error_code": 0,
            "data": [
                "task_id":6,
                "graphics_type":43,
                "status":3,
                "process_result":"{\"error_code\":0,\"data\":{\"request_id\":\"vd.43.9a4c89f798daaee66095514fa03f4221174ef83c\",\"result_list\":[{\"style_code\":\"c57c2afd03a144e5\",\"strength\":0.0,\"generate_size\":1,\"image_list\":[\"http://osscdn-va.changxinteam.com/graphics2/portrait/temp/2023-12-13/2c50454d-1c0f-4464-9e41-79d3815f5004.jpg\"]}]}}"
                ]
        ]
        let json = JSON(dict)
        let dataJSON = json["data"]
        let resultJSON = dataJSON["process_result"]
        let resultDataJSON = resultJSON["data"]
        print(resultJSON["error_code"].intValue,
              resultDataJSON["request_id"].stringValue,
              resultDataJSON["result_list"].arrayValue)
    }
    private func testConsole() {
        let values: [String: Any] = [
            "age": 10,
            "score": [10, 20, 30],
            "name": "xiaohuang"
        ]
        let num = 10
        let val = 3.1415926
        Console.log(num, val, "喝了咯 hello %@ %05d, %.3f, %d", values, num, val, Seasion.spring, num, val)
    }
    private func testLog() {
        Console.os("测试This is a defalut message.")
        Console.osError("测试This is a error message.")
        Console.osFault("测试This is a fault message.")
    }
    
//    private func testchoose2() {
//        var isMal = true
//        let choose = isMal.choose(String.self)
//        let str = choose("man", "woman")
//        print(str)
//        isMal = false
//        print(str, choose("man", "woman"))
//    }
}
enum Seasion { case spring }
//extension Seasion: CVarArg {
//    var _cVarArgEncoding: [Int] {
//        [0]
//    }
//}
 
protocol UpdateTitle {
    func updateTitle(_ title: String)
}
final class XXXXDog: UpdateTitle {
    func updateTitle(_ title: String) {
        print("Seasion updateTitle \(title)")
    }
}
enum NetError: Swift.Error {}
class DebugViewController: BaseViewController {
    private let s: Seasion = .spring
    private let s1 = Seasion.spring as AnyObject
    private let dog = XXXXDog()
    override func setupViews() {
        super.setupViews()
        title = "Debug"
        setupBody()
        Broadcaster.register(UpdateTitle.self, observer: self.dog)
//        Broadcaster.register(UpdateTitle.self, observer: self.s1)
//        Broadcaster.register(UpdateTitle.self, observer: self.s)
//        Broadcaster.register(UpdateTitle.self, observer: Seasion.spring)
    }
    private unowned var tableView: UITableView!
    private lazy var items: [TestCase] = TestCase.allCases
}
 
// MARK: - Delegate
extension DebugViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: TestCaseCell = tableView.dequeueReusableCell(for: indexPath)
        let index = indexPath.row
        let text = String(format: "%02d. ", index) + items[index].rawValue
        cell.textLabel?.text = text
        return cell
    }
}
//
extension DebugViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        items[indexPath.row].perform(from: self)
//        Broadcaster.notify(UpdateTitle.self) {
//            $0.updateTitle("哈哈哈哈")
//        }
    }
}

// MARK: - Create Views
extension DebugViewController {
    
    private func setupBody() {
        tableView = UITableView().then {
            $0.backgroundColor = .clear
            $0.tableFooterView = UIView()
            $0.contentInsetAdjustmentBehavior = .never
            $0.separatorStyle = .none
            $0.delegate = self
            $0.dataSource = self
            $0.rowHeight = 45.fit
            $0.register(cellType: TestCaseCell.self)
            view.addSubview($0)
            $0.contentInset = UIEdgeInsets(top: Screen.navbarH, left: 0, bottom: Screen.safeAreaB, right: 0)
            $0.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
    }
}
