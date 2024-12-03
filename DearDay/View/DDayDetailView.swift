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
            DDayImageCardView(
                dDayItem: dDayItem,
                dDayText: viewModel.dDayText[dDayItem.pk] ?? "Loading...",
                dDayImage: viewModel.dDayImage[dDayItem.pk] ?? nil
            )
            .toolbar {
                ToolbarContent()
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
                    dismiss()
                }
            }
        }
    }
}

private extension DDayDetailView {
    @ToolbarContentBuilder
    func ToolbarContent() -> some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            DDayDetailMenu()
        }
        ToolbarItem(placement: .bottomBar) {
            if dDayItem.type == .numberOfDays {
                Button {
                    isPresentedAnniversaryView.toggle()
                } label: {
                    Text("기념일 보기")
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
    
    func DDayDetailMenu() -> some View {
        Menu {
            Button {
                $isPresentedEditDDayView.wrappedValue.toggle()
            } label: {
                Label("수정", systemImage: "square.and.pencil")
            }
            Button(role: .destructive) {
                $isPresentedDeleteAlert.wrappedValue.toggle()
            } label: {
                Label("삭제", systemImage: "trash")
            }
        } label: {
            Image(systemName: "ellipsis")
                .foregroundStyle(.secondary)
                .rotationEffect(.degrees(90))
        }
    }
}
