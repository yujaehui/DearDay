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
    
    func calculateDDay(from date: Date, startFromDayOne: Bool, repeatType: RepeatType) -> String {
        let calendar = Calendar.current
        var adjustedDate = date

        if date < Date() {
            switch repeatType {
            case .month:
                if let newDate = calendar.date(byAdding: .month, value: 1, to: date) {
                    adjustedDate = newDate
                }
            case .year:
                if let newDate = calendar.date(byAdding: .year, value: 1, to: date) {
                    adjustedDate = newDate
                }
            default: break
            }
        }

        let components = calendar.dateComponents([.day], from: adjustedDate, to: Date())

        if let dayDifference = components.day {
            let ddayValue = startFromDayOne ? (dayDifference + 1) : dayDifference
            return ddayValue >= 0 ? "+\(ddayValue)" : "\(ddayValue - (startFromDayOne ? 2 : 1))"
        }
        
        return "N/A"
    }

}
