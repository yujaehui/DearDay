//
//  NetworkMonitor.swift
//  DearDay
//
//  Created by Jaehui Yu on 12/7/24.
//

import SwiftUI
import Network

final class NetworkMonitor {
    static let shared = NetworkMonitor()
    private let monitor = NWPathMonitor(prohibitedInterfaceTypes: [.wiredEthernet, .loopback, .other])
    private let queue = DispatchQueue.global()
    @Published var isConnected: Bool = true
    
    private init() {
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                if path.status == .satisfied {
                    self.isConnected = true
                } else {
                    self.isConnected = false
                }
            }
        }
        monitor.start(queue: queue)
    }
}
