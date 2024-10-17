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
    
    func calculateDDay(from date: Date, isLunar: Bool, startFromDayOne: Bool, repeatType: RepeatType) async -> String {
        let calendar = Calendar.current
        var adjustedDate = date
        
        if isLunar {
            if let closestLunarDate = await fetchClosestLunarDate(from: date) {
                adjustedDate = closestLunarDate
            } else {
                return "N/A"
            }
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
    
    private func fetchClosestLunarDate(from date: Date) async -> Date? {
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        
        do {
            let solarDateItems = try await APIService.shared.fetchSolarDateItems(lunYear: currentYear, lunMonth: month, lunDay: day)
            for solarItem in solarDateItems {
                if let convertedDate = calendar.date(from: DateComponents(year: Int(solarItem.solYear), month: Int(solarItem.solMonth), day: Int(solarItem.solDay)! + 1)) {
                    print(convertedDate, Date())
                    if convertedDate >= Date() {
                        return convertedDate
                    }
                }
            }
            
            let solarDateItemsNextYear = try await APIService.shared.fetchSolarDateItems(lunYear: currentYear + 1, lunMonth: month, lunDay: day)
            for solarItemNextYear in solarDateItemsNextYear {
                if let nextYearConvertedDate = calendar.date(from: DateComponents(year: Int(solarItemNextYear.solYear), month: Int(solarItemNextYear.solMonth), day: Int(solarItemNextYear.solDay)! + 1)) {
                    return nextYearConvertedDate
                }
            }
            
        } catch {
            print("Error fetching closest lunar date: \(error)")
        }
        
        return nil
    }
}
