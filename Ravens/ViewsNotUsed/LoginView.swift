//
//  loginView.swift
//  Ravens
//
//  Created by Eric de Quartel on 17/01/2024.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var settings: Settings
    @ObservedObject var loginViewModel: LoginViewModel
    
    var body: some View {
            VStack(alignment: .leading) {
                Text("\(settings.login)")
                Text("\(settings.password)")
            }
            Button("getToken") {
                loginViewModel.loginUser(username: settings.login, password: settings.password)
                    settings.token = loginViewModel.token
            }
            Text("\(loginViewModel.token)")
            Text("\(settings.token)")
                .font(.headline)
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
    // Setting up the environment objects for the preview
        LoginView(loginViewModel: LoginViewModel())
            .environmentObject(Settings())
    }
}

