//
//  UserView.swift
//  Ravens
//
//  Created by Eric de Quartel on 04/03/2024.
//

import SwiftUI
import SwiftyBeaver

struct UserView: View {
    let log = SwiftyBeaver.self

    @EnvironmentObject var userViewModel:  UserViewModel
    @EnvironmentObject var keyChainviewModel: KeychainViewModel
    @EnvironmentObject var settings: Settings
    
    @State private var navigateToObservers = false
    var body: some View {
        VStack(alignment: .leading) {
          Text("Token: \(keyChainviewModel.token)")
            .font(.caption)
          if (!keyChainviewModel.token.count.words.isEmpty) {
                HStack {
                    Spacer()
                  Text("\(userViewModel.user?.id ?? 0)")// \(userViewModel.user?.id ?? 0)")
                  Text("\(userViewModel.user?.name ?? "unknown")")// \(userViewModel.user?.id ?? 0)")
                        .bold()
                Spacer()
                }
                HStack {
                    Spacer()
                    QRCodeView(input: "ravens://"+String(userViewModel.user?.name ?? "unknown")+"/"+String(userViewModel.user?.id ?? 0))
                        .frame(width: 100, height: 100)
                        .padding(10)
                    Spacer()
                }
            }
        }
        .onChange(of: keyChainviewModel.token) { oldToken, newToken in
          log.error("token changed \(keyChainviewModel.token)")
                   if !newToken.isEmpty {
                     userViewModel.fetchUserData(settings: settings, token: keyChainviewModel.token ,completion: { log.info("UserView onAppear")})
                   }
               }
        .onAppear {
          userViewModel.fetchUserData(settings: settings,token: keyChainviewModel.token, completion: { log.info("UserView onAppear")})
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
    }
}

#Preview {
    UserView()
        .environmentObject(KeychainViewModel())
        .environmentObject(UserViewModel())
        .environmentObject(Settings())
    
}
