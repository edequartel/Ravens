import SwiftUI
import Alamofire

class LoginViewModel: ObservableObject {
    @Published var token: String = ""

    func loginUser(username: String, password: String) {
        let url = "https://waarneming.nl/api/v1/auth/login/"
        

        let parameters: [String: String] = [
            "username": username,
            "password": password
        ]

        let headers: HTTPHeaders = [
            "Content-Type": "application/x-www-form-urlencoded",
        ]
        
        AF.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success(let data):
                    if let json = data as? [String: Any], let key = json["key"] as? String {
                        print("Tokenkey: \(key)")
                        self.token  = key
                    } else {
                        print("Error extracting key from JSON")
                    }
                case .failure(let error):
                    print("Error: \(error)")
                }
            }
        
    }
}
