//
//  DDayCardView.swift
//  DearDay
//
//  Created by Jaehui Yu on 10/14/24.
//

import SwiftUI
import RealmSwift

struct DDayCardView: View {
    var dDayItem: DDayItem
    var dDayText: String

    var body: some View {
        HStack(spacing: 20) {
            Text(dDayItem.title)
                .foregroundColor(.gray)
                .font(.callout)
                .lineLimit(1)
            
            Spacer()
            VStack(alignment: .trailing) {
                Text(dDayText)
                    .foregroundColor(.gray)
                    .font(.title3)
                    .fontWeight(.bold)
                Text("\(DateFormatterManager.shared.formatDate(dDayItem.date))\(dDayItem.isLunarDate ? " (음력)" : "")")
                    .foregroundColor(.gray.opacity(0.8))
                    .font(.caption)
            }
        }
        .padding(8)
        .onAppear {
            print("DDayCardView appeared: \(dDayItem.title)")
        }
        .onDisappear {
            print("DDayCardView disappeared: \(dDayItem.title)")
        }
    }
}
