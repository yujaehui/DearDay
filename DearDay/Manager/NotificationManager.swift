//
//  NotificationManager.swift
//  DearDay
//
//  Created by Jaehui Yu on 11/12/24.
//

import Foundation
import UserNotifications

final class NotificationManager {
    static let shared = NotificationManager(apiService: APIService())
    private let apiService: APIServiceProtocol
    
    init(apiService: APIServiceProtocol) {
        self.apiService = apiService
    }
    
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
    
    func scheduleNotification(for dDay: DDay, updatedDDay: DDay) {
        let content = makeNotificationContent(
            title: "\(updatedDDay.title), D-DAY입니다.",
            body: "잊지 말고 의미 있는 하루 보내세요!"
        )
        
        let notificationDate = dDay.convertedSolarDateFromLunar ?? dDay.date
        
        guard dDay.type == .dDay else { return }
        
        if dDay.isLunarDate == false {
            switch dDay.repeatType {
            case .none:
                // D-Day(양력): 반복이 없는 경우
                scheduleNoneRepeatingDdayNotification(for: dDay, date: notificationDate, content: content)
            case .month:
                // D-Day(양력): 매월 반복의 경우
                scheduleMonthlyRepeatingDdayNotification(for: dDay, date: notificationDate, content: content)
            case .year:
                // D-Day(양력): 매년 반복의 경우
                scheduleYearlyRepeatingDdayNotification(for: dDay, date: notificationDate, content: content)
            }
        } else if dDay.isLunarDate == true && dDay.isRepeatOn == false {
            // D-Day(음력): 반복이 없는 경우
            scheduleNoneRepeatingLunarDdayNotification(for: dDay, date: notificationDate, content: content)
        }
        
        logPendingNotifications()
    }
    
    // D-Day(음력): 매년 반복의 경우 O
    func scheduleYearlyRepeatingLunarDdayNotification(for dDays: [DDayItem]) async {
        let notificationCenter = UNUserNotificationCenter.current()
        let calendar = Calendar.current
        
        for dDay in dDays {
            guard dDay.type == .dDay,
                  dDay.isLunarDate,
                  dDay.repeatType == .year
            else { continue }
            
            removeSpecificNotifications(with: ["\(dDay.pk)"])
            
            let content = makeNotificationContent(
                title: "\(dDay.title), D-DAY입니다.",
                body: "잊지 말고 의미 있는 하루 보내세요!"
            )
            
            if let convertedDate = await fetchClosestSolarDate(from: dDay.date, repeatType: dDay.repeatType) {
                var triggerDate = calendar.dateComponents([.month, .day], from: convertedDate)
                triggerDate.hour = 0
                triggerDate.minute = 0
                
                let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
                
                let request = UNNotificationRequest(identifier: "\(dDay.pk)", content: content, trigger: trigger)
                
                do {
                    try await notificationCenter.add(request)
                    print("(Lunar) D-Day 알림 등록 성공: \(dDay.title)")
                } catch {
                    print("(Lunar) D-Day 알림 등록 실패: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // 날짜 수: 100일 단위 기념일 처리
    func scheduleHundredDayNotifications(for dDays: [DDayItem]) {
        let notificationCenter = UNUserNotificationCenter.current()
        let calendar = Calendar.current
        let now = Date()
        
        for dDay in dDays {
            guard dDay.type == .numberOfDays else { continue }
            
            removeSpecificNotifications(with: ["\(dDay.pk)-100"])
            
            let notificationDate = dDay.convertedSolarDateFromLunar ?? dDay.date
            let daysSinceStart = calendar.dateComponents([.day], from: notificationDate, to: now).day ?? 0
            let nextMultipleOf100 = ((daysSinceStart / 100) + 1) * 100 - 1
            
            let content = makeNotificationContent(
                title: "\(dDay.title), \(nextMultipleOf100 + 1)일입니다!",
                body: "오늘을 기념하며, 소중한 하루를 보내세요!"
            )
            
            if let nextDate = calendar.date(byAdding: .day, value: nextMultipleOf100, to: notificationDate) {
                
                var triggerDate = calendar.dateComponents([.year, .month, .day], from: nextDate)
                triggerDate.hour = 0
                triggerDate.minute = 0
                
                let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
                
                let request = UNNotificationRequest(identifier: "\(dDay.pk)-100", content: content, trigger: trigger)
                
                notificationCenter.add(request) { error in
                    if let error = error {
                        print("100일 알림 등록 실패: \(error.localizedDescription)")
                    }
                }
            }
        }
        
        logPendingNotifications()
    }
    
    // 날짜 수: 1년 단위 기념일 처리
    func scheduleYearlyNotifications(for dDays: [DDayItem]) {
        let notificationCenter = UNUserNotificationCenter.current()
        let calendar = Calendar.current
        let now = Date()
        
        for dDay in dDays {
            guard dDay.type == .numberOfDays else { continue }
            
            removeSpecificNotifications(with: ["\(dDay.pk)-year"])
            
            let notificationDate = dDay.convertedSolarDateFromLunar ?? dDay.date
            let yearsSinceStart = calendar.dateComponents([.year], from: notificationDate, to: now).year ?? 0
            
            let content = makeNotificationContent(
                title: "\(dDay.title), \(yearsSinceStart)주년입니다!",
                body: "오늘을 기념하며, 소중한 하루를 보내세요!"
            )
            
            if let nextDate = calendar.date(byAdding: .year, value: yearsSinceStart, to: notificationDate) {
                
                var triggerDate = calendar.dateComponents([.month, .day], from: nextDate)
                triggerDate.hour = 18
                triggerDate.minute = 43
                
                let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
                
                let request = UNNotificationRequest(identifier: "\(dDay.pk)-year", content: content, trigger: trigger)
                
                notificationCenter.add(request) { error in
                    if let error = error {
                        print("1년 단위 알림 등록 실패: \(error.localizedDescription)")
                    }
                }
            }
        }
        
        logPendingNotifications()
    }
    
    func removeAllNotificationsForDDay(for dDay: DDay) {
        let identifiers = ["\(dDay.pk)", "\(dDay.pk)-year", "\(dDay.pk)-100"]
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: identifiers)
    }
    
    // MARK: - Private Helpers
    
    private func logPendingNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            print("현재 등록된 알림 개수: \(requests.count)")
            requests.forEach { print("알림 ID: \($0.identifier)") }
        }
    }
    
    private func makeNotificationContent(title: String, body: String) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        return content
    }
    
    // D-Day(양력): 반복이 없는 경우 O
    private func scheduleNoneRepeatingDdayNotification(for dDay: DDay, date: Date, content: UNMutableNotificationContent) {
        var triggerDate = Calendar.current.dateComponents([.year, .month, .day], from: date)
        triggerDate.hour = 0
        triggerDate.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        
        let request = UNNotificationRequest(identifier: "\(dDay.pk)", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("D-Day 알림 등록 실패: \(error.localizedDescription)")
            }
        }
    }
    
