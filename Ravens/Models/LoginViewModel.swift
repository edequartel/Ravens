import SwiftUI
import Alamofire
import SwiftyBeaver

class LoginViewModel: ObservableObject {
    let log = SwiftyBeaver.self
    @Published var token: String = ""

    func loginUser(username: String, password: String) {
        log.info("LoginViewModel")
        let url = endPoint+"auth/login/"
        

        let parameters: [String: String] = [
            "username": username,
            "password": password
        ]

        let headers: HTTPHeaders = [
            "Content-Type": "application/x-www-form-urlencoded",
        ]
        
        log.info("loginView: \(url)")
        AF.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success(let data):
                    if let json = data as? [String: Any], let key = json["key"] as? String {
                        self.log.verbose("Tokenkey: \(key)")
                        self.token  = key
                    } else {
                        self.log.error("Error LoginViewModel extracting key from JSON")
                    }
                case .failure(let error):
                    self.log.error("Error LoginViewModel: \(error)")
                }
            }
        
    }
}
