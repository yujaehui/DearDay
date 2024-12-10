//
//  APIService.swift
//  DearDay
//
//  Created by Jaehui Yu on 10/16/24.
//

import Foundation

enum APIServiceError: Error, CaseIterable {
    case networkUnavailable
    case invalidURL
    case serverError
    case parsingError
    case unknownError
    
    var shortErrorMessage: String {
        switch self {
        case .networkUnavailable:
            return "네트워크 연결 없음"
        case .invalidURL:
            return "잘못된 URL 요청"
        case .serverError:
            return "서버 문제 발생"
        case .parsingError:
            return "데이터 처리 오류"
        case .unknownError:
            return "음양력 계산 불가"
        }
    }
    
    var errorMessage: String {
        switch self {
        case .networkUnavailable:
            return "네트워크 연결이 없습니다.\n연결 후 다시 시도해주세요."
        case .invalidURL:
            return "잘못된 URL 요청입니다.\n다시 시도해주세요."
        case .serverError:
            return "서버에 문제가 발생했습니다.\n잠시 후 다시 시도해주세요."
        case .parsingError:
            return "데이터 처리 중 문제가 발생했습니다.\n다시 시도해주세요."
        case .unknownError:
            return "해당 날짜는 음양력 계산이 불가능합니다."
        }
    }
}

struct ResponseWrapper<T> {
    let data: T?
    let error: APIServiceError?

    /*
     이 접근 방식의 장점
     통일된 반환 형식: 성공/실패와 상관없이 항상 같은 구조로 반환되므로 호출하는 측에서 예외 처리 로직이 간소화됩니다.
     유연한 처리: 데이터와 에러를 한 번에 확인할 수 있으므로 에러가 발생했을 때 기본값을 제공하거나 로그를 남기는 등의 처리가 용이합니다.
     추가 정보 전달 가능: 필요하면 에러와 함께 추가적인 정보를 포함할 수 있습니다.
     */
    
}

final class APIService: APIServiceProtocol {
    private let calendar = Calendar.current
    private let serviceKey = APIKey.key
    private let baseURL = "http://apis.data.go.kr/B090041/openapi/service/LrsrCldInfoService/getSolCalInfo"
    
    func fetchSolarDate(lunarDate: Date) async -> ResponseWrapper<Date> {
        guard NetworkMonitor.shared.isConnected else {
            print(#function, "네트워크 연결이 없습니다. 연결 후 다시 시도해주세요.")
            return ResponseWrapper(data: nil, error: .networkUnavailable)
        }
        
        let year = calendar.component(.year, from: lunarDate)
        let month = calendar.component(.month, from: lunarDate)
        let day = calendar.component(.day, from: lunarDate)
        
        do {
            let solarDateItems = try await fetchSolarDateItems(lunYear: year, lunMonth: month, lunDay: day)
            if let solarItem = solarDateItems.first,
               let convertedDate = calendar.date(from: DateComponents(year: Int(solarItem.solYear), month: Int(solarItem.solMonth), day: Int(solarItem.solDay))) {
                return ResponseWrapper(data: convertedDate, error: nil)
            }
        } catch let error as APIServiceError {
            return ResponseWrapper(data: nil, error: error)
        } catch {
            return ResponseWrapper(data: nil, error: .unknownError)
        }
        
        return ResponseWrapper(data: nil, error: .unknownError)
    }
    
    func fetchSolarDate(year: Int, month: Int, day: Int) async -> ResponseWrapper<Date> {
        guard NetworkMonitor.shared.isConnected else {
            print(#function, "네트워크 연결이 없습니다. 연결 후 다시 시도해주세요.")
            return ResponseWrapper(data: nil, error: .networkUnavailable)
        }
                
        do {
            let solarDateItems = try await fetchSolarDateItems(lunYear: year, lunMonth: month, lunDay: day)
            if let solarItem = solarDateItems.first,
               let convertedDate = calendar.date(from: DateComponents(year: Int(solarItem.solYear), month: Int(solarItem.solMonth), day: Int(solarItem.solDay))) {
                return ResponseWrapper(data: convertedDate, error: nil)
            }
        } catch let error as APIServiceError {
            return ResponseWrapper(data: nil, error: error)
        } catch {
            return ResponseWrapper(data: nil, error: .unknownError)
        }
        
        return ResponseWrapper(data: nil, error: .unknownError)
    }
    
    func fetchSolarDateSync(year: Int, month: Int, day: Int) -> ResponseWrapper<Date> {
        guard NetworkMonitor.shared.isConnected else {
            print(#function, "네트워크 연결이 없습니다. 연결 후 다시 시도해주세요.")
            return ResponseWrapper(data: nil, error: .networkUnavailable)
        }
                
        do {
            let solarDateItems = try fetchSolarDateItemsSync(lunYear: year, lunMonth: month, lunDay: day)
            if let solarItem = solarDateItems.first,
               let convertedDate = calendar.date(from: DateComponents(year: Int(solarItem.solYear), month: Int(solarItem.solMonth), day: Int(solarItem.solDay))) {
                return ResponseWrapper(data: convertedDate, error: nil)
            }
        } catch let error as APIServiceError {
            return ResponseWrapper(data: nil, error: error)
        } catch {
            return ResponseWrapper(data: nil, error: .unknownError)
        }
        
        return ResponseWrapper(data: nil, error: .unknownError)
    }
    
    // MARK: - Private Helpers
    
    private func fetchSolarDateItems(lunYear: Int, lunMonth: Int, lunDay: Int) async throws -> [SolarDateItem] {
        print(#function)

        guard let url = constructURL(year: lunYear, month: lunMonth, day: lunDay) else {
            throw APIServiceError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw APIServiceError.serverError
        }
        
        return parseXML(data: data)
    }

    private func fetchSolarDateItemsSync(lunYear: Int, lunMonth: Int, lunDay: Int) throws -> [SolarDateItem] {
        print(#function)

        guard let url = constructURL(year: lunYear, month: lunMonth, day: lunDay) else {
            throw APIServiceError.invalidURL
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
            throw APIServiceError.serverError
        }
        
        guard let data = resultData else {
            throw APIServiceError.unknownError
        }
        
        return parseXML(data: data)
    }
    
    private func constructURL(year: Int, month: Int, day: Int) -> URL? {
        let urlString = String(
            format: "\(baseURL)?lunYear=%d&lunMonth=%02d&lunDay=%02d&ServiceKey=%@",
            year, month, day, serviceKey
        )
        return URL(string: urlString)
    }
    
    private func parseXML(data: Data) -> [SolarDateItem] {
        let parser = SolarDateXMLParser()
        return parser.parse(data: data)
    }
}
