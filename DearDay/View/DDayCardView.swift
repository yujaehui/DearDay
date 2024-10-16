//
//  DDayCardView.swift
//  DearDay
//
//  Created by Jaehui Yu on 10/14/24.
//

import SwiftUI

struct DDayCardView: View {
    var dday: DDay
    
    var body: some View {
        HStack(spacing: 20) {
            Text(dday.title)
                .foregroundColor(.gray)
                .font(.callout)
                .lineLimit(1)
            
            Spacer()
            VStack(alignment: .trailing) {
                Text(DateFormatterManager.shared.calculateDDay(from: dday.date, startFromDayOne: dday.startFromDayOne, repeatType: dday.repeatType))
                    .foregroundColor(.gray)
                    .font(.title3)
                    .fontWeight(.bold)
                Text(DateFormatterManager.shared.formatDate(dday.date))
                    .foregroundColor(.gray.opacity(0.8))
                    .font(.caption)
            }
            
        }
        .padding(8)
    }
}

#Preview {
    DDayCardView(dday: DDay(type: .numberOfDays, title: "COMET", date: Calendar.current.date(from: DateComponents(year: 2024, month: 9, day: 22))!, startFromDayOne: true))
}

