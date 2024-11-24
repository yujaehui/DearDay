//
//  DDayViewModel.swift
//  DearDay
//
//  Created by Jaehui Yu on 11/17/24.
//

import Foundation
import RealmSwift
import WidgetKit
import SwiftUI

enum SortOption: String, CaseIterable, Identifiable {
    case creationDate = "생성일"
    case title = "제목"
    case dDay = "디데이"
    
    var id: String { self.rawValue }
    
    static func from(rawValue: String) -> SortOption {
        return SortOption(rawValue: rawValue) ?? .creationDate
    }
}

@MainActor
final class DDayViewModel: ObservableObject {
    //@Published var dDays: [DDay] = []
    @Published var dDayItems: [DDayItem] = []
    @Published var dDayText: [String: String] = [:]
    @Published var solarDate: Date?
    
    @Published private(set) var sortedAndGroupedDDays: [(key: DDayType, value: [DDayItem])] = []
    @Published private(set) var sortedDDays: [DDayItem] = []
    
    @Published var isGrouped: Bool = UserDefaults.standard.bool(forKey: "isGrouped") {
        didSet {
            UserDefaults.standard.set(isGrouped, forKey: "isGrouped")
        }
    }
    @Published var selectedSortOption: SortOption = SortOption.from(rawValue: UserDefaults.standard.string(forKey: "selectedSortOption") ?? SortOption.creationDate.rawValue) {
        didSet {
            UserDefaults.standard.set(selectedSortOption.rawValue, forKey: "selectedSortOption")
        }
    }

    private let repository: DDayRepositoryProtocol
    private let apiService: APIServiceProtocol
    
    init(repository: DDayRepositoryProtocol, apiService: APIServiceProtocol) {
        self.repository = repository
        self.apiService = apiService
    }
    
    func loadDDayText(dDayItem: DDayItem) {
        Task {
            dDayText[dDayItem.pk] = await self.calculateDDay(from: dDayItem.date, type: dDayItem.type, isLunar: dDayItem.isLunarDate, startFromDayOne: dDayItem.startFromDayOne, repeatType: dDayItem.repeatType)
        }
    }
    
    func loadAllDDayText() {
        dDayItems.forEach { loadDDayText(dDayItem: $0) }
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
            adjustedDate = adjustDateForRepeatType(date: adjustedDate, repeatType: repeatType, calendar: calendar)
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
            return await apiService.fetchSolarDate(year: year, month: month, day: day)
        case .year:
            if let thisYearDate = await apiService.fetchSolarDate(year: currentYear, month: month, day: day), thisYearDate >= Date() {
                return thisYearDate
            }
            return await apiService.fetchSolarDate(year: currentYear + 1, month: month, day: day)
        case .month:
            return nil
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
    
    func updateLunarDate(lunarDate: Date) {
        Task {
            solarDate = await self.apiService.fetchSolarDate(lunarDate: lunarDate)
        }
    }
    
    func fetchDDay() {
        let realmDDays = repository.fetchItem()
        dDayItems = realmDDays.map { DDayItem(from: $0) }
        loadAllDDayText()
        updateSortedAndGroupedDDays()        
    }
    
    func addDDay(dDay: DDay, image: UIImage?) {
        NotificationManager.shared.scheduleNotification(for: dDay)

        if let image = image {
            ImageDocumentManager.shared.saveImageToDocument(image: image, fileName: "\(dDay.pk)")
        }
        
        self.repository.createItem(dDay)
        
        WidgetCenter.shared.reloadAllTimelines()
        
        fetchDDay()
    }
    
    func editDDay(dDayItem: DDayItem, newDDay: DDay, image: UIImage?) {
        guard let dDay = repository.fetchItem().first(where: { $0.pk.stringValue == dDayItem.pk }) else { return }
        
        NotificationManager.shared.removeNotification(for: dDay)
        NotificationManager.shared.scheduleNotification(for: newDDay)
        
        if ImageDocumentManager.shared.loadImageFromDocument(fileName: "\(dDay.pk)") != nil {
            ImageDocumentManager.shared.removeImageFromDocument(fileName: "\(dDay.pk)")
        }
        
        if let image = image {
            ImageDocumentManager.shared.saveImageToDocument(image: image, fileName: "\(newDDay.pk)")
        }
        
        self.repository.updateItem(dDay, title: newDDay.title, date: newDDay.date, isLunarDate: newDDay.isLunarDate, convertedSolarDateFromLunar: newDDay.convertedSolarDateFromLunar, startFromDayOne: newDDay.startFromDayOne, isRepeatOn: newDDay.isRepeatOn, repeatType: newDDay.repeatType)
        
        WidgetCenter.shared.reloadAllTimelines()
        
        fetchDDay()
    }
    
    func deleteDDay(dDayItem: DDayItem) {
        guard let dDay = repository.fetchItem().first(where: { $0.pk.stringValue == dDayItem.pk }) else { return }

        NotificationManager.shared.removeNotification(for: dDay)
                
        if ImageDocumentManager.shared.loadImageFromDocument(fileName: "\(dDay.pk)") != nil {
            ImageDocumentManager.shared.removeImageFromDocument(fileName: "\(dDay.pk)")
        }
        
        self.repository.deleteItem(dDay)
        
        WidgetCenter.shared.reloadAllTimelines()
        
        fetchDDay()
    }
    
    func updateSortedAndGroupedDDays() {
        if isGrouped {
            sortedAndGroupedDDays = groupAndSortDDays(dDayItems, by: selectedSortOption)
        } else {
            sortedDDays = sortDDays(dDayItems, by: selectedSortOption)
        }
    }
    
    func sortDDays(_ dDays: [DDayItem], by option: SortOption) -> [DDayItem] {
        switch option {
        case .creationDate:
            return dDays
        case .title:
            return dDays.sorted { $0.title < $1.title }
        case .dDay:
            return dDays.sorted { (dDay1, dDay2) -> Bool in
                compareDDayTexts(dDayText[dDay1.pk] ?? "", dDayText[dDay2.pk] ?? "")
            }
        }
    }
    
    func groupAndSortDDays(_ dDays: [DDayItem], by option: SortOption) -> [(key: DDayType, value: [DDayItem])] {
        let grouped = Dictionary(grouping: dDays, by: { $0.type })
        return grouped.mapValues { sortDDays($0, by: option) }
            .sorted { $0.key.rawValue < $1.key.rawValue }
    }
    
    private func compareDDayTexts(_ text1: String, _ text2: String) -> Bool {
        (text1.sortPriority, text1.absoluteValue, text1) <
        (text2.sortPriority, text2.absoluteValue, text2)
    }
}
