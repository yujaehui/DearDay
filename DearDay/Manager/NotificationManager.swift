//
//  NotificationManager.swift
//  DearDay
//
//  Created by Jaehui Yu on 11/12/24.
//

import Foundation
import UserNotifications

final class NotificationManager {
    static let shared = NotificationManager()
    private init() {}
    
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("알림 권한 요청 에러: \(error.localizedDescription)")
                completion(false)
            } else {
                print(granted ? "알림 권한이 승인되었습니다." : "알림 권한이 거부되었습니다.")
                completion(granted)
            }
        }
    }
    
    func scheduleNotification(for dDay: DDay) {
        let notificationDate = dDay.convertedSolarDateFromLunar ?? dDay.date
        let content = makeNotificationContent(for: dDay)
        
        if dDay.type == .dDay {
            scheduleDdayNotification(for: dDay, date: notificationDate, content: content)
        } else if dDay.type == .numberOfDays {
            scheduleRecurringNotifications(for: dDay, startDate: notificationDate, content: content)
        }
        
        logPendingNotifications()
    }
    
    func removeNotification(for dDay: DDay) {
        let identifiers = notificationIdentifiers(for: dDay)
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: identifiers)
    }
    
    // MARK: - Private Helpers
    
    private func makeNotificationContent(for dDay: DDay) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = dDay.title
        content.body = dDay.title
        content.sound = .default
        return content
    }
    
    private func scheduleDdayNotification(for dDay: DDay, date: Date, content: UNMutableNotificationContent) {
        var triggerDate = Calendar.current.dateComponents([.year, .month, .day], from: date)
        triggerDate.hour = 0
        triggerDate.minute = 0
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        let request = UNNotificationRequest(identifier: dDay.pk.stringValue, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("D-Day 알림 등록 실패: \(error.localizedDescription)")
            }
        }
    }
    
    private func scheduleRecurringNotifications(for dDay: DDay, startDate: Date, content: UNMutableNotificationContent) {
        let calendar = Calendar.current
        
        //guard let adjustedStartDate = calendar.date(byAdding: .day, value: -1, to: startDate) else { return }

        //TODO: 100일 간격 알림 로직 구현 필요
        
        if let nextYearDate = calendar.date(byAdding: .year, value: 1, to: startDate) {
            var yearTriggerDate = calendar.dateComponents([.month, .day], from: nextYearDate)
            yearTriggerDate.hour = 0
            yearTriggerDate.minute = 0
            let yearTrigger = UNCalendarNotificationTrigger(dateMatching: yearTriggerDate, repeats: true)
            let yearRequest = UNNotificationRequest(identifier: "\(dDay.pk.stringValue)-year", content: content, trigger: yearTrigger)
            UNUserNotificationCenter.current().add(yearRequest) { error in
                if let error = error {
                    print("1년 알림 등록 실패: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func notificationIdentifiers(for dDay: DDay) -> [String] {
        if dDay.type == .dDay {
            return [dDay.pk.stringValue]
        } else {
            return ["\(dDay.pk.stringValue)-100", "\(dDay.pk.stringValue)-year"]
        }
    }
    
    private func logPendingNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            print("현재 등록된 알림 개수: \(requests.count)")
        }
    }
}
