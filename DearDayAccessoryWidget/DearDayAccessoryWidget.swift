//
//  DearDayAccessoryWidget.swift
//  DearDayAccessoryWidget
//
//  Created by Jaehui Yu on 12/4/24.
//

import WidgetKit
import SwiftUI
import Realm

struct Provider: TimelineProvider {
    private var repository = DDayRepository()
    private var apiService = APIService()
    
    func placeholder(in context: Context) -> DDayEntry {
        fetchClosestDDayEntry()
    }
    
    func getSnapshot(in context: Context, completion: @escaping (DDayEntry) -> Void) {
        let entry = fetchClosestDDayEntry()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<DDayEntry>) -> Void) {
        let currentDate = Date()
        let entry = fetchClosestDDayEntry()
        let nextUpdate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

extension Provider {
    private func fetchClosestDDayEntry() -> DDayEntry {
        let dDays = repository.fetchItem()
        
        guard let firstDDay = dDays.first else {
            return DDayEntry(title: "No Upcoming D-Days", date: Date(), dDayText: "")
        }
        
        let dDayText = calculateDDaySync(from: firstDDay.date, type: firstDDay.type, isLunar: firstDDay.isLunarDate, startFromDayOne: firstDDay.startFromDayOne, repeatType: firstDDay.repeatType)
        
        return DDayEntry(title: firstDDay.title, date: firstDDay.date, dDayText: dDayText)
    }
    
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
            adjustedDate = adjustForRepeatingDateIfNeeded(date: adjustedDate, repeatType: repeatType, calendar: calendar)
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

struct DDayEntry: TimelineEntry {
    let title: String
    let date: Date
    let dDayText: String
}

struct DearDayAccessoryWidgetEntryView: View {
    @Environment(\.widgetFamily) var widgetFamily
    var entry: Provider.Entry
    
    var body: some View {
        switch widgetFamily {
        case .accessoryCircular:
            AccessoryCircularView(entry: entry)
                .containerBackground(.clear, for: .widget)
        case .accessoryRectangular:
            AccessoryRectangularView(entry: entry)
                .containerBackground(.clear, for: .widget)
        case .accessoryInline:
            AccessoryInlineView(entry: entry)
                .containerBackground(.clear, for: .widget)
        default:
            Text("")
        }
    }
}

struct AccessoryCircularView: View {
    var entry: Provider.Entry
    
    var body: some View {
        ZStack {
            AccessoryWidgetBackground()
            Text(entry.dDayText)
        }
    }
}

struct AccessoryRectangularView: View {
    var entry: Provider.Entry
    
    var body: some View {
        VStack(spacing: 5) {
            Text(entry.title)
            Text(entry.dDayText)
                .font(.system(size: 25))
        }
    }
}

struct AccessoryInlineView: View {
    var entry: Provider.Entry
    
    var body: some View {
        Text("\(entry.title) \(entry.dDayText)")
    }
}

struct DearDayAccessoryWidget: Widget {
    let kind: String = "DearDayAccessoryWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            DearDayAccessoryWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("D-Day Accessory Widget")
        .description("Displays a accessory D-Day.")
        .supportedFamilies([.accessoryCircular, .accessoryRectangular, .accessoryInline])
    }
}
