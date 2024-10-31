//
//  AddDDayViewModel.swift
//  DearDay
//
//  Created by Jaehui Yu on 10/31/24.
//

import SwiftUI
import Combine

@MainActor
class AddDDayViewModel {
    private let repository = DDayRepository()
    
    var cancellables = Set<AnyCancellable>()
    
    var input = Input()
    @Published var output = Output()
    
    init() {
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
        case .addDDay(let dday, let image):
            input.addDDay.send((dday, image))
        }
    }
    
    func transform() {
        input.updateLunarDate
            .sink { [weak self] lunarDate in
                guard let self = self else { return }
                Task {
                    self.output.solarDate = await self.fetchSolarDate(lunarDate: lunarDate)
                }
            }
            .store(in: &cancellables)
        
        input.addDDay
            .sink { [weak self] dday, image in
                guard let self = self else { return }
                if let image = image {
                    ImageDocumentManager.shared.saveImageToDocument(image: image, fileName: "\(dday.pk)")
                }
                self.repository.createItem(dday)
                self.output.addCompleted.send() // 추가 완료 이벤트 전송
            }
            .store(in: &cancellables)
    }
    
    private func fetchSolarDate(lunarDate: Date) async -> Date? {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: lunarDate)
        let month = calendar.component(.month, from: lunarDate)
        let day = calendar.component(.day, from: lunarDate)
        
        do {
            let solarDateItems = try await APIService.shared.fetchSolarDateItems(lunYear: year, lunMonth: month, lunDay: day)
            for solarItem in solarDateItems {
                if let convertedDate = calendar.date(from: DateComponents(year: Int(solarItem.solYear), month: Int(solarItem.solMonth), day: Int(solarItem.solDay))) {
                    return convertedDate
                }
            }
        } catch {
            print("Error fetching closest lunar date for year \(year): \(error)")
        }
        return nil
    }
}
