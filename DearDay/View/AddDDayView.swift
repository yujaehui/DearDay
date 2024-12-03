//
//  AddDDayView.swift
//  DearDay
//
//  Created by Jaehui Yu on 10/30/24.
//

import SwiftUI
import PhotosUI

struct AddDDayView: View {
    @EnvironmentObject var viewModel: DDayViewModel
    
    @State var type: DDayType = .dDay
    @State var title: String = ""
    @State var selectedDate = Date()
    @State var isLunarDate: Bool = false
    @State var startFromDayOne: Bool = false
    @State var isRepeatOn: Bool = false
    @State var repeatType: RepeatType = .none
    @State var selectedImage: UIImage?
    
    @State private var isPresentedImagePicker = false
    @State private var isPresentedErrorAlert = false
    @State private var alertMessage = ""
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                titleSection
                dateSection
                optionsSection
                imageSection
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        validateAndAddDDay()
                    } label: {
                        Text("추가")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .sheet(isPresented: $isPresentedImagePicker) {
                ImagePicker(selectedImage: $selectedImage)
                    .ignoresSafeArea()
            }
            .alert(isPresented: $isPresentedErrorAlert) {
                Alert(title: Text("오류"), message: Text(alertMessage), dismissButton: .default(Text("확인")))
            }
            .background(.background)
        }
    }
}

private extension AddDDayView {
    // MARK: - Title Section
    var titleSection: some View {
        Section {
            TextField("제목을 입력하세요", text: $title)
                .multilineTextAlignment(.center)
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
            } else if isLunarDate {
                Text("해당 날짜는 음양력 계산이 불가능합니다.")
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
    
    // MARK: - Options Section
    var optionsSection: some View {
        Section {
            Toggle("음력", isOn: $isLunarDate)
                .onChange(of: isLunarDate) { newValue in
                    if newValue {
                        viewModel.updateLunarDate(lunarDate: selectedDate)
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
            Button {
                isPresentedImagePicker = true
            } label: {
                HStack {
                    Text("이미지 선택")
                    Spacer()
                    Image(systemName: "plus")
                        .font(.title3)
                }
                .foregroundStyle(.primary)
            }
            
            if selectedImage != nil {
                Image(uiImage: selectedImage!)
                    .resizable()
                    .scaledToFit()
                
                Button(action: {
                    selectedImage = nil // 이미지 삭제
                }) {
                    HStack {
                        Image(systemName: "trash")
                        Text("이미지 삭제")
                    }
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }
    
    // MARK: - Validation and Add D-Day
    func validateAndAddDDay() {
        if title.isEmpty {
            alertMessage = "제목을 입력하세요."
            isPresentedErrorAlert = true
        }
        
        if isLunarDate && viewModel.solarDate == nil {
            alertMessage = "해당 날짜는 음양력 계산이 불가능합니다."
            isPresentedErrorAlert = true
            return
        }
        
        let dDay = DDay(
            type: type,
            title: title,
            date: selectedDate,
            isLunarDate: isLunarDate,
            convertedSolarDateFromLunar: viewModel.solarDate,
            startFromDayOne: startFromDayOne,
            isRepeatOn: isRepeatOn,
            repeatType: repeatType
        )
        
        viewModel.addDDay(dDay: dDay, image: selectedImage)
        dismiss()
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            guard let provider = results.first?.itemProvider, provider.canLoadObject(ofClass: UIImage.self) else { return }
            
            provider.loadObject(ofClass: UIImage.self) { image, _ in
                DispatchQueue.main.async {
                    self.parent.selectedImage = image as? UIImage
                }
            }
        }
    }
}



