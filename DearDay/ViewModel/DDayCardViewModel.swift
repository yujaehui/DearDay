//
//  DDayCardViewModel.swift
//  DearDay
//
//  Created by Jaehui Yu on 11/11/24.
//

import Foundation
import Combine

@MainActor
final class DDayCardViewModel {
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

extension DDayCardViewModel: ViewModelType {
    struct Input {
        var loadDDay = PassthroughSubject<DDay, Never>()
    }
    
    struct Output {
        var dDayText: String = "Loading..."
    }
    
    enum Action {
        case loadDDay(DDay)
    }
    
    func action(_ action: Action) {
        switch action {
        case .loadDDay(let dDay):
            input.loadDDay.send(dDay)
        }
    }
    
    func transform() {
        input.loadDDay
            .sink { [weak self] dDay in
                guard let self = self else { return }
                Task {
                    let dDayText = await self.calculateDDay(
                        from: dDay.date,
                        type: dDay.type,
                        isLunar: dDay.isLunarDate,
                        startFromDayOne: dDay.startFromDayOne,
                        repeatType: dDay.repeatType
                    )
                    self.output.dDayText = dDayText
                }
            }
            .store(in: &cancellables)
    }
    
    private func calculateDDay(from date: Date, type: DDayType, isLunar: Bool, startFromDayOne: Bool, repeatType: RepeatType) async -> String {
        let calendar = Calendar.current
        var adjustedDate = date
        
        if isLunar {
            if let closestLunarDate = await fetchClosestSolarDate(from: date, repeatType: repeatType) {
                adjustedDate = closestLunarDate
            } else {
                return "음력 계산 실패"
            }
        }
        
        if !isLunar && adjustedDate < Date() {
            adjustedDate = adjustForRepeatingDateIfNeeded(date: adjustedDate, repeatType: repeatType, calendar: calendar)
        }
        
        return DateFormatterManager.shared.calculateDDayString(from: adjustedDate, type: type, startFromDayOne: startFromDayOne, calendar: calendar)
    }
    
    private func fetchClosestSolarDate(from date: Date, repeatType: RepeatType) async -> Date? {
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        
        switch repeatType {
        case .none:
            return await self.apiService.fetchSolarDate(year: year, month: month, day: day)
        case .year:
            if let thisYearDate = await self.apiService.fetchSolarDate(year: currentYear, month: month, day: day), thisYearDate >= Date() {
                return thisYearDate
            }
            return await self.apiService.fetchSolarDate(year: currentYear + 1, month: month, day: day)
        case .month: return nil
        }
    }
    
    private func adjustForRepeatingDateIfNeeded(date: Date, repeatType: RepeatType, calendar: Calendar) -> Date {
        var adjustedDate = date
        
        switch repeatType {
        case .none: break
        case .year:
            while adjustedDate < Date() {
                if let newDate = calendar.date(byAdding: .year, value: 1, to: adjustedDate) {
                    adjustedDate = newDate
                }
            }
        case .month:
            while adjustedDate < Date() {
                if let newDate = calendar.date(byAdding: .month, value: 1, to: adjustedDate) {
                    adjustedDate = newDate
                }
            }
        }
        return adjustedDate
    }
}

