//
//  AnniversaryView.swift
//  DearDay
//
//  Created by Jaehui Yu on 10/15/24.
//

import SwiftUI
import RealmSwift

//TODO: Today와 기념일이 겹치는 경우 처리 필요

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
        return Array(1...maxYears).map { $0 * 365 }
    }
    
    var anniversaries: [(days: Int, date: Date)] {
        var dates: [(days: Int, date: Date)] = [(daysUntilEvent(), Date())]
        let calendar = Calendar.current

        for days in anniversaryIntervals {
            let offset = dDay.startFromDayOne ? days - 1 : days
            if let anniversary = calendar.date(byAdding: .day, value: offset, to: dDay.date) {
                dates.append((days, anniversary))
            }
        }

        for yearDays in anniversaryYears {
            let offset = dDay.startFromDayOne ? yearDays - 1 : yearDays
            if let anniversary = calendar.date(byAdding: .day, value: offset, to: dDay.date) {
                dates.append((yearDays, anniversary))
            }
        }

        return dates.sorted { $0.date < $1.date }
    }
    
    var body: some View {
        List(anniversaries, id: \.date) { anniversary in
            VStack(alignment: .leading) {
                if isToday(anniversary.date) {
                    Text("Today")
                        .foregroundColor(.red)
                        .font(.headline)
                } else if anniversary.days % 365 == 0 {
                    Text("\(anniversary.days / 365) Years")
                        .foregroundColor(isPast(anniversary.date) ? .gray : .primary)
                        .font(.headline)
                } else {
                    Text("\(anniversary.days) Days")
                        .foregroundColor(isPast(anniversary.date) ? .gray : .primary)
                        .font(.headline)
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
        return date < Date()
    }
    
    private func isToday(_ date: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDateInToday(date)
    }
    
    private func daysUntilEvent() -> Int {
        let calendar = Calendar.current
        return calendar.dateComponents([.day], from: Date(), to: dDay.date).day ?? 0
    }
}
