//
//  DateFormatterManager.swift
//  DearDay
//
//  Created by Jaehui Yu on 10/15/24.
//

import Foundation

final class DateFormatterManager {
    static let shared = DateFormatterManager()
    private init() {}
    
    func formatDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd.E"
        return dateFormatter.string(from: date)
    }
    
    func calculateDDayString(from date: Date, type: DDayType, startFromDayOne: Bool, calendar: Calendar) -> String {
        let components = calendar.dateComponents([.day], from: calendar.startOfDay(for: date), to: calendar.startOfDay(for: Date()))
        
        switch type {
        case .dDay:
            if let dayDifference = components.day {
                if dayDifference == 0 {
                    return "D-DAY"
                } else if dayDifference > 0 {
                    return "+\(dayDifference)"
                } else {
                    return "\(dayDifference)"
                }
            }
        case .numberOfDays:
            if let dayDifference = components.day {
                let dDayValue = dayDifference + 1
                if dDayValue > 0 {
                    return "+\(dDayValue)"
                } else {
                    return "\(dDayValue - 1)"
                }
            }
        }
        
        return "N/A"
    }
}
