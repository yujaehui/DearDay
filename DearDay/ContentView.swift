//
//  ContentView.swift
//  DearDay
//
//  Created by Jaehui Yu on 10/14/24.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("isRequested") private var isRequested: Bool = false

    var body: some View {
        DDayView()
            .onAppear {
                if !isRequested {
                    NotificationManager.shared.requestAuthorization { granted in
                        if granted {
                            isRequested = true
                        }
                    }
                }
            }
    }
}

#Preview {
    ContentView()
}
