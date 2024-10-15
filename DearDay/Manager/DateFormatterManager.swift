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
    
    // Function to format the date
    func formatDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd.E"
        return dateFormatter.string(from: date)
    }
    
    // Unified function to calculate D-day with Day 0 or Day 1 option
    func calculateDDay(from date: Date, startFromDayOne: Bool) -> String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: date, to: Date())
        
        if let dayDifference = components.day {
            let ddayValue = startFromDayOne ? (dayDifference + 1) : dayDifference
            return ddayValue >= 0 ? "+\(ddayValue)" : "\(ddayValue - (startFromDayOne ? 2 : 1))"
        }
        return "N/A"
    }
}
