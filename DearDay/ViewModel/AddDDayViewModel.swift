//
//  AddDDayViewModel.swift
//  DearDay
//
//  Created by Jaehui Yu on 10/31/24.
//

import SwiftUI
import Combine

@MainActor
class AddDDayViewModel: ObservableObject {
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

extension AddDDayViewModel: ViewModelType {
    struct Input {
        var updateLunarDate = PassthroughSubject<Date, Never>()
        var addDDay = PassthroughSubject<(DDay, UIImage?), Never>()
    }
    
    struct Output {
        var solarDate: Date?
        var addCompleted = PassthroughSubject<Void, Never>() // 추가 완료 신호
    }
    
    enum Action {
        case updateLunarDate(Date)
        case addDDay(DDay, UIImage?)
    }
    
    func action(_ action: Action) {
        switch action {
        case .updateLunarDate(let lunarDate):
            input.updateLunarDate.send(lunarDate)
        case .addDDay(let dDay, let image):
            input.addDDay.send((dDay, image))
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
        
        input.addDDay
            .sink { [weak self] dDay, image in
                guard let self = self else { return }
                if let image = image {
                    ImageDocumentManager.shared.saveImageToDocument(image: image, fileName: "\(dDay.pk)")
                }
                
                self.repository.createItem(dDay)
                
                NotificationManager.shared.scheduleNotification(for: dDay)
                
                self.output.addCompleted.send() // 추가 완료 이벤트 전송
            }
            .store(in: &cancellables)
    }
}
