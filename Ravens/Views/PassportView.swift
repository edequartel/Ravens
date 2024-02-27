import SwiftUI
import KeychainAccess
import SwiftyBeaver
import Alamofire
import MarkdownUI

class KeychainViewModel: ObservableObject {
    let log = SwiftyBeaver.self
    private let keychain = Keychain(service: bundleIdentifier)
    
    @EnvironmentObject var settings: Settings
    
    @Published var loginName: String = ""
    @Published var password: String = ""
    
    @Published var token: String = ""
    
    func saveCredentials() {
        do {
            try keychain.set(loginName, key: "loginName")
            try keychain.set(password, key: "password")
            log.error("save my token \(token)")
            try keychain.set(token, key: "token")
            
        } catch {
            // Handle errors
            print("Error saving credentials: \(error)")
        }
    }
    
    func retrieveCredentials() {
        do {
            loginName = try keychain.getString("loginName") ?? ""
            password = try keychain.getString("password") ?? ""
            log.error("load my token \(token)")
            tokenKey = try keychain.getString("token") ?? ""
        } catch {
            // Handle errors
            print("Error retrieving credentials: \(error)")
        }
    }
}

struct PassportView: View {
    let log = SwiftyBeaver.self
    @StateObject private var viewModel = KeychainViewModel()
    
    @EnvironmentObject var settings: Settings
    
    @State var myMessage: String = ""
    //    var myMessage: String = ""
    
    //    var didLogin: (String) -> Void
    
    var body: some View {
        Form {
            Section() {

                Picker("EndPoint", selection: $settings.selectedInBetween) {
                    Text("waarneming.nl")
                        .tag("waarneming.nl")
//                    Text("waarneming.be")
//                        .tag("waarneming.be")
                    Text("waarneming-test.nl")
                        .tag("waarneming-test.nl")
//                    Text("waarneming-test.be")
//                        .tag("waarneming-test.be")
//                    Text("observations.be")
//                        .tag("observations.be")
                    Text("observation.org")
                        .tag("observation.org")
                }
                .onChange(of: settings.selectedInBetween) {
                    print("Selected value changed to: \(settings.selectedInBetween)")
                    print(settings.endPoint())
                }

                

                
                TextField("Login Name", text: $viewModel.loginName)
                    .padding()
                    .onChange(of: viewModel.loginName) {
                        viewModel.loginName = viewModel.loginName.lowercased()
                    }
                
                SecureField("Password", text: $viewModel.password)
                    .padding()
            }
            //                Button("Save") {
            //                    viewModel.saveCredentials()
            //                }
            //                .padding()
            Section() {
                Button("Login") {
                    loginUser(username: viewModel.loginName, password: viewModel.password)
                    viewModel.saveCredentials()
                }
                .padding()
                if myMessage.count > 0 {
                    Text("\(myMessage)")
                        .foregroundColor(.red)
                        .padding()
                }
                
//                NavigationLink("Display Credentials", destination: DisplayCredentialsView(viewModel: viewModel))
//                    .padding()
            }
            
            Section() {
                Markdown(
                    """
**\(settings.selectedInBetween)**

Voor optimaal gebruik van Ravens is het vereist om een account te hebben bij [www.waarneming.nl](https://www.waarneming.nl). De Ravens-app maakt gebruik van waarnemingen die door heel Nederland en België worden doorgegeven.

Voor het invoeren van waarnemingen kun je gebruikmaken van de apps **iObs** en **Obsidentify**.

""")
            }
        }
        .navigationTitle("Login \(settings.selectedInBetween)")
        .onAppear {
            viewModel.retrieveCredentials()
            //            }
        }
    }
    
    
    func loginUser(username: String, password: String) {
        log.info("loginUser()")
        tokenKey = "" // empty token at login
        
        // Perform authentication and get token
        // In a real-world scenario, you would make an API call to authenticate the user
        let parameters: [String: String] = ["username": username, "password": password]
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/x-www-form-urlencoded",
        ]
        
        AF.request(settings.endPoint()+"auth/login/", method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers)
            .validate()
            .responseData { response in
                debugPrint(response)
                switch response.result {
                case .success(let value):
                    do {
                        let asJSON = try JSONSerialization.jsonObject(with: value)
                        // Handle as previously success
                        if let token = (asJSON as? [String: Any])?["key"] as? String {
                            // Save token to Keychain
                            do {
                                try Keychain(service: bundleIdentifier).set(token, key: "AuthToken")
                                log.error("103 token \(token)")
                                //                                                                didLogin(token)
                                myMessage = "Login success"
                                tokenKey = token
                            } catch {
                                log.info("Error saving token to Keychain: \(error.localizedDescription)")
                                myMessage = "Login error"
                            }
                        }
                    } catch {
                        log.error("Error while decoding response: \(error) from: \(String(describing: String(data: value, encoding: .utf8)))")
                        myMessage = "Login error"
                    }
                case .failure(let error):
                    // Handle as previously error
                    log.error("Login failed: \(error.localizedDescription)")
                    myMessage = "Login error"
                }
            }
    }
}

struct DisplayCredentialsView: View {
    @ObservedObject var viewModel: KeychainViewModel
    
    var body: some View {
        VStack {
            Text("Login Name: \(viewModel.loginName)")
            Text("Password: \(viewModel.password)")
            
            Text("Token: \(viewModel.token)")
        }
        .onAppear {
            viewModel.retrieveCredentials()
        }
        .padding(20)
    }
}

struct PassportView_Previews: PreviewProvider {
    static var previews: some View {
        PassportView()
            .environmentObject(Settings())
    }
}
