//
//  DDayRepository.swift
//  DearDay
//
//  Created by Jaehui Yu on 10/31/24.
//

import Foundation
import RealmSwift

final class DDayRepository {
    private let realm = try! Realm()
    
    func createItem(_ item: DDay) {
        print(realm.configuration.fileURL)
        do {
            try realm.write {
                realm.add(item)
            }
        } catch {
            print(error)
        }
    }
    
//    func updateItem(_ item: DDay) {
//        do {
//            try realm.write {
//                realm.add(item, update: .modified)
//            }
//        } catch {
//            print(error)
//        }
//    }
    
    func updateItem(_ item: DDay, title: String, date: Date, isLunarDate: Bool, startFromDayOne: Bool, repeatType: RepeatType) {
        guard let item = realm.object(ofType: DDay.self, forPrimaryKey: item.pk) else {
            print("수정하려는 객체를 찾을 수 없습니다.")
            return
        }
        
        do {
            try realm.write {
                item.title = title
                item.date = date
                item.isLunarDate = isLunarDate
                item.startFromDayOne = startFromDayOne
                item.repeatType = repeatType

            }
        } catch {
            print(error)
        }
    }
    
    func deleteItem(_ item: DDay) {
        // 유효성 검사: object(ofType:forPrimaryKey:)로 객체가 Realm에서 관리되고 있는지 확인하여, 이미 삭제되었거나 관리가 해제된 객체를 참조하지 않도록 했습니다.
        // 스레드 안정성: Realm은 특정 스레드에서 생성된 객체를 그 스레드에서만 안전하게 수정할 수 있습니다. 객체를 가져오는 메서드를 통해 Realm과 일치하는 스레드에서 접근할 수 있도록 보장했기 때문에 스레드 충돌을 방지할 수 있습니다.
        
        guard let item = realm.object(ofType: DDay.self, forPrimaryKey: item.pk) else {
            print("삭제하려는 객체를 찾을 수 없습니다.")
            return
        }
        
        do {
            try realm.write {
                realm.delete(item)
            }
        } catch {
            print("Realm 삭제 중 오류 발생: \(error)")
        }
    }
}
