//
//  TokenView.swift
//  Ravens
//
//  Created by Eric de Quartel on 17/01/2024.
//

import SwiftUI

struct TokenView: View {
    @ObservedObject var loginViewModel: LoginViewModel

    var body: some View {
        VStack {
            Text("Token: \(loginViewModel.token)")
                .font(.headline)
            Text(loginViewModel.token)
                .padding()
            // Add any other UI elements or logic as needed
        }
        .onAppear {
            // Call the login API when the view appears
            loginViewModel.loginUser(username: "edequartel@protonmail.com", password: "zeemeeuw2015")
        }
    }
}

struct TokenView_Previews: PreviewProvider {
    static var previews: some View {
        TokenView(loginViewModel: LoginViewModel())
    }
}
