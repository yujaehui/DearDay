//
//  DDayImageCardView.swift
//  DearDay
//
//  Created by Jaehui Yu on 10/16/24.
//

import SwiftUI

struct DDayImageCardView: View {
    var sampleImageList = ["SampleImage1", "SampleImage2", "SampleImage3"]
    
    var dday: DDay
    @State private var ddayText: String = "Loading..."
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(dday.title)
                .lineLimit(1)
                .foregroundColor(.gray)
                .font(.title3)
            Image(sampleImageList.randomElement()!)
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
                Text(ddayText)
                    .foregroundColor(.gray)
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }
        }
        .padding()
        .task {
            ddayText = await DateFormatterManager.shared.calculateDDay(from: dday.date, isLunar: dday.isLunarDate, startFromDayOne: dday.startFromDayOne, repeatType: dday.repeatType)
        }
    }
}

#Preview {
    DDayImageCardView(dday: DDay(type: .numberOfDays, title: "COMET", date: Calendar.current.date(from: DateComponents(year: 2024, month: 9, day: 22))!, isLunarDate: false, startFromDayOne: true))
}
