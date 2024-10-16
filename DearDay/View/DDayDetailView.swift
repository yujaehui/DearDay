//
//  DDayDetailView.swift
//  DearDay
//
//  Created by Jaehui Yu on 10/14/24.
//

import SwiftUI

struct DDayDetailView: View {    
    @State private var showingAnniversarySheet: Bool = false
    @State private var showingDeleteAlert = false
    
    var dday: DDay
    
    var body: some View {
        NavigationStack {
            DDayImageCardView(dday: dday)
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
                    }
                }
            }
            .sheet(isPresented: $showingAnniversarySheet, content: {
                AnniversaryView(dday: dday)
                    .presentationDetents([.medium])
            })
            .alert("해당 디데이를 삭제하시겠습니까?", isPresented: $showingDeleteAlert) {
                Button("취소", role: .cancel) { }
                Button("삭제", role: .destructive) { }
            }
        }
    }
}

#Preview {
    DDayDetailView(dday: DDay(type: .numberOfDays, title: "COMET", date: Calendar.current.date(from: DateComponents(year: 2024, month: 9, day: 22))!, isLunarDate: false, startFromDayOne: true))
}


