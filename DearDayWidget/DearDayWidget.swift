//
//  DearDayWidget.swift
//  DearDayWidget
//
//  Created by Jaehui Yu on 11/15/24.
//

import WidgetKit
import SwiftUI

// MARK: - Provider
struct Provider: AppIntentTimelineProvider {
    private var apiService = APIService()

    func placeholder(in context: Context) -> SelectedDDayEntry {
        let configuration = ConfigurationDearDayIntent()
        let currentDate = Date()
        let dDay = configuration.selectedDDay ?? configuration.defaultSelectedDDay()
        let dDayText = calculateDDaySync(from: dDay.date, type: dDay.type, isLunar: dDay.isLunarDate, startFromDayOne: dDay.startFromDayOne, repeatType: dDay.repeatType)
        return SelectedDDayEntry(date: currentDate, configuration: configuration, dDay: dDay, dDayText: dDayText)
    }

    func snapshot(for configuration: ConfigurationDearDayIntent, in context: Context) async -> SelectedDDayEntry {
        let currentDate = Date()
        let dDay = configuration.selectedDDay ?? configuration.defaultSelectedDDay()
        let dDayText = calculateDDaySync(from: dDay.date, type: dDay.type, isLunar: dDay.isLunarDate, startFromDayOne: dDay.startFromDayOne, repeatType: dDay.repeatType)
        return SelectedDDayEntry(date: currentDate, configuration: configuration, dDay: dDay, dDayText: dDayText)
    }

    func timeline(for configuration: ConfigurationDearDayIntent, in context: Context) async -> Timeline<SelectedDDayEntry> {
        let currentDate = Date()
        let dDay = configuration.selectedDDay ?? configuration.defaultSelectedDDay()
        let dDayText = calculateDDaySync(from: dDay.date, type: dDay.type, isLunar: dDay.isLunarDate, startFromDayOne: dDay.startFromDayOne, repeatType: dDay.repeatType)
        let entry = SelectedDDayEntry(date: currentDate, configuration: configuration, dDay: dDay, dDayText: dDayText)
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
            if let thisYearDate = apiService.fetchSolarDateSync(year: currentYear, month: month, day: day), 
                calendar.startOfDay(for: thisYearDate) >= calendar.startOfDay(for: Date()) {
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
    let configuration: ConfigurationDearDayIntent
    let dDay: DDayEntity
    let dDayText: String
}

// MARK: - EntryView
struct DearDayWidgetEntryView: View {
    @Environment(\.widgetFamily) var widgetFamily
    var entry: Provider.Entry
    
    var body: some View {
        switch widgetFamily {
        case .systemMedium:
            MediumWidgetView(entry: entry)
                .containerBackground(.clear, for: .widget)
        case .systemLarge:
            LargeWidgetView(entry: entry)
                .containerBackground(.clear, for: .widget)
        default:
            VStack(spacing: 10) {
                Text(entry.dDayText)
                    .foregroundStyle(.secondary)
                    .font(.title)
                Text(entry.dDay.title)
                    .foregroundStyle(.secondary)
                    .font(.caption)
                    .lineLimit(1)
                Text(DateFormatterManager.shared.formatDate(entry.dDay.date))
                    .foregroundStyle(.secondary.opacity(0.8))
                    .font(.caption)
            }
            .padding()
            .containerBackground(.clear, for: .widget)
        }
    }
}

struct MediumWidgetView: View {
    var entry: Provider.Entry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(entry.dDay.title)
                .asMainTitle()
            HStack {
                VStack(alignment: .leading) {
                    Text("\(DateFormatterManager.shared.formatDate(entry.dDay.date))\(entry.dDay.isLunarDate ? " (음력)" : "")")
                        .asMainDate()
                    if entry.dDay.repeatType != .none {
                        Text("[\(entry.dDay.repeatType.rawValue) 반복]")
                            .asMainRepeatType()
                    }
                }
                Spacer()
                Text(entry.dDayText)
                    .asMainDDayText()
            }
        }
        .padding()
    }
}

struct LargeWidgetView: View {
    var entry: Provider.Entry
    
    var body: some View {
        VStack {
            if let image = ImageDocumentManager.shared.loadImageFromDocument(fileName: "\(entry.dDay.id)") {
                GeometryReader { geometry in
                    Image(uiImage: resizeImage(image, targetSize: geometry.size))
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipped()
                }
            }
            VStack(alignment: .leading, spacing: 10) {
                Text(entry.dDay.title)
                    .asMainTitle()
                HStack {
                    VStack(alignment: .leading) {
                        Text("\(DateFormatterManager.shared.formatDate(entry.dDay.date))\(entry.dDay.isLunarDate ? " (음력)" : "")")
                            .asMainDate()
                        if entry.dDay.repeatType != .none {
                            Text("[\(entry.dDay.repeatType.rawValue) 반복]")
                                .asMainRepeatType()
                        }
                    }
                    Spacer()
                    Text(entry.dDayText)
                        .asMainDDayText()
                }
            }
            .padding()
        }
    }
    
    func resizeImage(_ image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size

        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height
        let scaleRatio = min(widthRatio, heightRatio)

        let newSize = CGSize(
            width: size.width * scaleRatio,
            height: size.height * scaleRatio
        )
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }

}

// MARK: - Widget
struct DearDayWidget: Widget {
    let kind: String = "DearDayIntentWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: ConfigurationDearDayIntent.self,
            provider: Provider()
        ) { entry in
            DearDayWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("D-Day Single Widget")
        .description("Displays a single D-Day.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
        .contentMarginsDisabled()
    }
}

