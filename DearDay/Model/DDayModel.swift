//
//  DDayModel.swift
//  DearDay
//
//  Created by Jaehui Yu on 10/15/24.
//

import Foundation

struct DDay: Identifiable {
    var id = UUID().uuidString
    var title: String
    var date: Date
    var startFromDayOne: Bool
}

var sampleDDays: [DDay] = [
    DDay(title: "COMET", date: Calendar.current.date(from: DateComponents(year: 2024, month: 9, day: 22))!, startFromDayOne: true),
    DDay(title: "ChristmasChristmasChristmasChristmas", date: Calendar.current.date(from: DateComponents(year: 2024, month: 12, day: 25))!, startFromDayOne: false),
    DDay(title: "🩶.Birthday", date: Calendar.current.date(from: DateComponents(year: 2024, month: 11, day: 10))!, startFromDayOne: false),
    DDay(title: "New Year", date: Calendar.current.date(from: DateComponents(year: 2025, month: 1, day: 1))!, startFromDayOne: false),
    DDay(title: "100DAYS", date: Calendar.current.date(from: DateComponents(year: 2024, month: 12, day: 30))!, startFromDayOne: false),
]
