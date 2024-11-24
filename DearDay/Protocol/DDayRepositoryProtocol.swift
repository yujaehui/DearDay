//
//  DDayRepositoryProtocol.swift
//  DearDay
//
//  Created by Jaehui Yu on 11/21/24.
//

import Foundation
import RealmSwift

protocol DDayRepositoryProtocol {
    func fetchItem() -> [DDay]
    func createItem(_ item: DDay)
    func updateItem(_ item: DDay, title: String, date: Date, isLunarDate: Bool, convertedSolarDateFromLunar: Date?, startFromDayOne: Bool, isRepeatOn: Bool, repeatType: RepeatType)
    func deleteItem(_ item: DDay)
}
