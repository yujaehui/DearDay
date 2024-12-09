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
import Combine

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
    private var cancellables: Set<AnyCancellable> = []
    private let repository: DDayRepositoryProtocol
    private let apiService: APIServiceProtocol
    
    // MARK: - Initialization
    init(repository: DDayRepositoryProtocol, apiService: APIServiceProtocol) {
        self.repository = repository
        self.apiService = apiService
        monitorNetworkConnectivity()
    }
    
    // MARK: - Public Methods
    func updateLunarDate(lunarDate: Date) {
        print(#function)
        
        Task {
            let response = await apiService.fetchSolarDate(lunarDate: lunarDate)
            solarDate = response.data
            errorMessage = response.error?.errorMessage
        }
    }
    
    func monitorLunarDateUpdates(isLunarDate: Binding<Bool>, selectedDate: Binding<Date>) {
        NetworkMonitor.shared.$isConnected
            .dropFirst()
            .removeDuplicates()
            .sink { [weak self] isConnected in
                guard let self = self else { return }
                if isConnected, isLunarDate.wrappedValue {
                    print("\(isConnected) 네트워크가 연결되었습니다. 데이터를 가져옵니다.")
                    self.updateLunarDate(lunarDate: selectedDate.wrappedValue)
                } else {
                    print("\(isConnected) 네트워크 연결이 없습니다. 연결 후 다시 시도해주세요.")
                    self.updateLunarDate(lunarDate: selectedDate.wrappedValue)
                }
            }
            .store(in: &cancellables)
    }
    
    func fetchDDay() {
        print(#function)
        
        let dDays = repository.fetchItem()
        dDayItems = dDays.map { DDayItem(from: $0) }
        
        Task {
            await fetchAllDDayData()
            await NotificationManager.shared.scheduleYearlyRepeatingLunarDdayNotification(for: dDayItems)
            NotificationManager.shared.scheduleHundredDayNotifications(for: dDayItems)
            NotificationManager.shared.scheduleYearlyNotifications(for: dDayItems)
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
    private func monitorNetworkConnectivity() {
        NetworkMonitor.shared.$isConnected
            .dropFirst() // 초기 값 무시
            .removeDuplicates() // 중복 상태 제거
            .sink { [weak self] isConnected in
                guard let self = self else { return }
                if isConnected {
                    print("\(isConnected) 네트워크가 연결되었습니다. 데이터를 가져옵니다. 위젯 타임라인을 갱신합니다.")
                    WidgetCenter.shared.reloadAllTimelines()
                    self.fetchDDay()
                } else {
                    print("\(isConnected) 네트워크 연결이 없습니다. 연결 후 다시 시도해주세요.")
                    self.fetchDDay()
                }
            }
            .store(in: &cancellables)
    }
    
    private func fetchAllDDayData() async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.loadAllImages() }
            group.addTask { await self.loadAllTexts() }
        }
        updateSortedAndGroupedDDays()
    }
    
    private func loadAllImages() {
        for dDayItem in dDayItems {
            dDayImage[dDayItem.pk] = ImageDocumentManager.shared.loadImageFromDocument(fileName: dDayItem.pk)
        }
    }
    
    private func loadAllTexts() async {
        for dDayItem in dDayItems {
            dDayText[dDayItem.pk] = await calculateDDay(from: dDayItem.date, type: dDayItem.type, isLunar: dDayItem.isLunarDate, startFromDayOne: dDayItem.startFromDayOne, repeatType: dDayItem.repeatType)
        }
    }
    
    private func calculateDDay(from date: Date, type: DDayType, isLunar: Bool, startFromDayOne: Bool, repeatType: RepeatType) async -> String {
        let calendar = Calendar.current
        var adjustedDate = date
        
        if isLunar {
            let result = await fetchClosestSolarDate(from: date, repeatType: repeatType)
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
    
    private func adjustDateForRepeatType(date: Date, repeatType: RepeatType, calendar: Calendar) -> Date {
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
    
    private func saveImageIfNeeded(for dDay: DDay, image: UIImage?) {
        guard let image = image else { return }
        ImageDocumentManager.shared.saveImageToDocument(image: image, fileName: dDay.pk.stringValue)
    }

    private func removeExistingImage(for dDay: DDay) {
        ImageDocumentManager.shared.removeImageFromDocument(fileName: dDay.pk.stringValue)
    }
}
