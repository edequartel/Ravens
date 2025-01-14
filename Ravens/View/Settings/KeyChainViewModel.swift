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

  @Published var token: String = "" {
    didSet {
      saveCredentials()
    }
  }
  
  @Published var loginFailed = false

  init(){
    retrieveCredentials()
  }

  func saveCredentials() {
    do {
      try keychain.set(token, key: "token")
      log.info("saved credentials are: \(token)")
    } catch {
      // Handle errors
      log.error("Error saving credentials: \(error)")
    }
  }

  func retrieveCredentials() {
    do {
      token = try keychain.getString("token") ?? ""
    } catch {
      // Handle errors
      log.error("Error retrieving credentials: \(error)")
    }
  }


  func fetchData(username: String, password: String, settings: Settings, completion: ((Bool) -> Void)? = nil) {
    log.info("KeychainViewModel fetchData()")

    self.token = "" // Clear token at the start of login (and logout)

    let parameters: [String: String] = ["username": username, "password": password]
    let headers: HTTPHeaders = [
      "Content-Type": "application/x-www-form-urlencoded",
    ]

    AF.request(endPoint() + "auth/login/", method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers)
      .validate()
      .responseData { response in
        switch response.result {
        case .success(let value):
          do {
            let asJSON = try JSONSerialization.jsonObject(with: value)

            if let token = (asJSON as? [String: Any])?["key"] as? String {
              self.log.info("Token saved successfully: \(token)")
              self.token = token
              self.saveCredentials()
              self.loginFailed = false
              completion?(true) // Call completion with success if provided

            } else {
              self.loginFailed = true
              completion?(false) // Call completion if token is missing, if provided
            }

          } catch {
            self.log.error("Error while decoding response: \(error) from: \(String(describing: String(data: value, encoding: .utf8)))")
            self.loginFailed = true
            completion?(false) // Call completion with failure if provided
          }
        case .failure(let error):
          self.loginFailed = true
          self.log.error("Login failed: \(error.localizedDescription)")
          completion?(false) // Call completion with failure if provided
        }
      }
  }
}