    // D-Day(양력): 매월 반복의 경우 O
    private func scheduleMonthlyRepeatingDdayNotification(for dDay: DDay, date: Date, content: UNMutableNotificationContent) {
        var triggerDate = Calendar.current.dateComponents([.day], from: date)
        triggerDate.hour = 0
        triggerDate.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: true)
        
        let request = UNNotificationRequest(identifier: "\(dDay.pk)", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("D-Day 알림 등록 실패: \(error.localizedDescription)")
            }
        }
    }
    
    // D-Day(양력): 매년 반복의 경우 O
    private func scheduleYearlyRepeatingDdayNotification(for dDay: DDay, date: Date, content: UNMutableNotificationContent) {
        var triggerDate = Calendar.current.dateComponents([.month, .day], from: date)
        triggerDate.hour = 0
        triggerDate.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: true)
        
        let request = UNNotificationRequest(identifier: "\(dDay.pk)", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("D-Day 알림 등록 실패: \(error.localizedDescription)")
            }
        }
    }
    
    // D-Day(음력): 반복이 없는 경우 O
    private func scheduleNoneRepeatingLunarDdayNotification(for dDay: DDay, date: Date, content: UNMutableNotificationContent) {
        var triggerDate = Calendar.current.dateComponents([.year, .month, .day], from: date)
        triggerDate.hour = 0
        triggerDate.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        
        let request = UNNotificationRequest(identifier: "\(dDay.pk)", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("(Lunar) D-Day 알림 등록 실패: \(error.localizedDescription)")
            }
        }
    }
    
    private func removeSpecificNotifications(with identifier: [String]) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifier)
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: identifier)
    }
    
    private func fetchClosestSolarDate(from date: Date, repeatType: RepeatType) async -> Date? {
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        
        switch repeatType {
        case .none:
            return await apiService.fetchSolarDate(year: year, month: month, day: day)
        case .year:
            if let thisYearDate = await apiService.fetchSolarDate(year: currentYear, month: month, day: day),
               calendar.startOfDay(for: thisYearDate) >= calendar.startOfDay(for: Date()) {
                return thisYearDate
            }
            return await apiService.fetchSolarDate(year: currentYear + 1, month: month, day: day)
        case .month:
            return nil
        }
    }
}

