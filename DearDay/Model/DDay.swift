//
//  DDay.swift
//  DearDay
//
//  Created by Jaehui Yu on 10/31/24.
//

import Foundation
import RealmSwift

enum DDayType: String, CaseIterable, PersistableEnum {
    case dDay = "D-DAY"
    case numberOfDays = "날짜 수"
}

enum RepeatType: String, CaseIterable, PersistableEnum {
    case none
    case month = "매월"
    case year = "매년"
}

final class DDay: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var pk: ObjectId
    @Persisted var type: DDayType
    @Persisted var title: String
    @Persisted var date: Date
    @Persisted var isLunarDate: Bool
    @Persisted var convertedSolarDateFromLunar: Date?
    @Persisted var startFromDayOne: Bool
    @Persisted var isRepeatOn: Bool
    @Persisted var repeatType: RepeatType = .none
        
    convenience init(type: DDayType, 
                     title: String,
                     date: Date,
                     isLunarDate: Bool,
                     convertedSolarDateFromLunar: Date?,
                     startFromDayOne: Bool,
                     isRepeatOn: Bool,
                     repeatType: RepeatType) {
        self.init()
        self.type = type
        self.title = title
        self.date = date
        self.isLunarDate = isLunarDate
        self.convertedSolarDateFromLunar = convertedSolarDateFromLunar
        self.startFromDayOne = type == .dDay ? false : true
        self.isRepeatOn = repeatType == .none ? false : true
        self.repeatType = repeatType
    }
}

struct DDayItem {
    let pk: String
    let type: DDayType
    let title: String
    let date: Date
    let isLunarDate: Bool
    let convertedSolarDateFromLunar: Date?
    let startFromDayOne: Bool
    let isRepeatOn: Bool
    let repeatType: RepeatType
    
    init(from dDay: DDay) {
        self.pk = dDay.pk.stringValue
        self.type = dDay.type
        self.title = dDay.title
        self.date = dDay.date
        self.isLunarDate = dDay.isLunarDate
        self.convertedSolarDateFromLunar = dDay.convertedSolarDateFromLunar
        self.startFromDayOne = dDay.startFromDayOne
        self.isRepeatOn = dDay.isRepeatOn
        self.repeatType = dDay.repeatType
    }
}

