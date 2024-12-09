//
//  DearDayListWidget.swift
//  DearDayListWidget
//
//  Created by Jaehui Yu on 11/27/24.
//

import WidgetKit
import SwiftUI

// MARK: - Provider
struct Provider: AppIntentTimelineProvider {
    private var apiService = APIService()

    func placeholder(in context: Context) -> SelectedDDayEntry {
        SelectedDDayEntry(date: Date(), configuration: ConfigurationDearDayListIntent(), selectedDDays: [])
    }

    func snapshot(for configuration: ConfigurationDearDayListIntent, in context: Context) async -> SelectedDDayEntry {
        let currentDate = Date()
        let dDays = configuration.isCustomSelectionEnabled
            ? (configuration.selectedDDays ?? [])
            : configuration.defaultSelectedDDays()
        let selectedDDays = dDays.map { dDay in
            SelectedDDay(dDay: dDay, dDayText: calculateDDaySync(from: dDay.date, type: dDay.type, isLunar: dDay.isLunarDate, startFromDayOne: dDay.startFromDayOne, repeatType: dDay.repeatType))
        }
        return SelectedDDayEntry(date: currentDate, configuration: configuration, selectedDDays: selectedDDays)
    }

    func timeline(for configuration: ConfigurationDearDayListIntent, in context: Context) async -> Timeline<SelectedDDayEntry> {
        let currentDate = Date()
        let dDays = configuration.isCustomSelectionEnabled
            ? (configuration.selectedDDays ?? [])
            : configuration.defaultSelectedDDays()
        let selectedDDays = dDays.map { dDay in
            SelectedDDay(dDay: dDay, dDayText: calculateDDaySync(from: dDay.date, type: dDay.type, isLunar: dDay.isLunarDate, startFromDayOne: dDay.startFromDayOne, repeatType: dDay.repeatType))
        }
        let entry = SelectedDDayEntry(date: currentDate, configuration: configuration, selectedDDays: selectedDDays)
        
        // 자정 시간 계산
        let calendar = Calendar.current
        let nextUpdate = calendar.nextDate(after: currentDate, matching: DateComponents(hour: 0, minute: 0), matchingPolicy: .strict)!
        
        // 타임라인 생성
        return Timeline(entries: [entry], policy: .after(nextUpdate))
    }
}


extension Provider {
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

// MARK: - Entry
struct SelectedDDayEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationDearDayListIntent
    let selectedDDays: [SelectedDDay]
}

struct SelectedDDay: Identifiable {
    let id = UUID()
    let dDay: DDayEntity
    let dDayText: String
}

// MARK: - EntryView
struct DearDayListWidgetEntryView: View {
    @Environment(\.widgetFamily) var widgetFamily
    var entry: Provider.Entry
    
    var body: some View {
        switch widgetFamily {
        case .systemMedium:
            MediumListWidgetView(entry: entry)
                .containerBackground(.clear, for: .widget)
        case .systemLarge:
            LargeListWidgetView(entry: entry)
                .containerBackground(.clear, for: .widget)
        default:
            Text("")
        }
    }
}

struct MediumListWidgetView: View {
    var entry: Provider.Entry
    
    var body: some View {
        if entry.selectedDDays.isEmpty {
            VStack(spacing: 10) {
                Image(systemName: "plus")
                    .foregroundStyle(.secondary.opacity(0.8))
                    .font(.title)
                Text("위젯 편집 > 디데이 목록을 설정해주세요.")
                    .foregroundStyle(.secondary)
                    .font(.caption)
            }
        } else {
            VStack(alignment: .leading, spacing: 10) {
                ForEach(entry.selectedDDays.prefix(3)) { item in
                    HStack(spacing: 10) {
                        Text(item.dDay.title)
                            .asRowTitle()
                        Spacer()
                        Text(item.dDayText)
                            .asRowDDayText()
                    }
                    Divider()
                }
            }
            .padding()
        }
    }
}

struct LargeListWidgetView: View {
    var entry: Provider.Entry
    
    var body: some View {
        if entry.selectedDDays.isEmpty {
            VStack(spacing: 10) {
                Image(systemName: "plus")
                    .foregroundStyle(.secondary.opacity(0.8))
                    .font(.title)
                Text("위젯 편집 > 디데이 목록을 설정해주세요.")
                    .foregroundStyle(.secondary)
                    .font(.caption)
            }
        } else {
            VStack(alignment: .leading, spacing: 10) {
                ForEach(entry.selectedDDays.prefix(5)) { item in
                    HStack(spacing: 10) {
                        Text(item.dDay.title)
                            .asRowTitle()
                        Spacer()
                        VStack(alignment: .trailing) {
                            Text(item.dDayText)
                                .asRowDDayText()
                            Text("\(DateFormatterManager.shared.formatDate(item.dDay.date))\(item.dDay.isLunarDate ? " (음력)" : "")")
                                .asRowDate()
                        }
                    }
                    Divider()
                }
            }
            .padding()
        }
    }
}

// MARK: - Widget
struct DearDayListWidget: Widget {
    let kind: String = "DearDayWidget"
    
    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: ConfigurationDearDayListIntent.self,
            provider: Provider()
        ) { entry in
            DearDayListWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("D-Day List Widget")
        .description("Displays a list of D-Days.")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

