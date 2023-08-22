//
//  Notify.swift
//  SwifterKnife
//
//  Created by 李阳 on 2023/8/4.
//

import Foundation



public enum Notify {
    private final class Wrapper {
        
        private var deinitObserveKey: UInt8 = 0
        private let closure: (Notification) -> Void
        
        init(closure: @escaping (Notification) -> Void) {
            self.closure = closure
        }
        
        func attach(to object: AnyObject) {
            objc_setAssociatedObject(
                object,
                &deinitObserveKey,
                self,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
        
        @objc func didReceiveNotification(_ sender: Notification) {
            closure(sender)
        }
        deinit {
            Console.logFunc(whose: self)
            NotificationCenter.default.removeObserver(self)
        }
    }
     
    
    public static func post(name: Notification.Name, userInfo: [AnyHashable: Any]? = nil) {
        NotificationCenter.default.post(name: name, object: nil, userInfo: userInfo)
    }
    
    public static func addObserver(_ observer: Any, selector aSelector: Selector, name aName: Notification.Name) {
        NotificationCenter.default.addObserver(observer, selector: aSelector, name: aName, object: nil)
    }
    
    public static func addObserver<T: AnyObject>(_ observer: T, name aName: Notification.Name, closure: @escaping (T, Notification) -> Void) {
        let wrap = Wrapper { [weak observer] sender in
            guard let object = observer else { return }
            closure(object, sender)
        }
        wrap.attach(to: observer)
        NotificationCenter.default.addObserver(wrap, selector: #selector(Wrapper.didReceiveNotification(_:)), name: aName, object: nil)
    }
     
}



