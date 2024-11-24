//
//  DDayImageCardView.swift
//  DearDay
//
//  Created by Jaehui Yu on 10/16/24.
//

import SwiftUI
import RealmSwift

struct DDayImageCardView: View {
    var dDayItem: DDayItem
    var dDayText: String

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(dDayItem.title)
                .lineLimit(1)
                .foregroundColor(.gray)
                .font(.title3)
            if let image = ImageDocumentManager.shared.loadImageFromDocument(fileName: "\(dDayItem.pk)") {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            }
            HStack {
                VStack(alignment: .leading) {
                    Text("\(DateFormatterManager.shared.formatDate(dDayItem.date))\(dDayItem.isLunarDate ? " (음력)" : "")")
                        .foregroundColor(.gray.opacity(0.8))
                        .font(.callout)
                    if dDayItem.repeatType != .none {
                        Text("[\(dDayItem.repeatType.rawValue) 반복]")
                            .foregroundColor(.gray.opacity(0.8))
                            .font(.caption)
                    }
                }
                Spacer()
                Text(dDayText)
                    .foregroundColor(.gray)
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }
        }
        .padding()
        .onAppear {
            print("DDayImageCardView appeared: \(dDayItem.title)")
        }
        .onDisappear {
            print("DDayImageCardView disappeared: \(dDayItem.title)")
        }
    }
}
