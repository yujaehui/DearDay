//
//  DDayCardView.swift
//  DearDay
//
//  Created by Jaehui Yu on 10/14/24.
//

import SwiftUI

struct DDayCardView: View {
    var title: String
    var date: Date
    var startFromDayOne: Bool
    
    var body: some View {
        HStack(spacing: 20) {
            Text(title)
                .foregroundColor(.gray)
                .font(.callout)
                .lineLimit(1)
            
            Spacer()
            VStack(alignment: .trailing) {
                Text(DateFormatterManager.shared.calculateDDay(from: date, startFromDayOne: startFromDayOne))
                    .foregroundColor(.gray)
                    .font(.title3)
                    .fontWeight(.bold)
                Text(DateFormatterManager.shared.formatDate(date))
                    .foregroundColor(.gray.opacity(0.8))
                    .font(.caption)
            }
            
        }
        .padding(8)
    }
}

#Preview {
    DDayCardView(title: "COMET", date: Calendar.current.date(from: DateComponents(year: 2024, month: 9, day: 22))!, startFromDayOne: true)
}

