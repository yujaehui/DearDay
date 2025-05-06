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
import os

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
    private let logger = OSLog(subsystem: "com.dearday.debug", category: "async/await")
    
    // MARK: - Published Properties
    @Published var dDayItems: [DDayItem] = []
    @Published var dDayImage: [String: UIImage?] = [:]
    @Published var dDayText: [String: String] = [:]
    @Published var solarDate: Date?
    @Published var errorMessage: String?
    
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
    
    @Published private(set) var sortedAndGroupedDDayItems: [(key: DDayType, value: [DDayItem])] = []
    @Published private(set) var sortedDDayItems: [DDayItem] = []
    
    // MARK: - Private Properties
    private let repository: DDayRepositoryProtocol
    private let apiService: APIServiceProtocol
    
    // MARK: - Initialization
    init(repository: DDayRepositoryProtocol, apiService: APIServiceProtocol) {
        self.repository = repository
        self.apiService = apiService
        
        WidgetCenter.shared.reloadAllTimelines()
        self.fetchDDay()
    }
    
    // MARK: - Public Methods
    func updateLunarDate(lunarDate: Date) {
        Task {
            let response = await apiService.fetchSolarDate(lunarDate: lunarDate)
            solarDate = response.data
            errorMessage = response.error?.errorMessage
        }
    }

    func fetchDDay() {
        print("♻️FETCH♻️")
        
        let dDays = repository.fetchItem()
        dDayItems = dDays.map { DDayItem(from: $0) }
        
        DDayAppGroupStorage.save(dDayItems)
        
        Task {
            async let fetchData: () = fetchAllDDayData()
            async let yearlyLunarNotifications: () = NotificationManager.shared.scheduleYearlyRepeatingLunarDdayNotification(for: dDayItems)
            async let hundredDayNotifications: () = NotificationManager.shared.scheduleHundredDayNotifications(for: dDayItems)
            async let yearlyNotifications: () = NotificationManager.shared.scheduleYearlyNotifications(for: dDayItems)

            // 모든 비동기 작업이 끝날 때까지 대기
            await fetchData
            await yearlyLunarNotifications
            await hundredDayNotifications
            await yearlyNotifications
            
            // 모든 데이터 패치 후 정렬 및 그룹화 실행
            updateSortedAndGroupedDDays()
        }
    }

    func addDDay(dDay: DDay, image: UIImage?) {
        NotificationManager.shared.scheduleNotification(for: dDay, updatedDDay: dDay)           // 알림 추가
        saveImageIfNeeded(for: dDay, image: image)                                              // 이미지 추가
        self.repository.createItem(dDay)                                                        // 데이터베이스 추가
        WidgetCenter.shared.reloadAllTimelines()                                                // 위젯 동기화
        fetchDDay()
    }
    
    func editDDay(dDayItem: DDayItem, updatedDDay: DDay, image: UIImage?) {
        guard let dDay = repository.fetchItem().first(where: { $0.pk.stringValue == dDayItem.pk }) else { return }
        NotificationManager.shared.removeAllNotificationsForDDay(for: dDay)                     // 기존 알림 제거
        NotificationManager.shared.scheduleNotification(for: dDay, updatedDDay: updatedDDay)    // 새로운 알림 추가
        removeExistingImage(for: dDay)                                                          // 기존 이미지 제거
        saveImageIfNeeded(for: dDay, image: image)                                              // 새로운 이미지 추가
        self.repository.updateItem(dDay, updatedItem: updatedDDay)                              // 데이터베이스 변경
        WidgetCenter.shared.reloadAllTimelines()                                                // 위젯 동기화
        fetchDDay()
    }
    
    func deleteDDay(dDayItem: DDayItem) {
        guard let dDay = repository.fetchItem().first(where: { $0.pk.stringValue == dDayItem.pk }) else { return }
        NotificationManager.shared.removeAllNotificationsForDDay(for: dDay)                     // 알림 제거
        removeExistingImage(for: dDay)                                                          // 이미지 제거
        self.repository.deleteItem(dDay)                                                        // 데이터베이스 제거
        WidgetCenter.shared.reloadAllTimelines()                                                // 위젯 동기화
        fetchDDay()
    }
    
    func updateSortedAndGroupedDDays() {
        if isGrouped {
            sortedAndGroupedDDayItems = groupAndSortDDays(dDayItems, by: selectedSortOption)
        } else {
            sortedDDayItems = sortDDays(dDayItems, by: selectedSortOption)
        }
    }
    
    // MARK: - Private Methods
    private func fetchAllDDayData() async {
        os_signpost(.begin, log: logger, name: "fetchAllDDayData")
        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                os_signpost(.begin, log: self.logger, name: "loadAllImages")
                await self.loadAllImages()
                os_signpost(.end, log: self.logger, name: "loadAllImages")
            }
            group.addTask {
                os_signpost(.begin, log: self.logger, name: "loadAllTexts")
                await self.loadAllTexts()
                os_signpost(.end, log: self.logger, name: "loadAllTexts")
            }
        }
        os_signpost(.end, log: logger, name: "fetchAllDDayData")
    }
    
    private func loadAllImages() async {
        await withTaskGroup(of: (String, UIImage?)?.self) { group in
            for dDayItem in dDayItems {
                group.addTask {
                    let image = await ImageDocumentManager.shared.loadImageFromDocument(fileName: dDayItem.pk)
                    return (dDayItem.pk, image)
                }
            }
            
            var newDDayImage: [String : UIImage?] = [:]

            for await result in group {
                if let (pk, image) = result {
                    newDDayImage[pk] = image
                }
            }
            
            await MainActor.run {
                dDayImage = newDDayImage
            }
        }
    }
    
    private func loadAllTexts() async {
        await withTaskGroup(of: (String, String)?.self) { group in
            for dDayItem in dDayItems {
                group.addTask {
                    let text = await self.calculateDDay(dDayItem)
                    return (dDayItem.pk, text)
                }
            }

            var newDDayText: [String: String] = [:]
            
            for await result in group {
                if let (pk, text) = result {
                    newDDayText[pk] = text
                }
            }

            await MainActor.run {
                dDayText = newDDayText
            }
        }
    }
    
