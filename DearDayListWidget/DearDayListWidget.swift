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
        let nextUpdate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!
        return Timeline(entries: [entry], policy: .after(nextUpdate))
    }
}


extension Provider {
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
        case .systemLarge:
            LargeListWidgetView(entry: entry)
        default:
            Text(entry.selectedDDays[0].dDayText)
        }
    }
}

struct MediumListWidgetView: View {
    var entry: Provider.Entry
    
    var body: some View {
        if entry.selectedDDays.isEmpty {
            VStack(spacing: 10) {
                Image(systemName: "plus")
                    .foregroundStyle(.gray.opacity(0.8))
                    .font(.title)
                Text("위젯 편집 > 디데이 목록을 설정해주세요.")
                    .foregroundStyle(.gray)
                    .font(.caption)
            }
        } else {
            VStack(alignment: .leading, spacing: 10) {
                ForEach(entry.selectedDDays.prefix(3)) { item in
                    HStack(spacing: 10) {
                        Text(item.dDay.title)
                            .foregroundStyle(.gray)
                            .font(.callout)
                            .lineLimit(1)
                        Spacer()
                        Text(item.dDayText)
                            .foregroundStyle(.gray)
                            .font(.title3)
                            .fontWeight(.bold)
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
                    .foregroundStyle(.gray.opacity(0.8))
                    .font(.title)
                Text("위젯 편집 > 디데이 목록을 설정해주세요.")
                    .foregroundStyle(.gray)
                    .font(.caption)
            }
        } else {
            VStack(alignment: .leading, spacing: 10) {
                ForEach(entry.selectedDDays.prefix(5)) { item in
                    HStack(spacing: 10) {
                        Text(item.dDay.title)
                            .foregroundStyle(.gray)
                            .font(.callout)
                            .lineLimit(1)
                        Spacer()
                        VStack(alignment: .trailing) {
                            Text(item.dDayText)
                                .foregroundColor(.gray)
                                .font(.title3)
                                .fontWeight(.bold)
                            Text("\(DateFormatterManager.shared.formatDate(item.dDay.date))\(item.dDay.isLunarDate ? " (음력)" : "")")
                                .foregroundColor(.gray.opacity(0.8))
                                .font(.caption)
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

