//
//  AnniversaryView.swift
//  DearDay
//
//  Created by Jaehui Yu on 10/15/24.
//

import SwiftUI

struct AnniversaryView: View {
    var dday: DDay
    var maxAnniversaries: Int = 30000
    
    var anniversaryIntervals: [Int] {
        var intervals = [1, 10, 50]
        intervals.append(contentsOf: stride(from: 100, through: maxAnniversaries, by: 100))
        return intervals
    }
    
    var anniversaries: [(days: Int, date: Date)] {
        var dates: [(days: Int, date: Date)] = [(daysUntilEvent(), Date())]
        let calendar = Calendar.current
        for days in anniversaryIntervals {
            let offset = dday.startFromDayOne ? days - 1 : days
            if let anniversary = calendar.date(byAdding: .day, value: offset, to: dday.date) {
                dates.append((days, anniversary))
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
                } else {
                    Text("\(anniversary.days)Days")
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
        return calendar.dateComponents([.day], from: Date(), to: dday.date).day ?? 0
    }
}

#Preview {
    AnniversaryView(dday: DDay(type: .numberOfDays, title: "COMET", date: Calendar.current.date(from: DateComponents(year: 2024, month: 9, day: 22))!, startFromDayOne: true))
}
