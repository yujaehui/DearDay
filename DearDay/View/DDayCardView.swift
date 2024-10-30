//
//  DDayCardView.swift
//  DearDay
//
//  Created by Jaehui Yu on 10/14/24.
//

import SwiftUI

struct DDayCardView: View {
    var dday: DDay
    
    @StateObject private var viewModel = DDayViewModel()
    
    var body: some View {
        HStack(spacing: 20) {
            Text(dday.title)
                .foregroundColor(.gray)
                .font(.callout)
                .lineLimit(1)
            
            Spacer()
            VStack(alignment: .trailing) {
                Text(viewModel.output.ddayText)
                    .foregroundColor(.gray)
                    .font(.title3)
                    .fontWeight(.bold)
                Text(DateFormatterManager.shared.formatDate(dday.date))
                    .foregroundColor(.gray.opacity(0.8))
                    .font(.caption)
            }
        }
        .padding(8)
        .task {
            viewModel.action(.loadDDay(dday))
        }
    }
}
