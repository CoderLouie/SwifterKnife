//
//  Notify.swift
//  SwifterKnife
//
//  Created by 李阳 on 2023/8/4.
//

import Foundation



public enum Notify {
    private final class Wrapper {
        
        weak var object: AnyObject? {
            willSet {
                print("Notify.Wrapper willSetObject", newValue == nil)
            }
            didSet {
                print("Notify.Wrapper didSetObject", object == nil)
                if object == nil {
                    clear()
                }
            }
        }
        var closure: ((Wrapper, AnyObject, Notification) -> Void)?
        
        init(object: AnyObject, closure: @escaping (Wrapper, AnyObject, Notification) -> Void) {
            self.object = object
            self.closure = closure
        }
        @objc func didReceiveNotification(_ sender: Notification) {
            guard let obj = object else {
                clear()
                return
            }
            closure?(self, obj, sender)
        }
        func clear() {
            closure = nil
            Notify.remove(ref: self)
        }
        deinit {
            Console.logFunc(whose: self)
        }
    }
    
    private static var refs: [Wrapper] = []
    @discardableResult
    private static func remove(ref: Wrapper) -> Bool {
        guard let idx = refs.firstIndex(where: { $0 === ref }) else {
            return false
        }
        refs.remove(at: idx)
        return true
    }
    
    public static func post(name: Notification.Name, userInfo: [AnyHashable: Any]? = nil) {
        NotificationCenter.default.post(name: name, object: nil, userInfo: userInfo)
    }
    
    public static func addObserver(_ observer: Any, selector aSelector: Selector, name aName: Notification.Name) {
        NotificationCenter.default.addObserver(observer, selector: aSelector, name: aName, object: nil)
    }
    
    public static func addObserver<T: AnyObject>(_ observer: T, name aName: Notification.Name, closure: @escaping (T, Notification) -> Void) {
        let wrap = Wrapper(object: observer) { w, object, no in
            guard let obj = object as? T else {
                w.clear()
                return
            }
            closure(obj, no)
        }
        refs.append(wrap)
        
        NotificationCenter.default.addObserver(wrap, selector: #selector(Wrapper.didReceiveNotification(_:)), name: aName, object: nil)
    }
    
    public static func peek() {
        Console.log("Notify peek", refs.last?.object ?? "nil")
    }
}



