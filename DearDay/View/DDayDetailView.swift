//
//  DDayDetailView.swift
//  DearDay
//
//  Created by Jaehui Yu on 10/14/24.
//

import SwiftUI
import RealmSwift

struct DDayDetailView: View {
    var dDayItem: DDayItem
    @ObservedObject var viewModel: DDayViewModel
    
    @State private var isPresentedAnniversaryView: Bool = false
    @State private var isPresentedEditDDayView: Bool = false
    @State private var isPresentedDeleteAlert = false
    
    @Environment(\.dismiss) private var dismiss
        
    var body: some View {
        NavigationStack {
            DDayImageCardView(dDayItem: dDayItem, dDayText: viewModel.dDayText[dDayItem.pk] ?? "Loading...")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        DDayDetailMenu(isPresentedEditDDayView: $isPresentedEditDDayView, isPresentedDeleteAlert: $isPresentedDeleteAlert)
                        
                    }
                    ToolbarItem(placement: .bottomBar) {
                        if dDayItem.type == .numberOfDays {
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
                    AnniversaryView(dDayItem: dDayItem)
                        .presentationDetents([.medium])
                }
                .sheet(isPresented: $isPresentedEditDDayView) {
                    EditDDayView(dDayItem: dDayItem, viewModel: viewModel)
                }
                .alert("해당 디데이를 삭제하시겠습니까?", isPresented: $isPresentedDeleteAlert) {
                    Button("취소", role: .cancel) { }
                    Button("삭제", role: .destructive) {
                        viewModel.deleteDDay(dDayItem: dDayItem)
                        DispatchQueue.main.async {
                            dismiss()
                        }
                    }
                }
        }
        .onAppear {
            print("DDayDetailView appeared: \(dDayItem.title)")
        }
        .onDisappear {
            print("DDayDetailView disappeared: \(dDayItem.title)")
        }
    }
}

fileprivate struct DDayDetailMenu: View {
    @Binding var isPresentedEditDDayView: Bool
    @Binding var isPresentedDeleteAlert: Bool
    
    var body: some View {
        Menu {
            Button {
                isPresentedEditDDayView.toggle()
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
}
