import Foundation
import Alamofire
import SwiftyBeaver

class ObsViewModel: ObservableObject {
    let log = SwiftyBeaver.self
    
    @Published var observation: Observation?
    
    private var lastRequestTime: Date?
    
    private var keyChainViewModel =  KeychainViewModel()
    
//    var settings: Settings
//    init(settings: Settings) {
//        log.debug("init ObsViewModel")
//        self.settings = settings
//    }
    
    func fetchData(language: String, for obsID: Int, completion: @escaping () -> Void) {
//        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        ?? uitzoeken waarom dit niet werkt
        let fileManager = FileManager.default
        let obsDirectory = getDocumentsDirectory().appendingPathComponent("obs")
        if !fileManager.fileExists(atPath: obsDirectory.path) {
            try? fileManager.createDirectory(at: obsDirectory, withIntermediateDirectories: true, attributes: nil)
        }
//
        let fileURL = obsDirectory.appendingPathComponent("\(obsID).json")
//        log.error("ObsViewModel \(fileURL)")
        
        log.info("fetchData API Call for ObsViewModel \(obsID) at \(Date())")
        
        let url = endPoint()+"observations/\(obsID)/"
        
        keyChainViewModel.retrieveCredentials()
        
        let headers: HTTPHeaders = [
            "Accept-Language" : language,
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

                        let encoder = JSONEncoder()
                        if let encodedData = try? encoder.encode(self.observation) {
                            try? encodedData.write(to: fileURL)
                        }
                        completion()
                    } catch {
                        self.log.error("Error ObsVichacheewModel decoding JSON: \(error)")
                    }
                }
            case .failure(let error):
                self.log.error("Error ObsViewModel fetching data: \(url) \(headers) - \(error)")
                self.log.error("\(String(describing: response.data))")
            }
        }
    }
    
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
}

