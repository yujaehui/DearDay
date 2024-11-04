//
//  AnniversaryView.swift
//  DearDay
//
//  Created by Jaehui Yu on 10/15/24.
//

import SwiftUI
import RealmSwift

struct AnniversaryView: View {
    @ObservedRealmObject var dDay: DDay
    
    var maxAnniversaries: Int = 36400
    var maxYears: Int = 100
    
    var anniversaryIntervals: [Int] {
        var intervals = [1, 10, 50]
        intervals.append(contentsOf: stride(from: 100, through: maxAnniversaries, by: 100))
        return intervals
    }
    
    var anniversaryYears: [Int] {
        var yearIntervals: [Int] = []
        let calendar = Calendar.current
        
        for year in 1...maxYears {
            let dateForYear = calendar.date(byAdding: .year, value: year, to: dDay.date)!
            
            if let daysDifference = calendar.dateComponents([.day], from: dDay.date, to: dateForYear).day {
                yearIntervals.append(daysDifference)
            }
        }
        
        return yearIntervals
    }
    
    var anniversaries: [(days: Int, date: Date, isYear: Bool)] {
        var dates: [(days: Int, date: Date, isYear: Bool)] = []
        let calendar = Calendar.current
        
        for days in anniversaryIntervals {
            let offset = dDay.startFromDayOne ? days - 1 : days
            if let anniversary = calendar.date(byAdding: .day, value: offset, to: dDay.date) {
                dates.append((days, calendar.startOfDay(for: anniversary), false))
            }
        }
        
        for yearDays in anniversaryYears {
            let offset = dDay.startFromDayOne ? yearDays - 1 : yearDays
            if let anniversary = calendar.date(byAdding: .day, value: offset, to: dDay.date) {
                dates.append((yearDays, calendar.startOfDay(for: anniversary), true))
            }
        }
        
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
                           let yearDifference = Calendar.current.dateComponents([.year], from: dDay.date, to: anniversary.date).year {
                            Text("\(yearDifference + 1) Years")
                                .foregroundColor(isPast(anniversary.date) ? .gray : .primary)
                                .font(.headline)
                        } else {
                            Text("\(anniversary.days) Days")
                                .foregroundColor(isPast(anniversary.date) ? .gray : .primary)
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
                    .foregroundColor(.gray)
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

