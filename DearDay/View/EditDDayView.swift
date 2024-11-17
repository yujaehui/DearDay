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
    @Environment(\.dismiss) private var dismiss
    @ObservedRealmObject var dDay: DDay
    @StateObject private var viewModel = EditDDayViewModel()
    
    @State var type: DDayType
    @State var title: String
    @State var selectedDate: Date
    @State var isLunarDate: Bool
    @State var startFromDayOne: Bool
    @State var isRepeatOn: Bool
    @State var repeatType: RepeatType
    @State var selectedImage: UIImage?
    
    @State private var isPresentedImagePicker = false
    @State private var isPresentedErrorAlert = false
    @State private var alertMessage = ""
    
    
    init(dDay: DDay) {
        _dDay = ObservedRealmObject(wrappedValue: dDay)
        _type = State(initialValue: dDay.type)
        _title = State(initialValue: dDay.title)
        _selectedDate = State(initialValue: dDay.date)
        _isLunarDate = State(initialValue: dDay.isLunarDate)
        _startFromDayOne = State(initialValue: dDay.startFromDayOne)
        _isRepeatOn = State(initialValue: dDay.repeatType == .none ? false : true)
        _repeatType = State(initialValue: dDay.repeatType)
        _selectedImage = State(initialValue: ImageDocumentManager.shared.loadImageFromDocument(fileName: "\(dDay.pk)"))
    }
    
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
                    if isLunarDate {
                        if let solarDate = viewModel.output.solarDate {
                            Text("\(DateFormatterManager.shared.formatDate(solarDate))\(" (양력)")")
                                .foregroundStyle(.gray)
                                .frame(maxWidth: .infinity)
                                .multilineTextAlignment(.center)
                        } else {
                            Text("해당 날짜는 음양력 계산이 불가능합니다.")
                                .foregroundStyle(.gray)
                                .frame(maxWidth: .infinity)
                                .multilineTextAlignment(.center)
                        }
                    }
                    DatePicker(selection: $selectedDate, displayedComponents: .date) {
                        Text("")
                    }
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .onChange(of: selectedDate) { newDate in
                        if isLunarDate {
                            viewModel.action(.updateLunarDate(newDate))
                        }
                    }
                }
                .listRowSeparatorTint(.clear)
                .listRowBackground(Color.clear)
                
                Section {
                    Toggle("음력", isOn: $isLunarDate)
                    
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
                        .foregroundStyle(.black)
                        .padding(.bottom, 5) // 버튼과 이미지 간의 간격 추가
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
            .sheet(isPresented: $isPresentedImagePicker) {
                ImagePicker(selectedImage: $selectedImage)
                    .ignoresSafeArea()
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        if title.isEmpty {
                            alertMessage = "제목을 입력하세요."
                            isPresentedErrorAlert = true
                        } else if isLunarDate && viewModel.output.solarDate == nil {
                            alertMessage = "해당 날짜는 음양력 계산이 불가능합니다."
                            isPresentedErrorAlert = true
                        } else {
                            let newDDay = DDay(
                                type: type,
                                title: title,
                                date: selectedDate,
                                isLunarDate: isLunarDate,
                                convertedSolarDateFromLunar: viewModel.output.solarDate,
                                startFromDayOne: startFromDayOne,
                                repeatType: repeatType
                            )
                            viewModel.action(.editDDay(dDay, newDDay, selectedImage))
                            
                        }
                    } label: {
                        Text("수정")
                            .foregroundColor(.gray)
                    }
                    .alert(isPresented: $isPresentedErrorAlert) {
                        Alert(title: Text("오류"), message: Text(alertMessage), dismissButton: .default(Text("확인")))
                    }
                }
            }
            .onReceive(viewModel.output.editCompleted) {
                dismiss()
            }
        }
    }
}

//#Preview {
//    EditDDayView()
//}
