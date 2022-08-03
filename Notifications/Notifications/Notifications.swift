//
//  Notifications.swift
//  Notifications
//
//  Created by Alexey Efimov on 28.06.2018.
//  Copyright © 2018 Alexey Efimov. All rights reserved.
//

import UIKit
import UserNotifications

class Notifications: NSObject, UNUserNotificationCenterDelegate {
    
    let notificationCenter = UNUserNotificationCenter.current()
    
    func requestAutorization() {
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge, .providesAppNotificationSettings]) { (granted, error) in
            print("Permission granted: \(granted)")
            
            guard granted else { return }
            self.getNotificationSettings()
        }
    }
    
    func getNotificationSettings() {
        notificationCenter.getNotificationSettings { (settings) in
            print("Notification settings: \(settings)")
            
            guard settings.authorizationStatus == .authorized else { return }
            
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    func scheduleNotification(notifaicationType: String) {
        
        let content = UNMutableNotificationContent()
        let userActions = "User Actions"
        
        content.title = notifaicationType
        content.body = "Summer Time"
        content.sound = .default
        content.badge = 1
        content.categoryIdentifier = userActions
        
        content.threadIdentifier = notifaicationType
        
        content.summaryArgument = notifaicationType
        content.summaryArgumentCount = 10
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let identifire = UUID().uuidString
        let request = UNNotificationRequest(identifier: identifire,
                                            content: content,
                                            trigger: trigger)
        
        notificationCenter.add(request) { (error) in
            if let error = error {
                print("Error \(error.localizedDescription)")
            }
        }
    }
    
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        completionHandler([.alert, .sound])
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void) {
        
        if response.notification.request.identifier == "Local Notification" {
            print("Handling notification with the Local Notification Identifire")
        }
        
        switch response.actionIdentifier {
        case UNNotificationDismissActionIdentifier:
            print("Dismiss Action")
        case UNNotificationDefaultActionIdentifier:
            print("Default")
        case "Snooze":
            print("Snooze")
            scheduleNotification(notifaicationType: "Reminder")
        default:
            print("Unknown action")
        }
        
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, openSettingsFor notification: UNNotification?) {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        appDelegate?.openSettings()
    }
}
