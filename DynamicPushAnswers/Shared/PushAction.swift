//
//  Push.swift
//  Nexor Technology srl
//
//  Created by Daniele on 10/02/2020.
//  Copyright © 2019 nexor. All rights reserved.
//

import UIKit

struct Push {
    static let kPushLastActKey = "kPushLastActKey"
    
    static func addLastAction(value: Any) {
        UserDefaults.standard.set(value, forKey: Push.kPushLastActKey)
        UserDefaults.standard.synchronize()
    }
    
    static func readLastAction<T>(removeToo: Bool) -> T? {
        let value = UserDefaults.standard.object(forKey: Push.kPushLastActKey) as? T
        
        if removeToo {
            self.deleteLastAction()
        }
        return value
    }
    
    static func deleteLastAction() {
        UserDefaults.standard.removeObject(forKey: Push.kPushLastActKey)
        UserDefaults.standard.synchronize()
    }
}
