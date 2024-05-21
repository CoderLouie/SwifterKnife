//
//  Broadcaster.swift
//  SwifterKnife
//
//  Created by liyang on 2023/12/15.
//

import Foundation


public enum Broadcaster {
    private final class Weak {
        weak var object: AnyObject?
        init<T>(_ item: T) {
            self.object = item as AnyObject
        }
    }
    
    private static var observerMap: [String: [Weak]] = [:]
    private static let queue = DispatchQueue(label: "com.Broadcaster.dispatch.queue", attributes: .concurrent)
    
    public static func register<T>(_ protocolType: T.Type, observer: T) {
        observers(for: protocolType, true) {
            $0.append(Weak(observer))
        }
    }
    public static func unregister<T>(_ protocolType: T.Type, observer: T) {
        observers(for: protocolType, false) { array in
            let id = ObjectIdentifier(observer as AnyObject)
            array.removeAll {
                guard let tmp = $0.object else { return true }
                return id == ObjectIdentifier(tmp)
            }
        }
    }
    
    public static func unregister<T>(_ protocolType: T.Type) {
        let key = "\(protocolType)"
        queue.async(flags: .barrier) {
            observerMap.removeValue(forKey: key)
        }
    }
    
    public static func notify<T>(_ protocolType: T.Type, block: (T) -> Void ) {
        let observers = observers(for: protocolType)
        observers.forEach(block)
    }
    public static func asyncNotify<T>(_ protocolType: T.Type, block: @escaping (T) -> Void ) {
        let observers = observers(for: protocolType)
        guard !observers.isEmpty else { return }
        DispatchQueue.main.async {
            for ob in observers {
                block(ob)
            }
        }
    }
    public static func observers<T>(for protocolType: T.Type) -> [T] {
        let key = "\(protocolType)"
        return queue.sync {
            if var array = observerMap[key] {
                array = array.filter { $0.object != nil }
                observerMap[key] = array
                return array.compactMap { $0.object as? T }
            } else {
                return []
            }
        }
    }
}

extension Broadcaster {
    private static func observers<T>(for protocolType: T.Type, _ createIfNeeded: Bool, _ closure: @escaping (inout [Weak]) -> Void) {
        let key = "\(protocolType)"
        queue.async(flags: .barrier) {
            if var array = observerMap[key] {
                array = array.filter { $0.object != nil }
                closure(&array)
                observerMap[key] = array
            } else {
                guard createIfNeeded else { return }
                var array: [Weak] = []
                closure(&array)
                observerMap[key] = array
            }
        }
    }
}
