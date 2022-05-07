//
//  Checkman.swift
//  SwifterKnife
//
//  Created by liyang on 2021/10/24.
//

import Foundation

public enum TicketHandleResult {
    case remove
    case skip
    case retry
    case retryWithDelay(TimeInterval)
    case skipWithDelay(TimeInterval)
}
public protocol TicketHandle: Persistentable {
    static func handle(ticket: Self, for checkman: Checkman<Self>, completion: @escaping (TicketHandleResult) -> Void)
}
 

fileprivate extension TicketHandle {
    var t_filename: String {
        "\(Int(round(Date().timeIntervalSince1970)))"
    }
}

/*
 类似于验票员在不断提供验票服务
 用于在后台线程不断处理一些可以归档到文件中的数据
 */
public final class Checkman<T: TicketHandle> {
    public private(set) var isWorking = false
    public private(set) var retryCount = 0
    public let workspace: String
    public let fetchBehavior: FetchBehavior
    public enum FetchBehavior {
        /// 随机获取
        case random
        /// 先入先出
        case queued
    }
    
    public init(workspace path: String,
                fetchBehavior: FetchBehavior = .random) {
        let url = URL(fileURLWithPath: path)
        guard url.isFileURL else { fatalError("workspace must be a validate filepath") }
        
        let folder = path.hasSuffix("/") ? path : (path as NSString).deletingLastPathComponent
        try? FileManager.default.createDirectory(atPath: folder, withIntermediateDirectories: true, attributes: nil)
        
        workspace = folder
        workQueue = DispatchQueue(label: "com.swifterknife.checkman.\((folder as NSString).lastPathComponent)")
        self.fetchBehavior = fetchBehavior
    }
    
    public func append(ticket item: T) {
        workQueue.async { self._append(ticket: item) }
    }
    private func _append(ticket item: T) {
        let path = (workspace as NSString).appendingPathComponent(item.t_filename)
        
        try? item.save(toFile: path)
        _awake()
    }
    
    
    public func awake() {
        workQueue.async { self._awake() }
    }
    private func _awake() {
        if isWorking { return }
        isWorking = true
        retryCount = 0
        
        let folder = workspace
        let manager = FileManager.default
        guard let contents = try? manager.contentsOfDirectory(atPath: folder).filter({ !$0.hasPrefix(".") }),// 过滤隐藏文件
              let filename = (fetchBehavior == .random ?
                                contents.randomElement() :
                                contents.sorted().first) else {
            Console.log(workspace + " is cleaned")
            // 已经全部上传上传完毕
            isWorking = false
            return
        }
        let path = folder + filename
        
        guard let item = try? T.load(fromFile: path) else {
            // 此文件可能被损坏，删除此文件
            try? manager.removeItem(atPath: path)
            goon()
            return
        }
        handle(tickt: item, at: path, by: manager)
    }
    
    private func handle(tickt item: T,
                        at path: String,
                        by manager: FileManager) {
        T.handle(ticket: item, for: self) { [weak self] result in
            guard let sself = self else { return }
            sself.workQueue.async { [weak sself] in
                guard let this = sself else { return }
                switch result {
                case .remove:
                    try? manager.removeItem(atPath: path)
                    this.goon()
                case .skip:
                    this.skip(tickt: item, at: path, by: manager)
                    
                case .retry:
                    this.retryCount += 1
                    this.handle(tickt: item, at: path, by: manager)
                case .retryWithDelay(let timeDelay):
                    this.workQueue.asyncAfter(deadline: .now() + timeDelay) { [weak this] in
                        this?.retryCount += 1
                        this?.handle(tickt: item, at: path, by: manager)
                    }
                case .skipWithDelay(let timeDelay):
                    this.workQueue.asyncAfter(deadline: .now() + timeDelay) { [weak this] in
                        this?.skip(tickt: item, at: path, by: manager)
                    }
                }
            }
        }
    }
    
    private func skip(tickt item: T,
                      at path: String,
                      by manager: FileManager) {
        guard fetchBehavior == .queued else {
            self.goon()
            return
        }
        // 修改文件名，让其排到最后
        let folder = workspace
        let newPath = (folder as NSString).appendingPathComponent(item.t_filename)
        do {
            try manager.moveItem(atPath: path, toPath: newPath)
        } catch {
            try? manager.removeItem(atPath: path)
        }
        self.goon()
    }
    private func goon() {
        isWorking = false
        _awake()
    }
    
    
    private let workQueue: DispatchQueue
}
