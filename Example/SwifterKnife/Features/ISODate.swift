//
//  ISODate.swift
//  SwifterKnife
//
//  Created by liyang on 2023/8/3.
//

import Foundation
import SwifterKnife


public enum ISODate {
    
    @SwiftyCachedDefaults(key: "iso_date_runtimeRef")
    private static var runtime: TimeInterval = 0
    
    @SwiftyCachedDefaults(key: "iso_date_serverTimeRef")
    private static var servertime: TimeInterval = 0
    
    @SwiftyCachedDefaults(key: "iso_date_systemUptimeRef")
    private static var systemUptime: TimeInterval = 0
    
    public static var isValid: Bool {
        let uptimeDelta = ProcessInfo.processInfo.systemUptime - systemUptime
        let refDelta = Double(now() - boottime() - runtime)
        return abs(uptimeDelta - refDelta) < 5
    }
    
    public static func work(_ completion: ((Bool) -> Void)?) {
        if isValid {
            completion?(true)
            return
        }
        
        runtime = 0
        servertime = 0
        systemUptime = 0
        
        pullRemote(completion)
    }
    public static func pullRemote(_ completion: ((Bool) -> Void)?) {
        fetchServerDate {
            sync(from: $0)
            let ok = $0 != nil
            DispatchQueue.main.async {
                completion?(ok)
            }
        }
    }
    
    public static func fetchServerDate(_ completion: @escaping (Date?) -> Void) {
        guard let url = URL(string: "https://www.baidu.com") else {
            completion(nil)
            return
        }
        URLSession.shared.dataTask(with: url) { _, res , _ in
            completion((res as? HTTPURLResponse)?.at_date)
        }.resume()
    }
    
    public static func sync(from isoDate: Date?) {
        guard let date = isoDate else { return }
        servertime = date.timeIntervalSince1970
        runtime = now() - boottime()
        systemUptime = ProcessInfo.processInfo.systemUptime
    }
    
    public static var date: Date? {
        interval.map(Date.init(timeIntervalSince1970:))
    }
    public static var dateV: Date {
        date ?? Date()
    }
    
    public static var interval: TimeInterval? {
        if runtime > 0 {
            return servertime + (now() - boottime() - runtime)
        }
        return nil
    }
    
    public static var intervalV: TimeInterval {
        interval ?? now()
    }
}


public extension ISODate {
    /// 获取当前 Unix Time
    static func now() -> TimeInterval {
        var now = timeval()
        var tz = timezone()
        gettimeofday(&now, &tz)
        return TimeInterval(now.tv_sec)
    }
    /// 获取设备上次重启的 Unix Time
    static func boottime() -> TimeInterval {
        var mid = [CTL_KERN, KERN_BOOTTIME]
        var boottime = timeval()
        var size = MemoryLayout.size(ofValue: boottime)
        if sysctl(&mid, 2, &boottime, &size, nil, 0) != -1 {
            return TimeInterval(boottime.tv_sec)
        }
        return 0
    }
}
