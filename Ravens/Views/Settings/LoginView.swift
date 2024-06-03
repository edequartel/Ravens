import SwiftUI
import KeychainAccess
import SwiftyBeaver
import Alamofire
import MarkdownUI

//
//  LoginView.swift
//  Ravens

class KeychainViewModel: ObservableObject {
    let log = SwiftyBeaver.self
    private let keychain = Keychain(service: bundleIdentifier)
    
    @Published var loginName: String = ""
    @Published var password: String = ""
    @Published var token: String = ""
    
    @Published var loginFailed = false
    
    init(){
        retrieveCredentials()
    }
    
    func saveCredentials() {
        do {
            try keychain.set(loginName, key: "loginName")
            try keychain.set(password, key: "password")
            try keychain.set(token, key: "token")
            log.error("saved credentials are: \(loginName) \(password) \(token)")
        } catch {
            // Handle errors
            log.error("Error saving credentials: \(error)")
        }
    }
    
    func retrieveCredentials() {
        do {
            loginName = try keychain.getString("loginName") ?? ""
            password = try keychain.getString("password") ?? ""
            token = try keychain.getString("token") ?? ""
            log.info("retrieved credentials are: \(loginName) \(password) \(token)")
        } catch {
            // Handle errors
            log.error("Error retrieving credentials: \(error)")
        }
    }
    
    func fetchData(username: String, password: String, settings: Settings) {
        log.info("KeychainViewModel fetchdata()")
        
        self.token = "" // empty token at login (and logout)
        
        let parameters: [String: String] = ["username": username, "password": password]
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/x-www-form-urlencoded",
        ]
        
        AF.request(endPoint()+"auth/login/", method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers)
            .validate()
            .responseData { response in
                // debugPrint(response)
                switch response.result {
                case .success(let value):
                    do {
                        let asJSON = try JSONSerialization.jsonObject(with: value)
                        // Handle as previously success
                        if let token = (asJSON as? [String: Any])?["key"] as? String {
                            // Save token to Keychain
                            do {
                                try Keychain(service: bundleIdentifier).set(token, key: "AuthToken")
                                self.log.error("103 token \(token)")
                                self.token = token
                                self.saveCredentials()
                                self.loginFailed = false
                            } catch {
                                self.log.info("Error saving token to Keychain: \(error.localizedDescription)")
                                self.loginFailed = true
                            }
                        }
                    } catch {
                        self.log.error("Error while decoding response: \(error) from: \(String(describing: String(data: value, encoding: .utf8)))")
                        self.loginFailed = true
                    }
                case .failure(let error):
                    self.loginFailed = true
                    self.log.error("Login failed: \(error.localizedDescription)")
                }
            }
    }
}

struct LoginView: View {
    let log = SwiftyBeaver.self
    
    @EnvironmentObject var keyChainviewModel: KeychainViewModel
    @EnvironmentObject var settings: Settings
    
    var firstTime = true
    
    var body: some View {
        Form {
            Section("Login") {
                VStack {
                    //                    Text("Login to \(settings.selectedInBetween)")
                    TextField("Name", text: $keyChainviewModel.loginName)
                        .onChange(of: keyChainviewModel.loginName) {
                            keyChainviewModel.loginName = keyChainviewModel.loginName.lowercased()
                        }
                    SecureField("Password", text: $keyChainviewModel.password)
                }
            }
            
            
            VStack {
                HStack {
                    
                    if (keyChainviewModel.token.isEmpty) {
                        Button("Login") {
                            keyChainviewModel.fetchData(
                                username: keyChainviewModel.loginName,
                                password: keyChainviewModel.password,
                                settings: settings)
                            keyChainviewModel.saveCredentials()
                        }
                        .buttonStyle(.borderedProminent)
                        .frame(maxWidth: .infinity)
                        
                    }
                    else {
                        Button("Logout") {
                            keyChainviewModel.token = ""
                            keyChainviewModel.saveCredentials()
                            keyChainviewModel.retrieveCredentials()
                        }
                        .buttonStyle(.bordered)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.red)
                    }
                    
                }
                
                if (keyChainviewModel.loginFailed) {
                    Text("Login failed")
                }
            }
            
            Section {
                if (keyChainviewModel.token.count>0) {
                    UserView()
                }
            }
            
//            Section() {
//                ObserversView()
//            }
            
            Section() {
                InfoObservationView()
            }
            
            DisplayCredentialsView()
        }
        .navigationTitle("Login \(selectedInBetween)")
    }
}

struct InfoObservationView: View {
    
    @EnvironmentObject var settings: Settings
    var body: some View {
        Markdown(
            """
**\(selectedInBetween)**

Voor optimaal gebruik van Ravens is het vereist om een account te hebben bij [www.waarneming.nl](https://www.waarneming.nl). De Ravens-app maakt gebruik van waarnemingen die door heel Nederland en België worden doorgegeven.

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
