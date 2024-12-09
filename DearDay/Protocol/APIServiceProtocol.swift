//
//  APIServiceProtocol.swift
//  DearDay
//
//  Created by Jaehui Yu on 11/21/24.
//

import Foundation

protocol APIServiceProtocol {
    func fetchSolarDate(lunarDate: Date) async -> ResponseWrapper<Date>
    func fetchSolarDate(year: Int, month: Int, day: Int) async -> ResponseWrapper<Date>
    func fetchSolarDateSync(year: Int, month: Int, day: Int) -> ResponseWrapper<Date>
}

