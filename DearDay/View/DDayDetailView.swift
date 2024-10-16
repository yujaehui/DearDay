//
//  DDayDetailView.swift
//  DearDay
//
//  Created by Jaehui Yu on 10/14/24.
//

import SwiftUI

struct DDayDetailView: View {
    @State private var showingAnniversarySheet: Bool = false
    @State private var showingCountingDaysSheet: Bool = false
    @State private var showingDeleteAlert = false
    
    var dday: DDay
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                Text(dday.title)
                    .lineLimit(1)
                    .foregroundColor(.gray)
                    .font(.title3)
                
                HStack(alignment: .bottom, spacing: 20) {
                    Image("SampleImage1")
                        .resizable()
                        .scaledToFit()
                    Text(DateFormatterManager.shared.calculateDDay(from: dday.date, startFromDayOne: dday.startFromDayOne))
                        .foregroundColor(.gray)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                }
                Text(DateFormatterManager.shared.formatDate(dday.date))
                    .foregroundColor(.gray.opacity(0.8))
                    .font(.callout)
                
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button {
                            print("수정")
                        } label: {
                            Label("수정", systemImage: "square.and.pencil")
                        }
                        Button(role: .destructive) {
                            showingDeleteAlert.toggle()
                        } label: {
                            Label("삭제", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .foregroundColor(.gray)
                            .rotationEffect(.degrees(90))
                    }
                    
                }
                ToolbarItem(placement: .bottomBar) {
                    if dday.type == .numberOfDays {
                        Button {
                            showingAnniversarySheet.toggle()
                        } label: {
                            Text("기념일 보기")
                                .foregroundStyle(.gray)
                        }
                    } else if dday.type == .dDay {
                        Button {
                            showingCountingDaysSheet.toggle()
                        } label: {
                            Text("날짜 계산하기")
                                .foregroundStyle(.gray)
                        }
                    }
                }
            }
            .sheet(isPresented: $showingAnniversarySheet, content: {
                AnniversaryView(dday: dday)
                    .presentationDetents([.medium])
            })
            .sheet(isPresented: $showingCountingDaysSheet, content: {
                CountingDaysView()
                    .presentationDetents([.medium])
            })
        }
    }
}

#Preview {
    DDayDetailView(dday: DDay(type: .numberOfDays, title: "COMET", date: Calendar.current.date(from: DateComponents(year: 2024, month: 9, day: 22))!, startFromDayOne: true))
}


