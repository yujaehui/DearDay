//
//  AnniversaryView.swift
//  DearDay
//
//  Created by Jaehui Yu on 10/15/24.
//

import SwiftUI

struct AnniversaryView: View {
    var date: Date
    var startFromDayOne: Bool
    var maxAnniversaries: Int = 100
    
    var anniversaryIntervals: [Int] {
        var intervals = [10, 50]
        for i in 1...maxAnniversaries {
            intervals.append(i * 100)
        }
        return intervals
    }

    var anniversaries: [(days: Int, date: Date)] {
        var dates: [(days: Int, date: Date)] = []
        let calendar = Calendar.current
        for days in anniversaryIntervals {
            let offset = startFromDayOne ? days - 1 : days
            if let anniversary = calendar.date(byAdding: .day, value: offset, to: date) {
                dates.append((days, anniversary))
            }
        }
        return dates
    }

    var body: some View {
        List(anniversaries, id: \.date) { anniversary in
            VStack(alignment: .leading) {
                Text("\(anniversary.days)Days")
                    .foregroundColor(isPast(anniversary.date) ? .gray : .primary)
                    .font(.headline)
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
}

#Preview {
    AnniversaryView(date: Calendar.current.date(from: DateComponents(year: 2024, month: 9, day: 22))!, startFromDayOne: true)
}
