//
//  DDayAppGroupStorage.swift
//  DearDay
//
//  Created by Jaehui Yu on 5/7/25.
//

import Foundation

enum DDayAppGroupStorage {
    private static let fileName = "dday_items.json"
    
    static func load() -> [DDayItem] {
        guard let url = FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: AppGroupID.id)?
            .appendingPathComponent(fileName),
              let data = try? Data(contentsOf: url),
              let items = try? JSONDecoder().decode([DDayItem].self, from: data)
        else {
            return []
        }
        return items
    }

    static func save(_ items: [DDayItem]) {
        guard let url = FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: AppGroupID.id)?
            .appendingPathComponent(fileName) else { return }

        do {
            let data = try JSONEncoder().encode(items)
            try data.write(to: url)
        } catch {
            print("AppGroup 저장 실패: \(error)")
        }
    }
}
