//
//  DDayRepository.swift
//  DearDay
//
//  Created by Jaehui Yu on 10/31/24.
//

import Foundation
import RealmSwift

final class DDayRepository {
    private let realm: Realm
    
    init() {
        realm = try! Realm()
    }
    
    func fetchItem() -> Results<DDay> {
        let results = realm.objects(DDay.self)
        return results
    }
    
    func createItem(_ item: DDay) {
        do {
            try realm.write {
                realm.add(item)
            }
        } catch {
            print(error)
        }
    }
    
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
