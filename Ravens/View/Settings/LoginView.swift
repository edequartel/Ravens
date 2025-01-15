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

  @EnvironmentObject var userViewModel:  UserViewModel

  @State private var myInlogName = ""
  @State private var myPassword = ""

  //  @State private var myInlogName = "lesdequartel@yahoo.com "
  //  @State private var myPassword = "Zeemeeuw2015!"

  //  @State private var myInlogName = "edequartel@protonmail.com "
  //  @State private var myPassword = "fyrta5-pIdtow-gawpys"

  var body: some View {
    Form {
      Section("Login \(settings.selectedInBetween)") {
        // Horizontal buttons
                    HStack {
                        Button("edq") {
                            myInlogName = "edequartel@protonmail.com"
                            myPassword = "fyrta5-pIdtow-gawpys"
                        }
                        .buttonStyle(BorderlessButtonStyle())

                        Button("ldq") {
                            myInlogName = "lesdequartel@yahoo.com"
                            myPassword = "Zeemeeuw2015!"
                        }
                        .buttonStyle(BorderlessButtonStyle())

                        Button("hdj") {
                            myInlogName = "Heikodejonge@cetera.nu"
                            myPassword = "Simca25-an-58"
                        }
                        .buttonStyle(BorderlessButtonStyle())

                        Button("bdq") {
                            myInlogName = "bramdeq@live.nl"
                            myPassword = "7mRv6!JZaV!JJb3"
                        }
                        .buttonStyle(BorderlessButtonStyle())

                        Button("!") {
                            myInlogName = ""
                            myPassword = ""
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    }
                    .padding()

        //        }
        VStack {
          if keyChainviewModel.token.isEmpty {
            TextField("Email", text: $myInlogName, prompt: Text("Enter your email address"))
              .textContentType(.emailAddress)
              .autocapitalization(.none)
              .disableAutocorrection(true)
              .textFieldStyle(.roundedBorder)

            Divider()

            SecureField(text: $myPassword, prompt: Text(password)) {
              Text(password)
            }
            .textContentType(.password)
            .textFieldStyle(.roundedBorder)

            Button("Log In") {
              guard !myInlogName.isEmpty, !myPassword.isEmpty else {
                log.error("Email or password is empty.")
                return
              }
              keyChainviewModel.fetchData(
                username: myInlogName,
                password: myPassword,
                settings: settings
              ) { success in
                if success {
                  log.info("Credentials successfully fetched.")
                  //so we get the user details and use these
                  userViewModel.fetchUserData(
                    settings: settings,
                    token: keyChainviewModel.token ,
                    completion:
                      {
                        log.error("userViewModel fethData")
                        userViewModel.loginSuccess = true
                    })
                  //
                } else {
                  log.error("Failed to fetch credentials.")
                }
              }
            }
            .buttonStyle(.borderedProminent)
            .frame(maxWidth: .infinity)

            if keyChainviewModel.loginFailed {
              Text(logInFailed)
                .foregroundColor(.red)
                .padding()
            }


          } else {

            HStack {
              Button(logOut) {
                keyChainviewModel.token = ""
                userViewModel.loginSuccess = false

              }
              .buttonStyle(.bordered)
              .frame(maxWidth: .infinity)
            }
            .padding(10)
          }
        }
      }

//      DisplayCredentialsView()

//      if !keyChainviewModel.token.isEmpty {
        Section(user) {
          UserView()
            .accessibilityElement(children: .combine)
        }
//      }

      if keyChainviewModel.token.isEmpty {
        Section(information) {
          InfoObservationView()
        }
      }
    }
  }
}

struct InfoObservationView: View {
  @EnvironmentObject var settings: Settings
  var body: some View {
    Markdown(
        """
        Voor optimaal gebruik van Ravens is het vereist om een account te hebben bij \
        [www.waarneming.nl](https://www.waarneming.nl).
        """
    )
  }
}

struct DisplayCredentialsView: View {
  @EnvironmentObject var viewModel: KeychainViewModel

  var body: some View {
    VStack(alignment: .leading) {
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

