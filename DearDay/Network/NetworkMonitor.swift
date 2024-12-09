//
//  NetworkMonitor.swift
//  DearDay
//
//  Created by Jaehui Yu on 12/7/24.
//

import SwiftUI
import Network
import WidgetKit

final class NetworkMonitor {
    static let shared = NetworkMonitor()
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue.global()
    @Published var isConnected: Bool = true
    
    private init() {
        monitor.start(queue: queue)
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                self.isConnected = path.status == .satisfied
            }
        }
    }
}
