//
//  Results+Extension.swift
//  DearDay
//
//  Created by Jaehui Yu on 11/11/24.
//

import Foundation
import RealmSwift

extension Results {
    func toArray() -> [Element] {
        return Array(self)
    }
}
