//
//  APIServiceProtocol.swift
//  DearDay
//
//  Created by Jaehui Yu on 11/21/24.
//

import Foundation

protocol APIServiceProtocol {
    func fetchSolarDate(lunarDate: Date) async -> Date?
    func fetchSolarDate(year: Int, month: Int, day: Int) async -> Date?
    func fetchSolarDateSync(year: Int, month: Int, day: Int) -> Date?
}

