import Foundation
import Alamofire
import SwiftyBeaver

class ObsViewModel: ObservableObject {
    let log = SwiftyBeaver.self
    
    @Published var observation: Observation?
    
    private var lastRequestTime: Date?
    
    private var keyChainViewModel =  KeychainViewModel()
    
    var settings: Settings
    init(settings: Settings) {
        log.debug("init ObsViewModel")
        self.settings = settings
    }
    
    func fetchData(for obsID: Int, completion: @escaping () -> Void) {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent("CachedObs\(obsID).json")
        log.error(fileURL)
        
        log.info("fetchData API Call for ObsViewModel \(obsID) at \(Date())")
        
        let url = settings.endPoint()+"observations/\(obsID)/"
        
        keyChainViewModel.retrieveCredentials()
        
        let headers: HTTPHeaders = [
            "Accept-Language" : settings.selectedLanguage,
            "Authorization": "Token " + keyChainViewModel.token
        ]
        
        log.info("\(url) \(headers)")
        
        AF.request(url, headers: headers).responseData { response in
            switch response.result {
            case .success(let data):
                if let utf8Data = String(data: data, encoding: .isoLatin1)?.data(using: .utf8) {
                    let decoder = JSONDecoder()

                    do {
                        self.observation = try decoder.decode(Observation.self, from: utf8Data)

                        let encoder = JSONEncoder()
                        if let encodedData = try? encoder.encode(self.observation) {
                            try? encodedData.write(to: fileURL)
                        }
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

