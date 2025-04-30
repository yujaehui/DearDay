//
//  EditDDayView.swift
//  DearDay
//
//  Created by Jaehui Yu on 11/4/24.
//

import SwiftUI
import PhotosUI
import RealmSwift

struct EditDDayView: View {
    let dDayItem: DDayItem
    @ObservedObject var viewModel: DDayViewModel
    
    @State var type: DDayType
    @State var title: String
    @State var selectedDate: Date
    @State var isLunarDate: Bool
    @State var startFromDayOne: Bool
    @State var isRepeatOn: Bool
    @State var repeatType: RepeatType
    
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var editedImage: UIImage?
    
    @State private var isPresentedImageEditorView = false
    @State private var isPresentedErrorAlert = false
    @State private var alertMessage = ""
    
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isTitleFieldFocused: Bool
    
    init(dDayItem: DDayItem, viewModel: DDayViewModel) {
        self.dDayItem = dDayItem
        self.viewModel = viewModel
        _type = State(initialValue: dDayItem.type)
        _title = State(initialValue: dDayItem.title)
        _selectedDate = State(initialValue: dDayItem.date)
        _isLunarDate = State(initialValue: dDayItem.isLunarDate)
        _startFromDayOne = State(initialValue: dDayItem.startFromDayOne)
        _isRepeatOn = State(initialValue: dDayItem.repeatType == .none ? false : true)
        _repeatType = State(initialValue: dDayItem.repeatType)
        _selectedImage = State(initialValue: viewModel.dDayImage[dDayItem.pk] ?? nil)
        _editedImage = State(initialValue: viewModel.dDayImage[dDayItem.pk] ?? nil)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                titleSection
                dateSection
                optionSection
                imageSection
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        validateAndEditDDay()
                    } label: {
                        Text("수정")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .fullScreenCover(isPresented: $isPresentedImageEditorView) {
                ImageEditorView(
                    selectedImage: selectedImage,
                    onComplete: { editedImage in
                        self.selectedImage = nil
                        self.editedImage = editedImage
                        isPresentedImageEditorView = false
                    },
                    onCancel: {
                        self.selectedImage = nil
                        isPresentedImageEditorView = false
                    }
                )
            }
            .alert(isPresented: $isPresentedErrorAlert) {
                Alert(title: Text("오류"), message: Text(alertMessage), dismissButton: .default(Text("확인")))
            }
            .task {
                if isLunarDate {
                    viewModel.updateLunarDate(lunarDate: selectedDate)
                }
            }
            .onChange(of: selectedItem) { newItem in
                Task {
                    await loadImage(from: newItem)
                }
            }
            .background(.background)
        }
    }
}

private extension EditDDayView {
    // MARK: - Title Section
    var titleSection: some View {
        Section {
            TextField("제목을 입력하세요", text: $title)
                .multilineTextAlignment(.center)
                .focused($isTitleFieldFocused)
        }
    }
    
    // MARK: - Date Section
    var dateSection: some View {
        Section {
            Text("\(DateFormatterManager.shared.formatDate(selectedDate))\(isLunarDate ? " (음력)" : "")")
                .asFormDate()
            
            if isLunarDate, let solarDate = viewModel.solarDate {
                Text("\(DateFormatterManager.shared.formatDate(solarDate))\(" (양력)")")
                    .asFormConvertedDate()
            } else if isLunarDate, let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .asFormConvertedDate()
            }
            
            DatePicker("", selection: $selectedDate, displayedComponents: .date)
                .datePickerStyle(.wheel)
                .labelsHidden()
                .onChange(of: selectedDate) { newDate in
                    if isLunarDate {
                        viewModel.updateLunarDate(lunarDate: newDate)
                    }
                }
        }
        .listRowSeparatorTint(.clear)
        .listRowBackground(Color.clear)
    }
    
    // MARK: - Option Section
    var optionSection: some View {
        Section {
            Toggle("음력", isOn: $isLunarDate)
                .onChange(of: isLunarDate) { newValue in
                    if newValue {
                        viewModel.updateLunarDate(lunarDate: selectedDate)
                    } else {
                        viewModel.solarDate = nil
                    }
                }
            
            if type == .dDay {
                Toggle("반복", isOn: $isRepeatOn)
                    .onChange(of: isRepeatOn) { newValue in
                        repeatType = newValue ? .year : .none
                    }
            }
            
            if isRepeatOn {
                Picker("반복 조건", selection: $repeatType) {
                    Text("매년").tag(RepeatType.year)
                    Text("매월").tag(RepeatType.month)
                }
            }
        }
    }
    
    // MARK: - Image Section
    var imageSection: some View {
        Section {
            PhotosPicker(
                selection: $selectedItem,
                matching: .images,
                photoLibrary: .shared()
            ) {
                HStack {
                    Text("이미지 선택")
                    Spacer()
                    Image(systemName: "plus")
                        .font(.title3)
                }
                .foregroundStyle(.primary)
            }
            
            if editedImage != nil {
                Image(uiImage: editedImage!)
                    .resizable()
                    .scaledToFit()
                
                Button(action: {
                    editedImage = nil // 이미지 삭제
                }) {
                    HStack {
                        Image(systemName: "trash")
                        Text("이미지 삭제")
                    }
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }
    
    // MARK: - Validate and Edit D-Day
    func validateAndEditDDay() {
        if title.isEmpty {
            alertMessage = "제목을 입력하세요."
            isPresentedErrorAlert = true
            return
        }
        
        if isLunarDate && viewModel.solarDate == nil,
           let errorMessage = viewModel.errorMessage {
            alertMessage = errorMessage
            isPresentedErrorAlert = true
            return
        }
        
        let updatedDDay = DDay(
            type: type,
            title: title,
            date: selectedDate,
            isLunarDate: isLunarDate,
            convertedSolarDateFromLunar: viewModel.solarDate,
            startFromDayOne: startFromDayOne,
            isRepeatOn: isRepeatOn,
            repeatType: repeatType
        )
        
        viewModel.editDDay(dDayItem: dDayItem, updatedDDay: updatedDDay, image: editedImage)
        dismiss()
    }
    
    // MARK: - Load Image
    private func loadImage(from item: PhotosPickerItem?) async {
        guard let item = item else { return }
        
        do {
            if let data = try await item.loadTransferable(type: Data.self) {
                selectedImage = downsampleImage(data: data)
                if selectedImage != nil {
                    isPresentedImageEditorView = true
                }
            }
        } catch {
            print("error: \(error)")
        }
        
        selectedItem = nil
    }
    
    private func downsampleImage(data: Data,
                                 to size: CGSize = UIScreen.main.bounds.size,
                                 scale: CGFloat = UIScreen.main.scale) -> UIImage? {
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let imageSource = CGImageSourceCreateWithData(data as CFData, imageSourceOptions) else { return nil }
        
        let maxDimensionInPixels = max(size.width, size.height) * scale
        let downsampleOptions = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxDimensionInPixels
        ] as CFDictionary
        
        guard let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions) else { return nil }
        
        return UIImage(cgImage: downsampledImage)
    }
}
