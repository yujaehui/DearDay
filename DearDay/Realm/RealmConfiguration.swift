//
//  RealmConfiguration.swift
//  DearDay
//
//  Created by Jaehui Yu on 11/15/24.
//

import Foundation
import RealmSwift

final class RealmConfiguration {
    static let shared = RealmConfiguration()
    private init() {}
    
    func configureRealm() {
        if let appGroupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: AppGroupID.id) {
            let realmURL = appGroupURL.appendingPathComponent("default.realm")
            var config = Realm.Configuration()
            config.fileURL = realmURL
            config.schemaVersion = 1
            config.migrationBlock = { _, _ in } // 마이그레이션 처리
            Realm.Configuration.defaultConfiguration = config
            print("Realm 경로 설정 완료: \(realmURL)")
        } else {
            print("App Group 경로를 찾을 수 없습니다.")
        }
    }
}
