//
//  APIService.swift
//  DearDay
//
//  Created by Jaehui Yu on 10/16/24.
//

import Foundation

final class APIService {
    static let shared = APIService()
    private init() {}
    
    func fetchSolarDateItems(lunYear: Int, lunMonth: Int, lunDay: Int) async throws -> [SolarDateItem] {
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
}
