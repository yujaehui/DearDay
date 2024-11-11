////
////  DDayViewModel.swift
////  DearDay
////
////  Created by Jaehui Yu on 10/30/24.
////
//
//import SwiftUI
//import RealmSwift
//import Combine
//
//@MainActor
//class DDayViewModel {
//    private let repository: DDayRepository
//    private let apiService: APIService
//    
//    var cancellables = Set<AnyCancellable>()
//    
//    var input = Input()
//    @Published var output = Output()
//    
//    init(repository: DDayRepository = DDayRepository(), apiService: APIService = APIService()) {
//        self.repository = repository
//        self.apiService = apiService
//        transform()
//    }
//}
//
//extension DDayViewModel: ViewModelType {
//    struct Input {
//        var loadDDays = PassthroughSubject<Results<DDay>, Never>()
//    }
//    
//    struct Output {
//        var dDayTexts: [String: String] = [:]
//    }
//    
//    enum Action {
//        case loadDDays(Results<DDay>)
//    }
//    
//    func action(_ action: Action) {
//        switch action {
//        case .loadDDays(let dDays):
//            input.loadDDays.send(dDays)
//        }
//    }
//    
//    func transform() {
//        print(#function)
//        input.loadDDays
//            .sink { [weak self] dDays in
//                guard let self = self else { return }
//                Task {
//                    var dDayTexts: [String: String] = [:]
//                    
//                    for dDay in dDays {
//                        let dDayText = await self.calculateDDay(
//                            from: dDay.date,
//                            type: dDay.type,
//                            isLunar: dDay.isLunarDate,
//                            startFromDayOne: dDay.startFromDayOne,
//                            repeatType: dDay.repeatType
//                        )
//                        
//                        dDayTexts[dDay.pk.stringValue] = dDayText
//                        
//                    }
//                    
//                    self.output.dDayTexts = dDayTexts
//                }
//            }
//            .store(in: &cancellables)
//    }
//    
//    private func calculateDDay(from date: Date, type: DDayType, isLunar: Bool, startFromDayOne: Bool, repeatType: RepeatType) async -> String {
//        print(#function)
//        let calendar = Calendar.current
//        var adjustedDate = date
//        
//        if isLunar {
//            if let closestLunarDate = await fetchClosestSolarDate(from: date, repeatType: repeatType) {
//                adjustedDate = closestLunarDate
//            } else {
//                return "음력 계산 실패"
//            }
//        }
//        
//        if !isLunar && adjustedDate < Date() {
//            adjustedDate = adjustForRepeatingDateIfNeeded(date: adjustedDate, repeatType: repeatType, calendar: calendar)
//        }
//        
//        return DateFormatterManager.shared.calculateDDayString(from: adjustedDate, type: type, startFromDayOne: startFromDayOne, calendar: calendar)
//    }
//    
//    private func fetchClosestSolarDate(from date: Date, repeatType: RepeatType) async -> Date? {
//        print(#function)
//        let calendar = Calendar.current
//        let currentYear = calendar.component(.year, from: Date())
//        let year = calendar.component(.year, from: date)
//        let month = calendar.component(.month, from: date)
//        let day = calendar.component(.day, from: date)
//        
//        switch repeatType {
//        case .none:
//            return await self.apiService.fetchSolarDate(year: year, month: month, day: day)
//        case .year:
//            if let thisYearDate = await self.apiService.fetchSolarDate(year: currentYear, month: month, day: day), thisYearDate >= Date() {
//                return thisYearDate
//            }
//            return await self.apiService.fetchSolarDate(year: currentYear + 1, month: month, day: day)
//        case .month: return nil
//        }
//    }
//    
//    private func adjustForRepeatingDateIfNeeded(date: Date, repeatType: RepeatType, calendar: Calendar) -> Date {
//        print(#function)
//        var adjustedDate = date
//        
//        switch repeatType {
//        case .none: break
//        case .year:
//            while adjustedDate < Date() {
//                if let newDate = calendar.date(byAdding: .year, value: 1, to: adjustedDate) {
//                    adjustedDate = newDate
//                }
//            }
//        case .month:
//            while adjustedDate < Date() {
//                if let newDate = calendar.date(byAdding: .month, value: 1, to: adjustedDate) {
//                    adjustedDate = newDate
//                }
//            }
//        }
//        return adjustedDate
//    }
//}
//
