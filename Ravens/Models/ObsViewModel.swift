import Foundation
import Alamofire
import SwiftyBeaver

class FetchRequestManager: ObservableObject {
    private var currentDelay: Double = 0
    private var resetDelayTimer: Timer?
    private let delayIncrement: Double = 0.1 // Time in seconds to wait before each request
    private let resetDelayTime: TimeInterval = 2.0 // Time in seconds to wait before resetting delay
    
    let log = SwiftyBeaver.self
    
    func fetchDataAfterDelay(for obsID: Int, by viewModel: ObsViewModel) {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent("CachedObs\(obsID).json")
        let decoder = JSONDecoder()
        
        if let data = try? Data(contentsOf: fileURL), let loadedObs = try? decoder.decode(Observation.self, from: data) {
            viewModel.observation = loadedObs
            log.info("\(obsID) loaded from cache")
            return
        } else {
            // Invalidate existing timer since we're making a new request
            resetDelayTimer?.invalidate()
            DispatchQueue.main.asyncAfter(deadline: .now() + currentDelay) {
                viewModel.fetchData(for: obsID)
            }
            currentDelay += delayIncrement // Increase delay for next request
            // Reset currentDelay after a specified period without new requests
            resetDelayTimer = Timer.scheduledTimer(withTimeInterval: resetDelayTime, repeats: false) { [weak self] _ in
                self?.currentDelay = 0
            }
        }
    }
}

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
    
    func fetchData(for obsID: Int) {
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
        
        AF.request(url, headers: headers).responseDecodable(of: Observation.self) { response in
            switch response.result {
            case .success(_):
                do {
                    let decoder = JSONDecoder()
                    
                    self.observation = try decoder.decode(Observation.self, from: response.data!)
                    
                    
                    let encoder = JSONEncoder()
                    if let encodedData = try? encoder.encode(self.observation) {
                        try? encodedData.write(to: fileURL)
                        
                    }
                } catch {
                    self.log.error("Error ObsViewModel decoding JSON: \(error)")
                }
            case .failure(let error):
                self.log.error("Error ObsViewModel fetching data: \(url) \(headers) - \(error)")
                self.log.error("\(String(describing: response.data))")
            }
        }
    }
}

