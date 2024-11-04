//
//  EditDDayViewModel.swift
//  DearDay
//
//  Created by Jaehui Yu on 11/4/24.
//

import SwiftUI
import Combine

@MainActor
class EditDDayViewModel {
    private let repository = DDayRepository()
    
    var cancellables = Set<AnyCancellable>()
    
    var input = Input()
    @Published var output = Output()
    
    init() {
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
            .sink { [weak self] lunarDate in
                guard let self = self else { return }
                Task {
                    self.output.solarDate = await self.fetchSolarDate(lunarDate: lunarDate)
                }
            }
            .store(in: &cancellables)
        
        input.editDDay
            .sink { [weak self] dDay, newDDay, image in
                guard let self = self else { return }
                // 1. 이전 이미지가 있다면 제거
                if ImageDocumentManager.shared.loadImageToDocument(fileName: "\(newDDay.pk)") != nil {
                    ImageDocumentManager.shared.removeImageFromDocument(fileName: "\(newDDay.pk)")
                }
                // 2. 현재 이미지가 있다면 추가
                if let image = image {
                    ImageDocumentManager.shared.saveImageToDocument(image: image, fileName: "\(newDDay.pk)")
                }
                
                self.repository.updateItem(dDay, title: newDDay.title, date: newDDay.date, isLunarDate: newDDay.isLunarDate, startFromDayOne: newDDay.startFromDayOne, repeatType: newDDay.repeatType)
                self.output.editCompleted.send() // 추가 완료 이벤트 전송
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
