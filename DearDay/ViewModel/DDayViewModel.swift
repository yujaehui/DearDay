//
//  DDayViewModel.swift
//  DearDay
//
//  Created by Jaehui Yu on 10/30/24.
//

import SwiftUI
import Combine

@MainActor
class DDayViewModel {
    var cancellables = Set<AnyCancellable>()
    
    var input = Input()
    @Published var output = Output()
    
    init() {
        transform()
    }
}

extension DDayViewModel: ViewModelType {
    struct Input {
        var loadDDay = PassthroughSubject<DDay, Never>()
    }
    
    struct Output {
        var ddayText: String = "Loading..."
    }
    
    enum Action {
        case loadDDay(DDay)
    }
    
    func action(_ action: Action) {
        switch action {
        case .loadDDay(let dday):
            input.loadDDay.send(dday)
        }
    }
    
    func transform() {
        input.loadDDay
            .sink { [weak self] dday in
                guard let self = self else { return }
                Task {
                    let ddayText = await self.calculateDDay(
                        from: dday.date,
                        isLunar: dday.isLunarDate,
                        startFromDayOne: dday.startFromDayOne,
                        repeatType: dday.repeatType
                    )
                    self.output.ddayText = ddayText
                }
            }
            .store(in: &cancellables)
    }
    
    private func calculateDDay(from date: Date, isLunar: Bool, startFromDayOne: Bool, repeatType: RepeatType) async -> String {
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
        
        return DateFormatterManager.shared.calculateDDayString(from: adjustedDate, startFromDayOne: startFromDayOne, calendar: calendar)
    }
    
    private func fetchClosestSolarDate(from date: Date, repeatType: RepeatType) async -> Date? {
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())
        let targetYear = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        
        switch repeatType {
        case .none:
            return await fetchSolarDate(year: targetYear, month: month, day: day)
        case .year:
            if let thisYearDate = await fetchSolarDate(year: currentYear, month: month, day: day), thisYearDate >= Date() {
                return thisYearDate
            }
            return await fetchSolarDate(year: currentYear + 1, month: month, day: day)
        case .month: return nil
        }
    }
    
    private func fetchSolarDate(year: Int, month: Int, day: Int) async -> Date? {
        let calendar = Calendar.current
        
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
