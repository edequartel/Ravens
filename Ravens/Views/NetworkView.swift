//
//  NetworkView.swift
//  Ravens
//
//  Created by Eric de Quartel on 06/03/2024.
//

import SwiftUI
import Alamofire

import SwiftUI
import Alamofire

class NetworkStatusViewModel: ObservableObject {
    @Published var isNetworkAvailable = true

    init() {
        startMonitoringNetwork()
    }

    private func startMonitoringNetwork() {
        let networkManager = NetworkReachabilityManager()

        networkManager?.startListening { status in
            self.isNetworkAvailable = (status == .reachable(.ethernetOrWiFi) )
                                       //|| status == .reachable(.wwan))
        }
    }
}

struct NetworkView: View {
    @StateObject private var viewModel = NetworkStatusViewModel()

    var body: some View {
        EmptyView()
//        Image(systemName: viewModel.isNetworkAvailable ? "wifi" : "wifi.slash")
//            .foregroundColor(viewModel.isNetworkAvailable ? .obsGreenFlower : .red)
    }
}

#Preview {
    NetworkView()
}
