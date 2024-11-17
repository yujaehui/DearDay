//
//  DearDayWidget.swift
//  DearDayWidget
//
//  Created by Jaehui Yu on 11/15/24.
//

import WidgetKit
import SwiftUI
import RealmSwift


// MARK: - Provider
struct Provider: TimelineProvider {
    @ObservedResults(DDay.self) var dDays
    private var apiService = APIService()
    
    func placeholder(in context: Context) -> DDayEntry {
        DDayEntry(dDays: [DDayEntryItem(
            dDay: DDay(type: .dDay, title: "Placeholder D-Day", date: Date(), isLunarDate: false, convertedSolarDateFromLunar: nil, startFromDayOne: false, repeatType: .none),
            dDayText: "")])
    }
    
    func getSnapshot(in context: Context, completion: @escaping (DDayEntry) -> Void) {
        let entry = DDayEntry(dDays: fetchDDayEntries())
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<DDayEntry>) -> Void) {
        let currentDate = Date()
        let entry = DDayEntry(dDays: fetchDDayEntries())
        
        var nextUpdate = Calendar.current.startOfDay(for: currentDate)
        nextUpdate = Calendar.current.date(byAdding: .day, value: 1, to: nextUpdate)!
        
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

extension Provider {
    private func fetchDDayEntries() -> [DDayEntryItem] {
        guard !dDays.isEmpty else {
            return [DDayEntryItem(
                dDay: DDay(type: .dDay, title: "No Upcoming D-Days", date: Date(), isLunarDate: false, convertedSolarDateFromLunar: nil, startFromDayOne: false, repeatType: .none),
                dDayText: "")]
        }
        
        return dDays.map { dDay in
            let dDayText = calculateDDaySync(
                from: dDay.date,
                type: dDay.type,
                isLunar: dDay.isLunarDate,
                startFromDayOne: dDay.startFromDayOne,
                repeatType: dDay.repeatType
            )
            return DDayEntryItem(dDay: dDay, dDayText: dDayText)
        }
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

// MARK: - Entry
struct DDayEntry: TimelineEntry {
    let date = Date()
    let dDays: [DDayEntryItem]
}

struct DDayEntryItem: Identifiable {
    let id = UUID()
    let dDay: DDay
    let dDayText: String
}

// MARK: - EntryView
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
        case .systemLarge:
            LargeWidgetView(entry: entry)
        default:
            VStack(spacing: 10) {
                Text(entry.dDays[0].dDayText)
                    .foregroundColor(.gray)
                    .font(.title)
                    .fontWeight(.bold)
                Text(entry.dDays[0].dDay.title)
                    .foregroundColor(.gray)
                    .font(.caption)
                    .lineLimit(1)
                Text(DateFormatterManager.shared.formatDate(entry.dDays[0].dDay.date))
                    .foregroundColor(.gray.opacity(0.8))
                    .font(.caption)
            }
        }
    }
}

struct DearDayWidgetListVersionEntryView: View {
    @Environment(\.widgetFamily) var widgetFamily
    var entry: Provider.Entry
    
    var body: some View {
        switch widgetFamily {
        case .systemMedium:
            ListMediumWidgetView(entry: entry)
        case .systemLarge:
            ListLargeWidgetView(entry: entry)
        default:
            VStack(spacing: 10) {
                Text(entry.dDays[0].dDayText)
                    .foregroundColor(.gray)
                    .font(.title)
                    .fontWeight(.bold)
                Text(entry.dDays[0].dDay.title)
                    .foregroundColor(.gray)
                    .font(.caption)
                    .lineLimit(1)
                Text(DateFormatterManager.shared.formatDate(entry.dDays[0].dDay.date))
                    .foregroundColor(.gray.opacity(0.8))
                    .font(.caption)
            }
        }
    }
}

struct AccessoryCircularView: View {
    var entry: Provider.Entry
    
    var body: some View {
        ZStack {
            AccessoryWidgetBackground()
            Text(entry.dDays[0].dDayText)
        }
    }
}

struct AccessoryRectangularView: View {
    var entry: Provider.Entry
    
    var body: some View {
        VStack(spacing: 5) {
            Text(entry.dDays[0].dDay.title)
            Text(entry.dDays[0].dDayText)
                .font(.system(size: 25, weight: .bold))
        }
    }
}

struct AccessoryInlineView: View {
    var entry: Provider.Entry
    
    var body: some View {
        Text("\(entry.dDays[0].dDay.title) \(entry.dDays[0].dDayText)")
    }
}

struct MediumWidgetView: View {
    var entry: Provider.Entry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(entry.dDays[0].dDay.title)
                .lineLimit(1)
                .foregroundColor(.gray)
                .font(.title3)
            HStack {
                VStack(alignment: .leading) {
                    Text("\(DateFormatterManager.shared.formatDate(entry.dDays[0].dDay.date))\(entry.dDays[0].dDay.isLunarDate ? " (음력)" : "")")
                        .foregroundColor(.gray.opacity(0.8))
                        .font(.callout)
                    if entry.dDays[0].dDay.repeatType != .none {
                        Text("[\(entry.dDays[0].dDay.repeatType.rawValue) 반복]")
                            .foregroundColor(.gray.opacity(0.8))
                            .font(.caption)
                    }
                }
                Spacer()
                Text(entry.dDays[0].dDayText)
                    .foregroundColor(.gray)
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }
        }
        .padding()
    }
}

struct LargeWidgetView: View {
    var entry: Provider.Entry
    
    var body: some View {
        VStack {
            if let image = ImageDocumentManager.shared.loadImageFromDocument(fileName: "\(entry.dDays[0].dDay.pk)") {
                GeometryReader { geometry in
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipped()
                }
            }
            
            HStack {
                VStack(alignment: .leading) {
                    Text(entry.dDays[0].dDay.title)
                        .lineLimit(1)
                        .foregroundColor(.gray)
                        .font(.title3)
                    Text("\(DateFormatterManager.shared.formatDate(entry.dDays[0].dDay.date))\(entry.dDays[0].dDay.isLunarDate ? " (음력)" : "")")
                        .foregroundColor(.gray.opacity(0.8))
                        .font(.callout)
                    if entry.dDays[0].dDay.repeatType != .none {
                        Text("[\(entry.dDays[0].dDay.repeatType.rawValue) 반복]")
                            .foregroundColor(.gray.opacity(0.8))
                            .font(.caption)
                    }
                }
                Spacer()
                Text(entry.dDays[0].dDayText)
                    .foregroundColor(.gray)
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }
            .padding()
        }
    }
}


struct ListMediumWidgetView: View {
    var entry: Provider.Entry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(entry.dDays.prefix(3)) { item in
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

struct ListLargeWidgetView: View {
    var entry: Provider.Entry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(entry.dDays.prefix(5)) { item in
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

// MARK: - Widget
struct DearDayWidget: Widget {
    let kind: String = "DearDayWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            DearDayWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Single D-Day Widget")
        .description("Displays a selected D-Day.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge, .accessoryCircular, .accessoryRectangular, .accessoryInline])
        .contentMarginsDisabled()
    }
}

struct ListDearDayWidget: Widget {
    let kind: String = "ListDearDayWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            DearDayWidgetListVersionEntryView(entry: entry)
        }
        .configurationDisplayName("D-Day List Widget")
        .description("Displays a list of D-Days.")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

