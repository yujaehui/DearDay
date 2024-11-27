//
//  AppIntent.swift
//  DearDayListWidget
//
//  Created by Jaehui Yu on 11/27/24.
//

import WidgetKit
import AppIntents
import RealmSwift

struct DDayEntity: AppEntity {
    var id: String
    let type: DDayType
    let title: String
    let date: Date
    let isLunarDate: Bool
    let convertedSolarDateFromLunar: Date?
    let startFromDayOne: Bool
    let isRepeatOn: Bool
    let repeatType: RepeatType
    
    var truncatedTitle: String {
        title.count > 15 ? "\(title.prefix(15))…" : title
    }
    
    // 시스템이 D-Day를 어떻게 표시할지 정의
    var displayRepresentation: DisplayRepresentation {
        if id == "none" {
            return DisplayRepresentation(title: "\(truncatedTitle)")
        } else {
            return DisplayRepresentation(title: "\(truncatedTitle)", subtitle: "\(calculateDDaySync(from: date, type: type, isLunar: isLunarDate, startFromDayOne: startFromDayOne, repeatType: repeatType))")
        }
    }

    // 타입 전체에 대한 설명
    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        TypeDisplayRepresentation(
            name: LocalizedStringResource("D-Day", table: "AppIntents"),
            numericFormat: LocalizedStringResource("\(placeholder: .int) D-Days", table: "AppIntents")
        )
    }

    // Query를 지원하기 위한 Query 정의
    static var defaultQuery = DDayEntityQuery()
    
    private func calculateDDaySync(from date: Date, type: DDayType, isLunar: Bool, startFromDayOne: Bool, repeatType: RepeatType) -> String {
        let calendar = Calendar.current
        var adjustedDate = date
        
        if isLunar {
            if let closestLunarDate = fetchClosestSolarDateSync(from: date, repeatType: repeatType) {
                adjustedDate = closestLunarDate
            } else {
                return "음력 계산 실패"
            }
        }
        
        if !isLunar && adjustedDate < Date() {
            adjustedDate = adjustDateForRepeatType(date: adjustedDate, repeatType: repeatType, calendar: calendar)
        }
        
        return DateFormatterManager.shared.calculateDDayString(from: adjustedDate, type: type, startFromDayOne: startFromDayOne, calendar: calendar)
    }
    
    private func fetchClosestSolarDateSync(from date: Date, repeatType: RepeatType) -> Date? {
        let apiService = APIService()
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        
        switch repeatType {
        case .none:
            return apiService.fetchSolarDateSync(year: year, month: month, day: day)
        case .year:
            if let thisYearDate = apiService.fetchSolarDateSync(year: currentYear, month: month, day: day), thisYearDate >= Date() {
                return thisYearDate
            }
            return apiService.fetchSolarDateSync(year: currentYear + 1, month: month, day: day)
        case .month: return nil
        }
    }
    
    private func adjustDateForRepeatType(date: Date, repeatType: RepeatType, calendar: Calendar) -> Date {
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

extension DDayEntity {
    static var none: DDayEntity {
        DDayEntity(id: "none", type: .dDay, title: "선택 안함", date: Date.distantPast, isLunarDate: false, convertedSolarDateFromLunar: nil, startFromDayOne: false, isRepeatOn: false, repeatType: .none)
    }
}

// D-Day Query 정의
struct DDayEntityQuery: EntityQuery {
    // 특정 ID로 D-Day 엔티티 검색
    func entities(for identifiers: [DDayEntity.ID]) async throws -> [DDayEntity] {
        let repository = DDayRepository()
        let dDays = repository.fetchItem().filter { identifiers.contains($0.pk.stringValue) }
        let entities = dDays.map { DDayEntity(id: $0.pk.stringValue, type: $0.type, title: $0.title, date: $0.date, isLunarDate: $0.isLunarDate, convertedSolarDateFromLunar: $0.convertedSolarDateFromLunar, startFromDayOne: $0.startFromDayOne, isRepeatOn: $0.isRepeatOn, repeatType: $0.repeatType) }
        return entities
    }

    // 추천 D-Day 리스트 반환
    func suggestedEntities() async throws -> [DDayEntity] {
        let repository = DDayRepository()
        let dDays = repository.fetchItem()
        var entities = dDays.map { DDayEntity(id: $0.pk.stringValue, type: $0.type, title: $0.title, date: $0.date, isLunarDate: $0.isLunarDate, convertedSolarDateFromLunar: $0.convertedSolarDateFromLunar, startFromDayOne: $0.startFromDayOne, isRepeatOn: $0.isRepeatOn, repeatType: $0.repeatType) }
        entities.insert(.none, at: 0) // 선택 안함 항목 추가
        return entities
    }
}

struct ConfigurationDearDayListIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Configuration"
    static var description = IntentDescription("Displays a list of D-Days.")
    
    @Parameter(title: "직접 설정", default: false)
    var isCustomSelectionEnabled: Bool
    
    @Parameter(title: "D-Days", size: [.systemMedium: 3, .systemLarge: 5])
    var selectedDDays: [DDayEntity]?

    static var parameterSummary: some ParameterSummary {
        When(\.$isCustomSelectionEnabled, .equalTo, true) {
            Summary {
                \.$isCustomSelectionEnabled
                \.$selectedDDays
            }
        } otherwise: {
            Summary {
                \.$isCustomSelectionEnabled
            }
        }
    }
        
    // 직접 설정을 활성화하지 않았을 경우 사용할 default 값
    func defaultSelectedDDays() -> [DDayEntity] {
        let repository = DDayRepository()
        let dDays = repository.fetchItem()
        
        return dDays.map { DDayEntity(id: $0.pk.stringValue, type: $0.type, title: $0.title, date: $0.date, isLunarDate: $0.isLunarDate, convertedSolarDateFromLunar: $0.convertedSolarDateFromLunar, startFromDayOne: $0.startFromDayOne, isRepeatOn: $0.isRepeatOn, repeatType: $0.repeatType) }
    }
}
