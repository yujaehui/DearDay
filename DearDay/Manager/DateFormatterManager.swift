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
    
    func convertToSolar(from lunarDate: Date) -> Date {
        // API 연결 예정
        return lunarDate
    }
    
    func formatDate(_ date: Date, isLunar: Bool) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd.E"
        
        let formattedDate = isLunar ? convertToSolar(from: date) : date
        return dateFormatter.string(from: formattedDate)
    }
    
    func calculateDDay(from date: Date, isLunar: Bool, startFromDayOne: Bool, repeatType: RepeatType) -> String {
        let calendar = Calendar.current
        var adjustedDate = date
        
        if isLunar {
            adjustedDate = convertToSolar(from: date)
        }

        if adjustedDate < Date() {
            switch repeatType {
            case .month:
                while adjustedDate < Date() {
                    if let newDate = calendar.date(byAdding: .month, value: 1, to: adjustedDate) {
                        adjustedDate = newDate
                    }
                }
            case .year:
                while adjustedDate < Date() {
                    if let newDate = calendar.date(byAdding: .year, value: 1, to: adjustedDate) {
                        adjustedDate = newDate
                    }
                }
            default:
                break
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
