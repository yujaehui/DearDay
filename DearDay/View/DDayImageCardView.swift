//
//  DDayImageCardView.swift
//  DearDay
//
//  Created by Jaehui Yu on 10/16/24.
//

import SwiftUI

struct DDayImageCardView: View {    
    var dday: DDay
    
    @StateObject private var viewModel = DDayViewModel()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(dday.title)
                .lineLimit(1)
                .foregroundColor(.gray)
                .font(.title3)
            Image("SampleImage1")
                .resizable()
                .scaledToFit()
            HStack {
                VStack(alignment: .leading) {
                    Text("\(DateFormatterManager.shared.formatDate(dday.date))\(dday.isLunarDate ? " (음력)" : "")")
                        .foregroundColor(.gray.opacity(0.8))
                        .font(.callout)
                    if dday.repeatType != .none {
                        Text("[\(dday.repeatType.rawValue) 반복]")
                            .foregroundColor(.gray.opacity(0.8))
                            .font(.caption)
                    }
                }
                Spacer()
                Text(viewModel.output.ddayText)
                    .foregroundColor(.gray)
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }
        }
        .padding()
        .task {
            viewModel.action(.loadDDay(dday))
        }
    }
}
