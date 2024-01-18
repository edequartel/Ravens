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
            .cURLDescription { description in
                            // Print the cURL command to the console
                            print("Alamofire Request:")
                            print(description)
                        }
            .responseDecodable(of: LoginModel.self) { response in
                switch response.result {
                case .success(let loginModel):
                    DispatchQueue.main.async {
                        self.token = loginModel.token
                        // Handle any other logic or UI updates
                    }
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                }
            }
    }
}

