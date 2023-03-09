//
//  AppDelegate.swift
//  SwifterKnife
//
//  Created by liyang on 10/25/2021.
//  Copyright (c) 2021 liyang. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard keyPath == "isHidden" else { return }
        print("")
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        window = UIWindow(frame: UIScreen.main.bounds).then {
//            $0.rootViewController = ViewController()
            $0.rootViewController = UINavigationController(rootViewController: HomeViewController())
            $0.makeKeyAndVisible()
            if let view = UIView.canvasView,
               let first = $0.subviews.first {
                first.addObserver(self, forKeyPath: "isHidden", options: [.old, .new], context: nil)
                first.removeFromSuperview()
                view.addSubview(first)
                $0.addSubview(view)
            }
        }
            
        
//        asyncWhile { i, exit, cost in
//            print("asyncWhile cond", i, exit)
//            if i > 3 {
//                exit = true
//                print(cost())
//            }
//            return self.window!.rootViewController!.view.frame.height > 0
//        } execute: { i, cost in
//            print("asyncWhile result", i, cost(), self.window!.rootViewController!.view.frame)
//        }
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

