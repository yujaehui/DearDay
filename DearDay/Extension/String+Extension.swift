//
//  String+Extension.swift
//  DearDay
//
//  Created by Jaehui Yu on 11/11/24.
//

import Foundation

extension String {
    var sortPriority: Int {
        if self == "D-DAY" { return 0 }
        if self.hasPrefix("-") { return 1 }
        if self.hasPrefix("+") { return 2 }
        return 3
    }
}
