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
    var startFromDayOne: Bool = false // type이 numberOfDays의 경우에만 설정 필요
    var repeatType: RepeatType = .none // type이 dDay의 경우에만 설정 필요
    
}

var sampleDDays: [DDay] = [
    DDay(type: .numberOfDays, title: "COMET", date: Calendar.current.date(from: DateComponents(year: 2024, month: 9, day: 22))!, startFromDayOne: true),
    DDay(type: .dDay, title: "ChristmasChristmasChristmasChristmas", date: Calendar.current.date(from: DateComponents(year: 2024, month: 12, day: 25))!, repeatType: .year),
    DDay(type: .dDay, title: "🩶.Birthday", date: Calendar.current.date(from: DateComponents(year: 2023, month: 11, day: 10))!, repeatType: .year),
    DDay(type: .dDay, title: "New Year", date: Calendar.current.date(from: DateComponents(year: 2025, month: 1, day: 1))!),
    DDay(type: .dDay, title: "100DAYS", date: Calendar.current.date(from: DateComponents(year: 2024, month: 12, day: 30))!),
    DDay(type: .dDay, title: "payday", date: Calendar.current.date(from: DateComponents(year: 2024, month: 9, day: 30))!, repeatType: .month)
]
