//
//  DDayRepositoryProtocol.swift
//  DearDay
//
//  Created by Jaehui Yu on 11/21/24.
//

import Foundation
import RealmSwift

protocol DDayRepositoryProtocol {
    func fetchItem() -> [DDay]
    func createItem(_ item: DDay)
    func updateItem(_ originalItem: DDay, updatedItem: DDay)
    func deleteItem(_ item: DDay)
}
