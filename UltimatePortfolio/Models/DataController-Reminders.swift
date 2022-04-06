//
//  DataController-Reminders.swift
//  UltimatePortfolio
//
//  Created by Christopher Eadie on 30/03/2022.
//

import Foundation
import UserNotifications

extension DataController {
    var uNCenter: UNUserNotificationCenter { return .current() }
    
    func addReminders(for project: Project, completion: @escaping (Bool) -> Void) {
        uNCenter.getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .notDetermined:
                self.requestNotificationsAuthorization { success in
                    if success {
                        self.placeReminders(for: project, completion: completion)
                    } else {
                        DispatchQueue.main.async {
                            completion(false)
                        }
                    }
                }
            case .authorized:
                self.placeReminders(for: project, completion: completion)
            case .denied, .ephemeral, .provisional:
                DispatchQueue.main.async {
                    completion(false)
                }
            @unknown default:
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }
    }
    
    func removeReminders(for project: Project) {
        let id = project.objectID.uriRepresentation().absoluteString
        uNCenter.removePendingNotificationRequests(withIdentifiers: [id])
    }
    
    private func requestNotificationsAuthorization(completion: @escaping (Bool) -> Void) {
        uNCenter.requestAuthorization(options: [.alert, .sound]) { granted, _ in
            completion(granted)
        }
    }
    
    private func placeReminders(for project: Project, completion: @escaping (Bool) -> Void) {
        let id = project.objectID.uriRepresentation().absoluteString
        
        let nContent = UNMutableNotificationContent()
        nContent.title = project.projectTitle
        nContent.sound = .default
        if let projectDetail = project.detail {
            nContent.subtitle = projectDetail
        }
        
        let dateComponents = Calendar.current.dateComponents([.hour, .minute], from: project.reminderTime.orToday)
        let nTrigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let nRequest = UNNotificationRequest(identifier: id, content: nContent, trigger: nTrigger)
        uNCenter.add(nRequest) { error in
            DispatchQueue.main.async {
                let success = error == nil
                completion(success)
            }
        }
    }
}
