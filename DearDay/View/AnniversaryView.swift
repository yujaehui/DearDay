//
//  AnniversaryView.swift
//  DearDay
//
//  Created by Jaehui Yu on 10/15/24.
//

import SwiftUI
import RealmSwift

struct AnniversaryView: View {
    var dDayItem: DDayItem
    
    var anniversaryIntervals: [Int] {
        var intervals = [1, 10, 50]
        intervals.append(contentsOf: stride(from: 100, through: 36400, by: 100))
        return intervals
    }
    
    var anniversaryYearIntervals: [Int] {
        var yearIntervals: [Int] = []
        let calendar = Calendar.current
        
        for year in 1...100 {
            let dateForYear = calendar.date(byAdding: .year, value: year, to: dDayItem.convertedSolarDateFromLunar ?? dDayItem.date)!
            
            if let daysDifference = calendar.dateComponents([.day], from: dDayItem.convertedSolarDateFromLunar ?? dDayItem.date, to: dateForYear).day {
                yearIntervals.append(daysDifference)
            }
        }
        
        return yearIntervals
    }
    
    var anniversaries: [(days: Int, date: Date, isYear: Bool)] {
        var dates: [(days: Int, date: Date, isYear: Bool)] = []
        let calendar = Calendar.current
        
        // 일 단위 기념일 목록 추가
        for days in anniversaryIntervals {
            let offset = dDayItem.startFromDayOne ? days - 1 : days
            if let anniversary = calendar.date(byAdding: .day, value: offset, to: dDayItem.convertedSolarDateFromLunar ?? dDayItem.date) {
                dates.append((days, calendar.startOfDay(for: anniversary), false))
            }
        }
        
        // 연 단위 기념일 목록 추가
        for yearDays in anniversaryYearIntervals {
            let offset = yearDays // 연 단위를 계산할 때는 시작일을 1일로 생각하는 것을 고려하지 않음
            if let anniversary = calendar.date(byAdding: .day, value: offset, to: dDayItem.convertedSolarDateFromLunar ?? dDayItem.date) {
                dates.append((yearDays, calendar.startOfDay(for: anniversary), true))
            }
        }
        
        // Today 계산을 위한 오늘 날짜 추가 (오늘 = 0)
        dates.append((0, calendar.startOfDay(for: Date()), false))
        
        let uniqueDates = Dictionary(grouping: dates, by: { $0.date })
            .compactMapValues { $0.first }
        
        return Array(uniqueDates.values).sorted { $0.date < $1.date }
    }
    
    var body: some View {
        List(anniversaries, id: \.days) { anniversary in
            VStack(alignment: .leading) {
                HStack {
                    if anniversary.days == 0 {
                        Text("Today")
                            .foregroundColor(.red)
                            .font(.headline)
                    } else {
                        if anniversary.isYear,
                           let yearDifference = Calendar.current.dateComponents([.year], from: dDayItem.convertedSolarDateFromLunar ?? dDayItem.date, to: anniversary.date).year {
                            Text("\(yearDifference + 1) Years")
                                .foregroundStyle(isPast(anniversary.date) ? .secondary : .primary)
                                .font(.headline)
                        } else {
                            Text("\(anniversary.days) Days")
                                .foregroundStyle(isPast(anniversary.date) ? .secondary : .primary)
                                .font(.headline)
                        }
                        
                        if isToday(anniversary.date) {
                            Image(systemName: "arrowtriangle.left.fill")
                                .foregroundColor(.red)
                                .font(.footnote)
                        }
                    }
                }
                
                Text(DateFormatterManager.shared.formatDate(anniversary.date))
                    .foregroundStyle(.secondary)
                    .font(.subheadline)
            }
            .padding(.vertical, 8)
        }
        .listStyle(.plain)
    }
    
    private func isPast(_ date: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.startOfDay(for: date) < calendar.startOfDay(for: Date())
    }
    
    private func isToday(_ date: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDateInToday(date)
    }
}

