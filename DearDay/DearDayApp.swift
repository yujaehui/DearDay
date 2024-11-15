//
//  DearDayApp.swift
//  DearDay
//
//  Created by Jaehui Yu on 10/14/24.
//

import SwiftUI

@main
struct DearDayApp: App {
    init() {
        RealmConfiguration.shared.configureRealm()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
