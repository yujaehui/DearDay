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
    
    func calculateDDayString(from date: Date, startFromDayOne: Bool, calendar: Calendar) -> String {
        let components = calendar.dateComponents([.day], from: date, to: Date())
        
        if let dayDifference = components.day {
            let ddayValue = startFromDayOne ? (dayDifference + 1) : (dayDifference - 1)
            if ddayValue > 0 {
                return "+\(ddayValue)"
            } else if ddayValue == 0 {
                return "D-DAY"
            } else {
                return "\(ddayValue)"
            }
        }
        return "N/A"
    }
}
