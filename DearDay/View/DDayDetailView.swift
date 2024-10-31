//
//  DDayDetailView.swift
//  DearDay
//
//  Created by Jaehui Yu on 10/14/24.
//

import SwiftUI
import RealmSwift

struct DDayDetailView: View {    
    @ObservedRealmObject var dday: DDay
    
    @StateObject private var viewModel = DDayDetailViewModel()
    
    @State private var isPresentedAnniversaryView: Bool = false
    @State private var isPresentedAddDDayView: Bool = false
    @State private var isPresentedDeleteAlert = false
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            DDayImageCardView(dday: dday)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button {
                            isPresentedAddDDayView.toggle()
                        } label: {
                            Label("수정", systemImage: "square.and.pencil")
                        }
                        Button(role: .destructive) {
                            isPresentedDeleteAlert.toggle()
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
                            isPresentedAnniversaryView.toggle()
                        } label: {
                            Text("기념일 보기")
                                .foregroundStyle(.gray)
                        }
                    }
                }
            }
            .sheet(isPresented: $isPresentedAnniversaryView) {
                AnniversaryView(dday: dday)
                    .presentationDetents([.medium])
            }
            .sheet(isPresented: $isPresentedAddDDayView) {
                //TODO: EditDDayView로 이동 및 DDay 업데이트 로직 구현
            }
            .alert("해당 디데이를 삭제하시겠습니까?", isPresented: $isPresentedDeleteAlert) {
                Button("취소", role: .cancel) { }
                Button("삭제", role: .destructive) {
                    viewModel.action(.deleteDDay(dday))
                    dismiss()
                }
            }
        }
    }
}


