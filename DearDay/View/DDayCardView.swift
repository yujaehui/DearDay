//
//  DDayCardView.swift
//  DearDay
//
//  Created by Jaehui Yu on 10/14/24.
//

import SwiftUI
import RealmSwift

struct DDayCardView: View {
    @ObservedRealmObject var dDay: DDay

    @StateObject private var viewModel = DDayViewModel()
    
    var body: some View {
        HStack(spacing: 20) {
            Text(dDay.title)
                .foregroundColor(.gray)
                .font(.callout)
                .lineLimit(1)
            
            Spacer()
            VStack(alignment: .trailing) {
                Text(viewModel.output.dDayText)
                    .foregroundColor(.gray)
                    .font(.title3)
                    .fontWeight(.bold)
                Text("\(DateFormatterManager.shared.formatDate(dDay.date))\(dDay.isLunarDate ? " (음력)" : "")")
                    .foregroundColor(.gray.opacity(0.8))
                    .font(.caption)
            }
        }
        .padding(8)
        .task {
            viewModel.action(.loadDDay(dDay))
        }
    }
}
