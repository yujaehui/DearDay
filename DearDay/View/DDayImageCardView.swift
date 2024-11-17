//
//  DDayImageCardView.swift
//  DearDay
//
//  Created by Jaehui Yu on 10/16/24.
//

import SwiftUI
import RealmSwift

struct DDayImageCardView: View {    
    @ObservedRealmObject var dDay: DDay
    @StateObject private var viewModel: DDayCardViewModel = DDayCardViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(dDay.title)
                .lineLimit(1)
                .foregroundColor(.gray)
                .font(.title3)
            if let image = ImageDocumentManager.shared.loadImageFromDocument(fileName: "\(dDay.pk)") {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            }
            HStack {
                VStack(alignment: .leading) {
                    Text("\(DateFormatterManager.shared.formatDate(dDay.date))\(dDay.isLunarDate ? " (음력)" : "")")
                        .foregroundColor(.gray.opacity(0.8))
                        .font(.callout)
                    if dDay.repeatType != .none {
                        Text("[\(dDay.repeatType.rawValue) 반복]")
                            .foregroundColor(.gray.opacity(0.8))
                            .font(.caption)
                    }
                }
                Spacer()
                Text(viewModel.output.dDayText)
                    .foregroundColor(.gray)
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }
        }
        .padding()
        .task {
            viewModel.action(.loadDDay(dDay))
        }
    }
}
