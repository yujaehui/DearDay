//
//  DearDayAccessoryWidgetBundle.swift
//  DearDayAccessoryWidget
//
//  Created by Jaehui Yu on 12/4/24.
//

import WidgetKit
import SwiftUI

@main
struct DearDayAccessoryWidgetBundle: WidgetBundle {
    init() {
        RealmConfiguration.shared.configureRealm()
    }
    
    var body: some Widget {
        DearDayAccessoryWidget()
    }
}
