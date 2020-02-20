//
//  PushManager.swift
//  Nexor Technology srl
//
//  Created by Daniele on 10/02/2020.
//  Copyright © 2019 nexor. All rights reserved.
//

import UIKit
import SwiftyJSON

extension PushManager {
    
    func configure() {
        self.openPush = { object in
            /*
             {
               "aps": {
                 "alert": {
                   "title": "www.nexor.it",
                   "body": "Rispondi a questo interessante sondaggio"
                 },
                 "sound": "default",
                 "mutable-content": 1
               },
               "data": {
                 "question": {
                   "id": 123,
                   "text": "Sono bello, alto e intelligente?",
                   "answers": [
                     {
                       "id": 1,
                       "text": "Si"
                     },
                     {
                       "id": 2,
                       "text": "No"
                     }
                   ]
                 }
               }
             }
             */
            
            let rootVc = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) //add your custom and valid root viewcontrollers, when app is active; //UIApplication.shared.keyWindow?.rootViewController on iOS < 13
            
            if UIApplication.shared.applicationState == .active, let _ = rootVc {
                if let lastPush = object {
                    let json = JSON(lastPush)
                    if let data = json["data"].dictionary, let question = data["question"]?.dictionary {
                        guard let _ = question["id"]?.int else {
                            PushManager.shared.removePush()
                            return
                        }
                        
                        
                        ///Get the last action selected by the user
                        let indexes: [Int] = Push.readLastAction(removeToo: true) ?? []
                        debugPrint("last selected action indexes \(String(describing: indexes.first))")
                        debugPrint("Do something with your selected answer index: \(String(describing: indexes.first))")
                    }
                    
                    PushManager.shared.removePush()
                }
            }
        }
    }
    
    func willPresentAnswer(response: UNNotificationResponse) {
        if let userInfo = response.notification.request.content.userInfo as? [String: AnyObject] {
            
            let json = JSON(userInfo)
            guard let _ = json["data"].dictionary else {
                return
            }
            
            switch response.actionIdentifier {
            case UNNotificationDefaultActionIdentifier:
                break
            default:
                if let answerId = Int(response.actionIdentifier) {
                    Push.addLastAction(value: [answerId])
                }
            }
        }
    }
    
    func onAnswer(response: UNNotificationResponse) {
        if let userInfo = response.notification.request.content.userInfo as? [String: AnyObject] {
            
            let json = JSON(userInfo)
            guard let _ = json["data"].dictionary else {
                return
            }
            
            switch response.actionIdentifier {
            case UNNotificationDefaultActionIdentifier:
                break
            default:
                if let answerId = Int(response.actionIdentifier) {
                    Push.addLastAction(value: [answerId])
                }
            }
        }
    }
    
    func prepareNotification(content: UNNotificationContent, userInfo: [AnyHashable: Any], completionHandler: @escaping (UNNotificationPresentationOptions) -> Void){
        // Register the notification type.
        let notificationCenter = UNUserNotificationCenter.current()
        
        var json = JSON(userInfo)
        
        guard let data = json["data"].dictionary else {
            completionHandler([ .alert, .sound, .badge ])
            return
        }
        
        let alreadyRequested = data["PushManagerPrepared"]?.bool ?? false
        
        guard alreadyRequested == false else {
            completionHandler([ .alert, .sound, .badge ])
            return
        }
        
        guard let question = data["question"]?.dictionary, let questionId = question["id"]?.int, let answers = question["answers"]?.array, !answers.isEmpty else {
            completionHandler([ .alert, .sound, .badge ])
            return
        }
        
        let acts = answers.map { (answer) -> UNNotificationAction in
            let action = UNNotificationAction(identifier: String(answer["id"].int!), title: answer["text"].string!, options: [.foreground])
            return action
        }
        
        let category = UNNotificationCategory(identifier: "DynamicPushAnswersInQuestion" + String(questionId), actions: acts, intentIdentifiers: [], options: [])
        
        // Register the notification type.
        notificationCenter.setNotificationCategories([category])
        
        let newContent = UNMutableNotificationContent()
        newContent.title = content.title
        newContent.body = content.body
        newContent.subtitle = content.subtitle
        newContent.sound = content.sound
        
        json["data"]["PushManagerPrepared"] = true
        newContent.userInfo = json.dictionaryObject!
        newContent.categoryIdentifier = category.identifier
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
        let newRequest = UNNotificationRequest(identifier: category.identifier, content: newContent, trigger: trigger)
        
        //add new notification with category
        notificationCenter.add(newRequest) { (error) in
            if let error = error {
                print("Error \(error.localizedDescription)")
            }
        }
        
        completionHandler([])
    }
}
