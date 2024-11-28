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
                .asRowTitle()
            Spacer()
            VStack(alignment: .trailing) {
                Text(dDayText)
                    .asRowDDayText()
                Text("\(DateFormatterManager.shared.formatDate(dDayItem.date))\(dDayItem.isLunarDate ? " (음력)" : "")")
                    .asRowDate()
            }
        }
        .padding(8)
    }
}
