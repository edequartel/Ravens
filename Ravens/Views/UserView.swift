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
    
    @State private var navigateToObservers = false
    var body: some View {
        VStack(alignment: .leading) {
            if (keyChainviewModel.token.count > 0) {
                
                Text("\(userViewModel.user?.name ?? "unknown")")
                    .bold()
                Text("\(userViewModel.user?.email ?? "unknown")")
                Text("\(String(userViewModel.user?.id ?? 0))")
                
                QRCodeView(input: "ravens://"+String(userViewModel.user?.name ?? "unknown")+"/"+String(userViewModel.user?.id ?? 0))
                    .frame(width: 100, height: 100)
                
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
            userViewModel.fetchUserData(settings: settings, completion: { print("userViewModel.fetchUserData") })
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
            userViewModel.fetchUserData(settings: settings, completion: { print("userViewModel.fetchUserData") } )
        }
    }
}

#Preview {
    UserView()
        .environmentObject(KeychainViewModel())
        .environmentObject(UserViewModel())
        .environmentObject(Settings())
    
}
