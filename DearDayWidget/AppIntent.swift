//
//  AppIntent.swift
//  DearDayWidgetExtension
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
        DisplayRepresentation(
            title: "\(truncatedTitle)",
            subtitle: "\(calculateDDaySync(from: date, type: type, isLunar: isLunarDate, startFromDayOne: startFromDayOne, repeatType: repeatType))"
        )
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
            let result = fetchClosestSolarDateSync(from: date, repeatType: repeatType)
            if let closestLunarDate = result.0 {
                adjustedDate = closestLunarDate
            } else if let errorMessage = result.1 {
                return errorMessage
            }
        }
        
        if !isLunar && adjustedDate < Date() {
            adjustedDate = adjustDateForRepeatType(date: adjustedDate, repeatType: repeatType, calendar: calendar)
        }
        
        return DateFormatterManager.shared.calculateDDayString(from: adjustedDate, type: type, startFromDayOne: startFromDayOne, calendar: calendar)
    }
    
    private func fetchClosestSolarDateSync(from date: Date, repeatType: RepeatType) -> (Date?, String?) {
        let apiService = APIService()
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        
        switch repeatType {
        case .none:
            let response = apiService.fetchSolarDateSync(year: year, month: month, day: day)
            return (response.data, response.error?.shortErrorMessage)
        case .year:
            let currentYearResponse = apiService.fetchSolarDateSync(year: currentYear, month: month, day: day)
            if let thisYearDate = currentYearResponse.data,
               calendar.startOfDay(for: thisYearDate) >= calendar.startOfDay(for: Date()) {
                return (thisYearDate, nil)
            }
            
            let nextYearResponse = apiService.fetchSolarDateSync(year: currentYear + 1, month: month, day: day)
            return (nextYearResponse.data, nextYearResponse.error?.shortErrorMessage)
        case .month:
            return (nil, nil)
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
    init(defaultEntity: Bool = true) {
        if defaultEntity {
            self.id = ""
            self.type = .dDay
            self.title = "No Upcoming D-Days"
            self.date = Date()
            self.isLunarDate = false
            self.convertedSolarDateFromLunar = nil
            self.startFromDayOne = true
            self.isRepeatOn = false
            self.repeatType = .none
        } else {
            fatalError("Custom initialization required")
        }
    }
}

extension DDayEntity {
    init(fromItem item: DDayItem) {
        self.id = item.pk
        self.type = item.type
        self.title = item.title
        self.date = item.date
        self.isLunarDate = item.isLunarDate
        self.convertedSolarDateFromLunar = item.convertedSolarDateFromLunar
        self.startFromDayOne = item.startFromDayOne
        self.isRepeatOn = item.isRepeatOn
        self.repeatType = item.repeatType
    }
}


// D-Day Query 정의
struct DDayEntityQuery: EntityQuery {
    // 특정 ID로 D-Day 엔티티 검색
    func entities(for identifiers: [DDayEntity.ID]) async throws -> [DDayEntity] {
        let items = DDayAppGroupStorage.load()
        let matched = items.filter { identifiers.contains($0.pk) }
        return matched.map { DDayEntity(fromItem: $0) }
    }

    // 추천 D-Day 리스트 반환
    func suggestedEntities() async throws -> [DDayEntity] {
        let items = DDayAppGroupStorage.load()
        return items.map { DDayEntity(fromItem: $0) }
    }
}

struct ConfigurationDearDayIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Configuration"
    static var description = IntentDescription("Displays a selected D-Day.")

    @Parameter(title: "D-Day")
    var selectedDDay: DDayEntity?
        
    func defaultSelectedDDay() -> DDayEntity {
        let items = DDayAppGroupStorage.load()
        return items.first.map { DDayEntity(fromItem: $0) } ?? DDayEntity(defaultEntity: true)
    }
}
