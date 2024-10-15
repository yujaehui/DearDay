//
//  DDayDetailView.swift
//  DearDay
//
//  Created by Jaehui Yu on 10/14/24.
//

import SwiftUI

struct DDayDetailView: View {
    @State private var showingAnniversarySheet: Bool = false
    
    var title: String
    var date: Date
    var startFromDayOne: Bool
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                Text(title)
                    .lineLimit(1)
                    .foregroundColor(.gray)
                    .font(.title3)
                
                HStack(alignment: .bottom, spacing: 20) {
                    Image("SampleImage1")
                        .resizable()
                        .scaledToFit()
                    Text(DateFormatterManager.shared.calculateDDay(from: date, startFromDayOne: startFromDayOne))
                        .foregroundColor(.gray)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                }
                Text(DateFormatterManager.shared.formatDate(date))
                    .foregroundColor(.gray.opacity(0.8))
                    .font(.callout)
                
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        print("Setting Button Tap")
                    } label: {
                        Image(systemName: "ellipsis")
                            .foregroundColor(.gray)
                            .rotationEffect(.degrees(90))
                    }
                }
                ToolbarItem(placement: .bottomBar) {
                    Button {
                        showingAnniversarySheet.toggle()
                    } label: {
                        Text("기념일 보기")
                            .foregroundStyle(.gray)
                            
                    }
                }
            }
            .sheet(isPresented: $showingAnniversarySheet, content: {
                AnniversaryView(date: date, startFromDayOne: startFromDayOne)
                    .presentationDetents([.medium])
            })
        }
    }
}

#Preview {
    DDayDetailView(title: "COMET", date: Calendar.current.date(from: DateComponents(year: 2024, month: 9, day: 22))!, startFromDayOne: true)
}


