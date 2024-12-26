//
//  ShareDDayImageCardView.swift
//  DearDay
//
//  Created by Jaehui Yu on 12/26/24.
//

import SwiftUI
import RealmSwift

struct ShareDDayImageCardView: View {
    var dDayItem: DDayItem
    var dDayText: String
    var dDayImage: UIImage?
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text("Dear Day")
                    .foregroundStyle(.gray)
                    .font(.headline)
            }
            .padding(.horizontal, 24)
            
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
                    if isErrorMessage(dDayText) {
                        Text(dDayText)
                            .asMainErrorText()
                    } else {
                        Text(dDayText)
                            .asMainDDayText()
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(colorScheme == .light ? Color.white : Color.black)
                    .shadow(color: Color.gray.opacity(0.5), radius: 6, x: 0, y: 3)
            )
            .padding(.horizontal)
        }
    }
    
    private func isErrorMessage(_ text: String) -> Bool {
        let shortErrorMessages = APIServiceError.allCases.map { $0.shortErrorMessage }
        return shortErrorMessages.contains(text)
    }
}
