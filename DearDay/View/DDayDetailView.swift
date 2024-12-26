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
    @State private var isPresentedErrorAlert = false
    @State private var alertMessage = ""
    
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
            .alert(isPresented: $isPresentedErrorAlert) {
                Alert(title: Text("오류"), message: Text(alertMessage), dismissButton: .default(Text("확인")))
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
            Section {
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
            }
            Section {
                Button {
                    let view = ShareDDayImageCardView(dDayItem: dDayItem, dDayText: viewModel.dDayText[dDayItem.pk] ?? "Loading...", dDayImage: viewModel.dDayImage[dDayItem.pk] ?? nil)
                    shareToInstagramStory(image: view.snapshot())
                } label: {
                    Label("Instagram 공유", systemImage: "square.and.arrow.up")
                }
            }
        } label: {
            Image(systemName: "ellipsis")
                .foregroundStyle(.secondary)
                .rotationEffect(.degrees(90))
        }
    }
    
    func shareToInstagramStory(image: UIImage,
                               backgroundTopColor: String = "#FFFFFF",
                               backgroundBottomColor: String = "#FFFFFF") {
        
        guard let urlScheme = URL(string: "instagram-stories://share?source_application=\(InstagramAppID.id)") else {
            alertMessage = "Instagram URL Scheme이 잘못되었습니다.\n잠시 후 다시 시도해 주십시오."
            isPresentedErrorAlert = true
            return
        }

        guard UIApplication.shared.canOpenURL(urlScheme) else {
            alertMessage = "Instagram이 설치되어 있지 않습니다.\n설치 후 다시 시도해 주십시오."
            isPresentedErrorAlert = true
            return
        }

        guard let imageData = image.pngData() else {
            alertMessage = "이미지 데이터를 변환할 수 없습니다.\n잠시 후 다시 시도해 주십시오."
            isPresentedErrorAlert = true
            return
        }

        let pasteboardItems: [String: Any] = [
            "com.instagram.sharedSticker.stickerImage": imageData,
            "com.instagram.sharedSticker.backgroundTopColor": backgroundTopColor,
            "com.instagram.sharedSticker.backgroundBottomColor": backgroundBottomColor
        ]

        UIPasteboard.general.setItems([pasteboardItems], options: [:])
        UIApplication.shared.open(urlScheme, options: [:], completionHandler: nil)
    }
}

