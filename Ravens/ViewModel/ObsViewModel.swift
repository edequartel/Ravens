import Foundation
import Alamofire
import SwiftyBeaver

class ObsViewModel: ObservableObject {
    let log = SwiftyBeaver.self
    @Published var observation: Observation?
    private var keyChainViewModel =  KeychainViewModel()
    
    func fetchData(settings: Settings, for obsID: Int, completion: @escaping () -> Void) {
        log.info("fetchData API Call for ObsViewModel \(obsID) at \(Date())")
        
        let url = endPoint(value: settings.selectedInBetween)+"observations/\(obsID)/"
        
        let headers: HTTPHeaders = [
            "Accept-Language" : settings.selectedLanguage,
            "Authorization": "Token " + keyChainViewModel.token
        ]
        
        log.info("ObsViewModel url: \(url) \(headers)")
        
        AF.request(url, headers: headers).responseData { response in
            switch response.result {
            case .success(let data):
                if let utf8Data = String(data: data, encoding: .isoLatin1)?.data(using: .utf8) {
                    let decoder = JSONDecoder()

                    do {
                        self.observation = try decoder.decode(Observation.self, from: utf8Data)
                        completion()
                    } catch {
                        self.log.error("Error ObsViewModel decoding JSON: \(error)")
                    }
                }
            case .failure(let error):
                self.log.error("Error ObsViewModel fetching data: \(url) \(headers) - \(error)")
                self.log.error("\(String(describing: response.data))")
            }
        }
    }
}