//    private func loadAllImages() async {
//        for dDayItem in dDayItems {
//            dDayImage[dDayItem.pk] = await ImageDocumentManager.shared.loadImageFromDocument(fileName: dDayItem.pk)
//        }
//    }
    
//    private func loadAllTexts() async {
//        for dDayItem in dDayItems {
//            dDayText[dDayItem.pk] = await calculateDDay(dDayItem)
//        }
//    }
    
    // MARK: - 디데이 계산 관련 메서드
    private func calculateDDay(_ dDayItem: DDayItem) async -> String {
        //네트워크 연결 상태 불안정 - 테스트
        //try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        let calendar = Calendar.current
        var adjustedDate = dDayItem.date
        
        if dDayItem.isLunarDate {
            let result = await fetchClosestSolarDate(from: dDayItem.date, repeatType: dDayItem.repeatType)
            if let closestLunarDate = result.0 {
                adjustedDate = closestLunarDate
            } else if let errorMessage = result.1 {
                return errorMessage
            }
        }
        
        if !dDayItem.isLunarDate && adjustedDate < Date() {
            adjustedDate = await adjustDateForRepeatType(date: adjustedDate, repeatType: dDayItem.repeatType, calendar: calendar)
        }
                
        return DateFormatterManager.shared.calculateDDayString(from: adjustedDate, type: dDayItem.type, startFromDayOne: dDayItem.startFromDayOne, calendar: calendar)
    }
    
    private func fetchClosestSolarDate(from date: Date, repeatType: RepeatType) async -> (Date?, String?) {
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        
        switch repeatType {
        case .none:
            let response = await apiService.fetchSolarDate(year: year, month: month, day: day)
            return (response.data, response.error?.shortErrorMessage)
        case .year:
            let currentYearResponse = await apiService.fetchSolarDate(year: currentYear, month: month, day: day)
            if let thisYearDate = currentYearResponse.data,
               calendar.startOfDay(for: thisYearDate) >= calendar.startOfDay(for: Date()) {
                return (thisYearDate, nil)
            }
            
            let nextYearResponse = await apiService.fetchSolarDate(year: currentYear + 1, month: month, day: day)
            return (nextYearResponse.data, nextYearResponse.error?.shortErrorMessage)
        case .month:
            return (nil, nil)
        }
    }
    
    private func adjustDateForRepeatType(date: Date, repeatType: RepeatType, calendar: Calendar) async -> Date {
        var adjustedDate = date
        
        switch repeatType {
        case .none: break
        case .year:
            while calendar.startOfDay(for: adjustedDate) < calendar.startOfDay(for: Date()) {
                if let newDate = calendar.date(byAdding: .year, value: 1, to: adjustedDate) {
                    adjustedDate = newDate
                }
            }
        case .month:
            while calendar.startOfDay(for: adjustedDate) < calendar.startOfDay(for: Date()) {
                if let newDate = calendar.date(byAdding: .month, value: 1, to: adjustedDate) {
                    adjustedDate = newDate
                }
            }
        }
        return adjustedDate
    }
    
    
    // MARK: -  정렬 및 그룹화 관련 메서드
    private func sortDDays(_ dDays: [DDayItem], by option: SortOption) -> [DDayItem] {
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
    
    private func groupAndSortDDays(_ dDays: [DDayItem], by option: SortOption) -> [(key: DDayType, value: [DDayItem])] {
        let grouped = Dictionary(grouping: dDays, by: { $0.type })
        return grouped
            .mapValues { sortDDays($0, by: option) }
            .sorted { $0.key.rawValue < $1.key.rawValue }
    }
    
    private func compareDDayTexts(_ text1: String, _ text2: String) -> Bool {
        return (text1.sortPriority, text1.absoluteValue, text1) < (text2.sortPriority, text2.absoluteValue, text2)
    }
    
    // MARK: - 이미지 처리 관련 메서드
    private func saveImageIfNeeded(for dDay: DDay, image: UIImage?) {
        guard let image = image else { return }
        ImageDocumentManager.shared.saveImageToDocument(image: image, fileName: dDay.pk.stringValue)
    }

    private func removeExistingImage(for dDay: DDay) {
        ImageDocumentManager.shared.removeImageFromDocument(fileName: dDay.pk.stringValue)
    }
}
