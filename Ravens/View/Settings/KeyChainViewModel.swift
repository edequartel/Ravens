//
//  KeyChainViewModel.swift
//  Ravens
//
//  Created by Eric de Quartel on 08/10/2024.
//

import SwiftUI
import KeychainAccess
import SwiftyBeaver
import Alamofire
import MarkdownUI

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