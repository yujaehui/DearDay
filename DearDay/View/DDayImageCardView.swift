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
    var dDayImage: UIImage?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(dDayItem.title)
                .asMainTitle()
            if let image = dDayImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            }
            HStack {
                VStack(alignment: .leading) {
                    Text("\(DateFormatterManager.shared.formatDate(dDayItem.date))\(dDayItem.isLunarDate ? " (음력)" : "")")
                        .asMainDate()
                    if dDayItem.repeatType != .none {
                        Text("[\(dDayItem.repeatType.rawValue) 반복]")
                        .asMainRepeatType()
                    }
                }
                Spacer()
                Text(dDayText)
                    .asMainDDayText()
            }
        }
        .padding()
    }
}
