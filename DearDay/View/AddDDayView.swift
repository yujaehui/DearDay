//
//  AddDDayView.swift
//  DearDay
//
//  Created by Jaehui Yu on 10/30/24.
//

import SwiftUI
import PhotosUI

struct AddDDayView: View {
    @State var type: DDayType
    @State private var title: String = ""
    @State private var selectedDate = Date()
    @State private var isLunarDate = false
    @State private var isRepeatOn = false {
        didSet {
            if !isRepeatOn {
                repeatOption = .none // 반복을 끄면 자동으로 .none으로 설정
            }
        }
    }
    @State private var repeatOption: RepeatType = .none
    @State private var startFromOne = false
    @State private var isWidgetRegistered = false
    @State private var selectedImage: UIImage? // Holds the selected image
    
    private var availableRepeatOptions: [RepeatType] {
        isLunarDate ? [.year] : [.month, .year]
    }
    
    @State private var isImagePickerPresented = false // To present the image picker
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("제목을 입력하세요", text: $title)
                        .multilineTextAlignment(.center)
                }
                
                Section {
                    Text("\(DateFormatterManager.shared.formatDate(selectedDate))\(isLunarDate ? " (음력)" : "")")
                        .font(.title)
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                    DatePicker(selection: $selectedDate, displayedComponents: .date) {
                        Text("")
                    }
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                }
                .listRowSeparatorTint(.clear)
                .listRowBackground(Color.clear)
                
                Section {
                    Toggle("음력", isOn: $isLunarDate)
                    
                    Toggle("반복", isOn: $isRepeatOn)
                    
                    if isRepeatOn {
                        Picker("반복 조건", selection: $repeatOption) {
                            ForEach(availableRepeatOptions, id: \.self) { option in
                                Text(option.rawValue)
                            }
                        }
                    }
                    
                    if type == .numberOfDays {
                        Toggle("설정일을 1부터 시작", isOn: $startFromOne)
                    }
                    
                    Toggle("위젯 등록", isOn: $isWidgetRegistered)
                }
                
                Section {
                    Button {
                        isImagePickerPresented = true
                    } label: {
                        HStack {
                            Text("이미지 선택")
                            Spacer()
                            Image(systemName: "plus")
                                .font(.title3)
                        }
                        .foregroundStyle(.black)
                    }
                    
                    if selectedImage != nil {
                        VStack {
                            Image(uiImage: selectedImage!)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 200)
                                .clipped()
                                .cornerRadius(10)
                            
                            Button(action: {
                                selectedImage = nil // 이미지 삭제
                            }) {
                                HStack {
                                    Image(systemName: "trash")
                                    Text("이미지 삭제")
                                }
                                .foregroundColor(.red)
                            }
                            .padding(.top, 5)
                        }
                    }
                }
                
                
            }
            .sheet(isPresented: $isImagePickerPresented) {
                ImagePicker(selectedImage: $selectedImage)
                    .ignoresSafeArea()
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        print("Add Button Tap")
                    } label: {
                        Text("ADD")
                            .foregroundColor(.gray)
                    }
                }
            }
        }
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

#Preview {
    AddDDayView(type: .dDay)
}


