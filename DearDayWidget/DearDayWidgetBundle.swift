//
//  DearDayWidgetBundle.swift
//  DearDayWidget
//
//  Created by Jaehui Yu on 11/15/24.
//

import WidgetKit
import SwiftUI

@main
struct DearDayWidgetBundle: WidgetBundle {
    init() {
        RealmConfiguration.shared.configureRealm()
    }
    
    var body: some Widget {
        DearDayWidget()
    }
}
