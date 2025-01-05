//
//  NetworkMonitor.swift
//  DearDay
//
//  Created by Jaehui Yu on 12/7/24.
//

import SwiftUI
import Network

final class NetworkMonitor: ObservableObject {
    static let shared = NetworkMonitor()
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue.global()
    @Published private(set) var isConnected: Bool = false
    
    private init() {
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                self.isConnected = (path.status == .satisfied)
            }
        }
        monitor.start(queue: queue)
    }
}
