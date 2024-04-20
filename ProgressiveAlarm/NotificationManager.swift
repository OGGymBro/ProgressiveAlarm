//
//  NotificationManager.swift
//  ProgressiveAlarm
//
//  Created by Joaquim Menezes on 21/04/24.
//

import Foundation
import UserNotifications

class NotificationManager {
    
    static let instance = NotificationManager()
    
    func requestAuthorization(){
        
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        UNUserNotificationCenter
            .current()
            .requestAuthorization(options: options) { (success, error) in
                if let error = error {
                    print("ERROR : \(error.localizedDescription)")
                }
                else {
                    print("SUCCESS")
                }
        }
    }
    
    
    
}
