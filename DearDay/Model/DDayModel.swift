//
//  DDayModel.swift
//  DearDay
//
//  Created by Jaehui Yu on 10/15/24.
//

import Foundation

enum DDayType: String {
    case dDay = "D-DAY"
    case numberOfDays = "날짜 수"
}

enum RepeatType: String {
    case none
    case month = "매월"
    case year = "매년"
}

struct DDay: Identifiable {
    var id = UUID().uuidString
    var type: DDayType
    var title: String
    var date: Date
    var isLunarDate: Bool
    var startFromDayOne: Bool = false // type이 numberOfDays의 경우에만 설정 필요
    var repeatType: RepeatType = .none // type이 dDay의 경우에만 설정 필요
}

var sampleDDays: [DDay] = [
    DDay(type: .numberOfDays, title: "COMET", date: Calendar.current.date(from: DateComponents(year: 2024, month: 9, day: 22))!, isLunarDate: false, startFromDayOne: true),
    DDay(type: .dDay, title: "ChristmasChristmasChristmasChristmas", date: Calendar.current.date(from: DateComponents(year: 2024, month: 12, day: 25))!, isLunarDate: false, repeatType: .year),
    DDay(type: .dDay, title: "🩶.Birthday", date: Calendar.current.date(from: DateComponents(year: 2023, month: 11, day: 10))!, isLunarDate: false, repeatType: .year),
    DDay(type: .dDay, title: "New Year", date: Calendar.current.date(from: DateComponents(year: 2025, month: 1, day: 1))!, isLunarDate: false),
    DDay(type: .dDay, title: "100DAYS", date: Calendar.current.date(from: DateComponents(year: 2024, month: 12, day: 30))!, isLunarDate: false),
    DDay(type: .dDay, title: "payday", date: Calendar.current.date(from: DateComponents(year: 2024, month: 9, day: 30))!, isLunarDate: false, repeatType: .month),
    DDay(type: .dDay, title: "Mommy BirthDay", date: Calendar.current.date(from: DateComponents(year: 1971, month: 9, day: 11))!, isLunarDate: true, repeatType: .year)
]
