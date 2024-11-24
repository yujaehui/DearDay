//
//  APIService.swift
//  DearDay
//
//  Created by Jaehui Yu on 10/16/24.
//

import Foundation

final class APIService: APIServiceProtocol {
    
    func fetchSolarDate(lunarDate: Date) async -> Date? {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: lunarDate)
        let month = calendar.component(.month, from: lunarDate)
        let day = calendar.component(.day, from: lunarDate)
        
        do {
            let solarDateItems = try await fetchSolarDateItems(lunYear: year, lunMonth: month, lunDay: day)
            for solarItem in solarDateItems {
                if let convertedDate = calendar.date(from: DateComponents(year: Int(solarItem.solYear), month: Int(solarItem.solMonth), day: Int(solarItem.solDay))) {
                    return convertedDate
                }
            }
        } catch {
            print("Error fetching closest lunar date for year \(year): \(error)")
        }
        return nil
    }
    
    func fetchSolarDate(year: Int, month: Int, day: Int) async -> Date? {
        let calendar = Calendar.current
        
        do {
            let solarDateItems = try await fetchSolarDateItems(lunYear: year, lunMonth: month, lunDay: day)
            for solarItem in solarDateItems {
                if let convertedDate = calendar.date(from: DateComponents(year: Int(solarItem.solYear), month: Int(solarItem.solMonth), day: Int(solarItem.solDay))) {
                    return convertedDate
                }
            }
        } catch {
            print("Error fetching closest lunar date for year \(year): \(error)")
        }
        return nil
    }
    
    private func fetchSolarDateItems(lunYear: Int, lunMonth: Int, lunDay: Int) async throws -> [SolarDateItem] {
        let serviceKey = APIKey.key
        let urlString = String(format: "http://apis.data.go.kr/B090041/openapi/service/LrsrCldInfoService/getSolCalInfo?lunYear=%d&lunMonth=%02d&lunDay=%02d&ServiceKey=%@", lunYear, lunMonth, lunDay, serviceKey)
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        let parser = SolarDateXMLParser()
        let parsedItems = parser.parse(data: data)
        return parsedItems
    }
    
    func fetchSolarDateSync(year: Int, month: Int, day: Int) -> Date? {
        let calendar = Calendar.current
        
        do {
            let solarDateItems = try fetchSolarDateItemsSync(lunYear: year, lunMonth: month, lunDay: day)
            for solarItem in solarDateItems {
                if let convertedDate = calendar.date(from: DateComponents(year: Int(solarItem.solYear), month: Int(solarItem.solMonth), day: Int(solarItem.solDay))) {
                    return convertedDate
                }
            }
        } catch {
            print("Error fetching closest lunar date for year \(year): \(error)")
        }
        return nil
    }

    private func fetchSolarDateItemsSync(lunYear: Int, lunMonth: Int, lunDay: Int) throws -> [SolarDateItem] {
        let serviceKey = APIKey.key
        let urlString = String(format: "http://apis.data.go.kr/B090041/openapi/service/LrsrCldInfoService/getSolCalInfo?lunYear=%d&lunMonth=%02d&lunDay=%02d&ServiceKey=%@", lunYear, lunMonth, lunDay, serviceKey)
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        var resultData: Data?
        var resultError: Error?
        let semaphore = DispatchSemaphore(value: 0)
        
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            resultData = data
            resultError = error
            semaphore.signal()
        }
        
        task.resume()
        semaphore.wait() // 비동기 작업이 끝날 때까지 대기
        
        if let error = resultError {
            throw error
        }
        
        guard let data = resultData else {
            throw URLError(.badServerResponse)
        }
        
        let parser = SolarDateXMLParser()
        let parsedItems = parser.parse(data: data)
        return parsedItems
    }
}
