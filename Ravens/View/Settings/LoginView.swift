//  LoginView.swift
//  Ravensimport SwiftUI

import KeychainAccess
import SwiftyBeaver
import Alamofire
import MarkdownUI
import SwiftUI

struct LoginView: View {
  let log = SwiftyBeaver.self

  @EnvironmentObject var keyChainviewModel: KeychainViewModel
  @EnvironmentObject var settings: Settings

  @State private var myInlogName = ""
  @State private var myPassword = ""

  var body: some View {
    Form {
      Section("Login") {
        VStack {

          TextField("email", text: $myInlogName, prompt: Text("emailadres"))
            .onChange(of: myInlogName) { oldState, newState in
              myInlogName = newState.lowercased()
              let lowercasedName = newState.lowercased()
              if lowercasedName != keyChainviewModel.loginName {
                keyChainviewModel.loginName = lowercasedName
              }
            }
            .textContentType(.emailAddress)
            .disableAutocorrection(true)
            .textFieldStyle(.roundedBorder)

          Divider()

          SecureField(text: $myPassword, prompt: Text("password")) {
            Text("password")
          }
          .onChange(of: myPassword) { oldState, newState in
            keyChainviewModel.password = newState
          }
          .textContentType(.password)
          .disableAutocorrection(true)
          .textFieldStyle(.roundedBorder)

          HStack {
            if keyChainviewModel.token.isEmpty {
              Button("Login") {
                keyChainviewModel.fetchData(
                  username: keyChainviewModel.loginName,
                  password: keyChainviewModel.password,
                  settings: settings,
                  completion: { success in
                    if success {
                      log.error("Credentials successfully fetched.")
                      keyChainviewModel.saveCredentials()
                    } else {
                      log.error("Failed to fetch credentials.")
                    }
                  }
                )
              }
              .buttonStyle(.borderedProminent)
              .frame(maxWidth: .infinity)
            } else {
              Button("Logout") {
                keyChainviewModel.token = ""
//                keyChainviewModel.loginName = ""
//                keyChainviewModel.password = ""
                keyChainviewModel.saveCredentials()
                keyChainviewModel.retrieveCredentials()
              }
              .buttonStyle(.bordered)
              .frame(maxWidth: .infinity)
            }
          }
          .padding(10)

          if keyChainviewModel.loginFailed {
            Text("Login failed")
              .foregroundColor(.red)
          }
        }
        .onAppear {
          myInlogName = keyChainviewModel.loginName
          myPassword = keyChainviewModel.password
          log.error("Login Name onAppear: \(myInlogName)")
          log.error("Password onAppear: \(myPassword)")
        }
      }

      Section("Information") {
        InfoObservationView()
      }

      Section("User") {
        if keyChainviewModel.token.count > 0 {
          UserView()
        }
      }

//      Section("Credentials") {
//        DisplayCredentialsView()
//      }
    }
  }
}


struct InfoObservationView: View {
  @EnvironmentObject var settings: Settings
  var body: some View {
    Markdown(
            """
Voor optimaal gebruik van Ravens is het vereist om een account te hebben bij [www.waarneming.nl](https://www.waarneming.nl). De Ravens-app maakt gebruik van waarnemingen die door heel Nederland en België worden doorgegeven.

De website van Ravens kun je vinden op [Ravens](https://edequartel.github.io/Ravens/).

De handleiding van Ravens kun je vinden op [Handleiding](https://edequartel.github.io/Ravens/images/manual.pdf).

Voor het invoeren van waarnemingen kun je gebruikmaken van de apps **iObs** en **Obsidentify**.
""")
  }
}

struct DisplayCredentialsView: View {
  @EnvironmentObject var viewModel: KeychainViewModel
  @EnvironmentObject var settings: Settings
  
  var body: some View {
    VStack(alignment: .leading) {
      Text("Login Name: \(viewModel.loginName)")
      Text("Password: \(viewModel.password)")
      Text("Token: \(viewModel.token)")
    }
    .font(.caption)
  }
}

struct LoginView_Previews: PreviewProvider {
  static var previews: some View {
    LoginView()
      .environmentObject(KeychainViewModel())
      .environmentObject(Settings())
  }
}

