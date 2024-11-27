//
//  DearDayListWidgetBundle.swift
//  DearDayListWidget
//
//  Created by Jaehui Yu on 11/27/24.
//

import WidgetKit
import SwiftUI

@main
struct DearDayListWidgetBundle: WidgetBundle {
    init() {
        RealmConfiguration.shared.configureRealm()
    }
    
    var body: some Widget {
        DearDayListWidget()
    }
}
