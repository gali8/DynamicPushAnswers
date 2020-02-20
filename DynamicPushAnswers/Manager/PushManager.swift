//
//  PushManager.swift
//  gap
//
//  Created by Daniele on 06/08/2019.
//  Copyright © 2019 nexor. All rights reserved.
//

import UIKit
import SwiftyJSON
import UserNotifications

class PushManager: Any {
    
    static let kPushNotificationDeviceToken = "kPushNotificationDeviceToken"
    static let kLastPushNotification = "kLastPushNotification"
    
    class var shared : PushManager {
        struct Static {
            static let instance : PushManager = PushManager()
        }
        return Static.instance
    }
    
    var openPush: ((Any?)->())?

    var token: String? {
        get {
            guard let value = UserDefaults.standard.object(forKey: PushManager.kPushNotificationDeviceToken) as? String else {
                return nil
            }
            return value
        }
        set {
            guard let value = newValue else {
                UserDefaults.standard.removeObject(forKey: PushManager.kPushNotificationDeviceToken)
                UserDefaults.standard.synchronize()
                return
            }
            
            UserDefaults.standard.set(value, forKey: PushManager.kPushNotificationDeviceToken)
            UserDefaults.standard.synchronize()
        }
    }
    
    init() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(applicationDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    @objc func applicationDidBecomeActive() {
        self.tryOpenPush()
    }
    
    func registerForPush() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (grant, error) in
            if let e = error {
                print(e.localizedDescription)
            }
        }
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    func token(tokenData: Data?) {
        guard let tokenData = tokenData else {
            debugPrint("No device token available for push notifications")
            self.token = nil
            return
        }
        
        let tokenMap = tokenData.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        self.token = tokenMap.joined()
        debugPrint("Push Token: \(String(describing: self.token))")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension PushManager {
    
    func checkForNotification(_ launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        //User tapped notification when app was close
        if let notificationOption = launchOptions?[.remoteNotification] {
            if let notification = notificationOption as? [String: AnyObject] {
                PushManager.shared.addPush(dict: notification)
            }
        }
    }
    
    func addPush(dict: [String: AnyObject]) {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: []) else {
            return
        }
        
        UserDefaults.standard.set(jsonData, forKey: PushManager.kLastPushNotification)
        UserDefaults.standard.synchronize()
        self.tryOpenPush()
    }
    
    internal func tryOpenPush() {
        guard let lastPushData = UserDefaults.standard.object(forKey: PushManager.kLastPushNotification) as? Data, let lastPush = try? JSONSerialization.jsonObject(with: lastPushData, options: []) else {
                return
        }
        self.openPush?(lastPush)
    }
    
    func removePush() {
        UserDefaults.standard.removeObject(forKey: PushManager.kLastPushNotification)
        UserDefaults.standard.synchronize()
    }
}
