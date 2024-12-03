//
//  DDayRepository.swift
//  DearDay
//
//  Created by Jaehui Yu on 10/31/24.
//

import Foundation
import RealmSwift

final class DDayRepository: DDayRepositoryProtocol {
    private let realm: Realm
    
    init() {
        realm = try! Realm()
    }
    
    func fetchItem() -> [DDay] {
        print(realm.configuration.fileURL)
        let realm = try! Realm()
        return Array(realm.objects(DDay.self))
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
    
    func updateItem(_ originalItem: DDay, updatedItem: DDay) {
        guard let originalItem = realm.object(ofType: DDay.self, forPrimaryKey: originalItem.pk) else {
            print("수정하려는 객체를 찾을 수 없습니다.")
            return
        }
        
        do {
            try realm.write {
                originalItem.title = updatedItem.title
                originalItem.date = updatedItem.date
                originalItem.isLunarDate = updatedItem.isLunarDate
                originalItem.convertedSolarDateFromLunar = updatedItem.convertedSolarDateFromLunar
                originalItem.startFromDayOne = updatedItem.startFromDayOne
                originalItem.isRepeatOn = updatedItem.isRepeatOn
                originalItem.repeatType = updatedItem.repeatType

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
