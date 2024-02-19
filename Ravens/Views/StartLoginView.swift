////
////  ContentView.swift
////  Ravens
////
////  Created by Eric de Quartel on 05/02/2024.
////
//
//import SwiftUI
//import Alamofire
//import KeychainAccess
//import SwiftyBeaver
//
//let bundleIdentifier = "ravens.app.bundle.identifier"
//
////class AuthManager: ObservableObject {
////    let log = SwiftyBeaver.self
////    
////    @Published var token: String?
////    
////    init() {
////        // Check if token exists in Keychain at the start
////        if let storedToken = try? Keychain(service: bundleIdentifier).get("AuthToken") {
////            self.token = storedToken
////            log.verbose("AuthManager Token \(storedToken)")
////        }
////    }
////    
////    func updateToken(_ newToken: String?) {
////        self.token = newToken
////    }
////}
//
//class AuthManager: ObservableObject {
//    let log = SwiftyBeaver.self
//    
//    @Published var token: String?
//    
//    init() {
//        let storedToken = tokenKey
//        self.token = storedToken
//    }
//    
//    func updateToken(_ newToken: String?) {
//        self.token = newToken
//    }
//}
//
//struct StartLoginView: View {
//    let log = SwiftyBeaver.self
//    
//    @StateObject private var authManager = AuthManager()
//    
////    @State private var username: String = "edequartel@protonmail.com"
////    @State private var password: String = "zeemeeuw2015"
//    @State private var username: String = ""
//    @State private var password: String = ""
//    
//    var body: some View {
//        
//        if authManager.token == nil {
//            LoginView(username: $username, password: $password, didLogin: { newToken in
//                authManager.updateToken(newToken)
//                
//            })
//        } else {
//            RavensContentView()
//        }
//    }
//}
//
//struct StartLoginView_Previews: PreviewProvider {
//    static var previews: some View {
//        StartLoginView()
//    }
//}
//
//struct LoginView: View {
//    let log = SwiftyBeaver.self
//    
//    @Binding var username: String
//    @Binding var password: String
//    
//    var didLogin: (String) -> Void
//    
//    var body: some View {
//        VStack {
//            Text("Login waarneming.nl")
//                .foregroundColor(.blue)
//                .padding()
//            
//            TextField("Username", text: $username)
//                .padding()
//                .textFieldStyle(RoundedBorderTextFieldStyle())
//                .onChange(of: username) {
//                    username = username.lowercased()
//                }
//            
//            SecureField("Password", text: $password)
//                .padding()
//                .textFieldStyle(RoundedBorderTextFieldStyle())
//                .onChange(of: password) {
//                    password = password.lowercased()
//                }
//            
//            Button("Login") {
//                loginUser()
//            }
//            .buttonStyle (.bordered)
//        }
//        .padding()
//    }
//    
//    func loginUser() {
//        log.info("loginUser()")
//        // Perform authentication and get token
//        // In a real-world scenario, you would make an API call to authenticate the user
//        //        let parameters: [String: String] = ["username": "email", "password": "password"]
//        let parameters: [String: String] = ["username": username, "password": password]
//        
//        let headers: HTTPHeaders = [
//            "Content-Type": "application/x-www-form-urlencoded",
//        ]
//        
//        AF.request(endPoint+"auth/login/", method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers)
//            .validate()
//            .responseData { response in
//                debugPrint(response)
//                switch response.result {
//                case .success(let value):
//                    do {
//                        let asJSON = try JSONSerialization.jsonObject(with: value)
//                        // Handle as previously success
//                        if let token = (asJSON as? [String: Any])?["key"] as? String {
//                            // Save token to Keychain
//                            do {
//                                try Keychain(service: bundleIdentifier).set(token, key: "AuthToken")
//                                didLogin(token)
//                            } catch {
//                                log.error("Error saving token to Keychain: \(error.localizedDescription)")
//                            }
//                        }
//                    } catch {
//                        log.error("Error while decoding response: \(error) from: \(String(describing: String(data: value, encoding: .utf8)))")
//                    }
//                case .failure(let error):
//                    // Handle as previously error
//                    log.error("Login failed: \(error.localizedDescription)")
//                }
//            }
//    }
//}
//
//
////struct LoginView_Previews: PreviewProvider {
////    static var previews: some View {
////        let username = Binding<String>(
////            get: { "PreviewUsername" },
////            set: { _ in }
////        )
////        
////        let password = Binding<String>(
////            get: { "PreviewPassword" },
////            set: { _ in }
////        )
////
////        return LoginView(username: username, password: password, didLogin: { token in
////            // Handle didLogin in preview if needed
////            print("Did login with token: \(token)")
////        })
////    }
////}
//
