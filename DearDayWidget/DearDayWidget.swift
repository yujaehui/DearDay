//
//  DearDayWidget.swift
//  DearDayWidget
//
//  Created by Jaehui Yu on 11/15/24.
//

import WidgetKit
import SwiftUI
import RealmSwift

struct Provider: TimelineProvider {
    @ObservedResults(DDay.self) var dDays
    private var apiService = APIService()
    
    func placeholder(in context: Context) -> DDayEntry {
        DDayEntry(title: "Placeholder D-Day", date: Date(), dDayText: "D-DAY")
    }

    func getSnapshot(in context: Context, completion: @escaping (DDayEntry) -> Void) {
        let entry = fetchClosestDDayEntry()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<DDayEntry>) -> Void) {
        let currentDate = Date()
        let entry = fetchClosestDDayEntry()
        
        var nextUpdate = Calendar.current.startOfDay(for: currentDate)
        nextUpdate = Calendar.current.date(byAdding: .day, value: 1, to: nextUpdate)!
        
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    private func fetchClosestDDayEntry() -> DDayEntry {
        RealmConfiguration.shared.configureRealm()
        
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

struct DearDayWidgetEntryView: View {
    @Environment(\.widgetFamily) var widgetFamily
    var entry: Provider.Entry

    var body: some View {
        switch widgetFamily {
        case .accessoryCircular:
            AccessoryCircularView(entry: entry)
        case .accessoryRectangular:
            AccessoryRectangularView(entry: entry)
        case .accessoryInline:
            AccessoryInlineView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        default:
            VStack {
                Text(entry.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                Text(entry.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct AccessoryCircularView: View {
    var entry: Provider.Entry

    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 1)
            Text(entry.title)
                .font(.caption2)
        }
    }
}

struct AccessoryRectangularView: View {
    var entry: Provider.Entry

    var body: some View {
        VStack(alignment: .leading) {
            Text(entry.title)
                .font(.caption)
                .bold()
            Text(entry.dDayText)
                .font(.caption2)
        }
    }
}

struct AccessoryInlineView: View {
    var entry: Provider.Entry

    var body: some View {
        Text("\(entry.title): \(entry.dDayText)")
    }
}

struct MediumWidgetView: View {
    var entry: Provider.Entry

    var body: some View {
        VStack {
            Text(entry.title)
                .font(.headline)
                .foregroundColor(.primary)
            Text(entry.dDayText)
                .font(.title)
                .bold()
                .foregroundColor(.accentColor)
            Text(entry.date, style: .date)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

struct DearDayWidget: Widget {
    let kind: String = "DearDayWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            DearDayWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Dear Day Widget")
        .description("Shows the closest D-Day.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryCircular, .accessoryRectangular, .accessoryInline])
    }
}
