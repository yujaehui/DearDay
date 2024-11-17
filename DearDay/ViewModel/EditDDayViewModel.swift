//
//  EditDDayViewModel.swift
//  DearDay
//
//  Created by Jaehui Yu on 11/4/24.
//

import SwiftUI
import Combine
import WidgetKit

@MainActor
class EditDDayViewModel {
    private let repository: DDayRepository
    private let apiService: APIService
    
    var cancellables = Set<AnyCancellable>()
    
    var input = Input()
    @Published var output = Output()
    
    init(repository: DDayRepository = DDayRepository(), apiService: APIService = APIService()) {
        self.repository = repository
        self.apiService = apiService
        transform()
    }
}

extension EditDDayViewModel: ViewModelType {
    struct Input {
        var updateLunarDate = PassthroughSubject<Date, Never>()
        var editDDay = PassthroughSubject<(DDay, DDay, UIImage?), Never>()
    }
    
    struct Output {
        var solarDate: Date?
        var editCompleted = PassthroughSubject<Void, Never>() // 수정 완료 신호
    }
    
    enum Action {
        case updateLunarDate(Date)
        case editDDay(DDay, DDay, UIImage?)
    }
    
    func action(_ action: Action) {
        switch action {
        case .updateLunarDate(let lunarDate):
            input.updateLunarDate.send(lunarDate)
        case .editDDay(let dDay,let newDDay, let image):
            input.editDDay.send((dDay, newDDay, image))
        }
    }
    
    func transform() {
        input.updateLunarDate
            .flatMap { lunarDate in
                return Future { promise in
                    Task {
                        let solarDate = await self.apiService.fetchSolarDate(lunarDate: lunarDate)
                        promise(.success(solarDate))
                    }
                }
            }
            .receive(on: DispatchQueue.main)
            .assign(to: \.output.solarDate, on: self)
            .store(in: &cancellables)
        
        input.editDDay
            .sink { [weak self] dDay, newDDay, image in
                guard let self = self else { return }
                // 1. 이전 이미지가 있다면 제거
                if ImageDocumentManager.shared.loadImageFromDocument(fileName: "\(dDay.pk)") != nil {
                    ImageDocumentManager.shared.removeImageFromDocument(fileName: "\(dDay.pk)")
                }
                // 2. 현재 이미지가 있다면 추가
                if let image = image {
                    ImageDocumentManager.shared.saveImageToDocument(image: image, fileName: "\(dDay.pk)")
                }
                
                self.repository.updateItem(dDay, title: newDDay.title, date: newDDay.date, isLunarDate: newDDay.isLunarDate, startFromDayOne: newDDay.startFromDayOne, repeatType: newDDay.repeatType)
                
                NotificationManager.shared.removeNotification(for: dDay)
                NotificationManager.shared.scheduleNotification(for: dDay)
                
                WidgetCenter.shared.reloadAllTimelines()
                
                self.output.editCompleted.send() // 수정 완료 이벤트 전송
            }
            .store(in: &cancellables)
    }
}
