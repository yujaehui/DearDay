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
    
    // Function to calculate D-day, treating the start date as Day 0
    func calculateDDayAsDayZero(from date: Date) -> String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: date, to: Date())
        if let dayDifference = components.day {
            return dayDifference >= 0 ? "+\(dayDifference)" : "\(dayDifference - 1)"
        }
        return "N/A"
    }
    
    // Function to calculate D-day, treating the start date as Day 1
    func calculateDDayAsDayOne(from date: Date) -> String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: date, to: Date())
        if let dayDifference = components.day {
            let ddayValue = dayDifference + 1  // Treat start date as Day 1
            return ddayValue >= 0 ? "+\(ddayValue)" : "\(ddayValue - 2)"
        }
        return "N/A"
    }
}
