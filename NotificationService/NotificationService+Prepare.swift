//
//  NotificationService.swift
//  Nexor Technology srl
//
//  Created by Daniele on 10/02/2020.
//  Copyright © 2019 nexor. All rights reserved.
//

import UIKit

extension NotificationService {
    func prepareNotification(request: UNNotificationRequest) -> UNMutableNotificationContent? {
        // Register the notification type.
        //let notificationCenter = UNUserNotificationCenter.current()
        //notificationCenter.setNotificationCategories([])
        
        guard let bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent) else {
            return nil
        }

        return bestAttemptContent //do not show default notification
   }
}
