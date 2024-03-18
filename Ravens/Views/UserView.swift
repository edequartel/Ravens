//
//  UserView.swift
//  Ravens
//
//  Created by Eric de Quartel on 04/03/2024.
//

import SwiftUI

struct UserView: View {
    @EnvironmentObject var userViewModel:  UserViewModel
    @EnvironmentObject var keyChainviewModel: KeychainViewModel
    @EnvironmentObject var settings: Settings
    
    
    var body: some View {
        VStack(alignment: .leading) {
            if (keyChainviewModel.token.count > 0) {
                Text("\(userViewModel.user?.name ?? "unknown")")
                    .bold()
                Text("\(userViewModel.user?.email ?? "unknown")")
                
                let url = userViewModel.user?.url ?? "unknown"
                Button("\(url)") {
                    if let validURL = URL(string: url) {
                        UIApplication.shared.open(validURL)
                    }
                }
                let country = userViewModel.user?.country ?? "unknown"
                Text(country)                
                //            Text("Avatar: \(viewModel.user.avatar ?? "?")")
            }
        }
        .onAppear {
            userViewModel.fetchUserData(token: keyChainviewModel.token, settings: settings)
        }
    }
}

struct UserSimpleView: View {
    @EnvironmentObject var userViewModel:  UserViewModel
    
    @EnvironmentObject var keyChainviewModel: KeychainViewModel
    @EnvironmentObject var settings: Settings
    
    var body: some View {
        VStack(alignment: .leading) {
            if (keyChainviewModel.token.count > 0) {
                Text("\(userViewModel.user?.name ?? "unknown")")
            }
        }
        .onAppear {
            userViewModel.fetchUserData(token: keyChainviewModel.token, settings: settings)
        }
    }
}

#Preview {
    UserView()
        .environmentObject(KeychainViewModel())
        .environmentObject(UserViewModel())
        .environmentObject(Settings())
    
}
