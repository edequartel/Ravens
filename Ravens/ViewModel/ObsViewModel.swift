import Foundation
import Alamofire
import SwiftyBeaver

// deze niet verwijderen is zonder cache
// class ObsViewModel: ObservableObject {
//    let log = SwiftyBeaver.self
//    @Published var observation: Observation?
//    private var keyChainViewModel =  KeychainViewModel()
//    
//  func fetchData(settings: Settings, for obsID: Int, token: String, completion: @escaping () -> Void) {
//        log.info("fetchData API Call for ObsViewModel \(obsID) at \(Date())")
//        
//        let url = endPoint(value: settings.selectedInBetween)+"observations/\(obsID)/"
//        
//        let headers: HTTPHeaders = [
//            "Accept-Language": settings.selectedLanguage,
//            "Authorization": "Token " + token
//        ]
//        
//        log.info("ObsViewModel url: \(url) \(headers)")
//        
//        AF.request(url, headers: headers).responseData { response in
//            switch response.result {
//            case .success(let data):
//                if let utf8Data = String(data: data, encoding: .isoLatin1)?.data(using: .utf8) {
//                    let decoder = JSONDecoder()
//
//                    do {
//                        self.observation = try decoder.decode(Observation.self, from: utf8Data)
//                        completion()
//                    } catch {
//                        self.log.error("Error ObsViewModel decoding JSON: \(error)")
//                    }
//                }
//            case .failure(let error):
//                self.log.error("Error ObsViewModel fetching data: \(url) \(headers) - \(error)")
//                self.log.error("\(String(describing: response.data))")
//            }
//        }
//    }
// }

// ?? cache
class ObsViewModel: ObservableObject {
    let log = SwiftyBeaver.self
    @Published var observation: Observation?
    private var keyChainViewModel = KeychainViewModel()

    // MARK: - Cache using (obsID, language) as key
    private var observationCache: [String: Observation] = [:]

    func fetchData(settings: Settings, for obsID: Int, token: String, completion: @escaping () -> Void) {
        log.info("fetchData called for ObsViewModel \(obsID) at \(Date())")

        let language = settings.selectedLanguage
        let cacheKey = "\(language)_\(obsID)"

        // Check cache first
        if let cachedObservation = observationCache[cacheKey] {
            log.info("Loaded observation \(obsID) from cache for language \(language)")
            self.observation = cachedObservation
            completion()
            return
        }

        // Otherwise, fetch from API
        let url = endPoint(value: settings.selectedInBetween) + "observations/\(obsID)/"
        let headers: HTTPHeaders = [
            "Accept-Language": language,
            "Authorization": "Token " + token
        ]

        log.info("ObsViewModel API request to: \(url) with headers: \(headers)")

        AF.request(url, headers: headers).responseData { response in
            switch response.result {
            case .success(let data):
                if let utf8Data = String(data: data, encoding: .isoLatin1)?.data(using: .utf8) {
                    let decoder = JSONDecoder()
                    do {
                        let decodedObservation = try decoder.decode(Observation.self, from: utf8Data)
                        self.observation = decodedObservation
                        self.observationCache[cacheKey] = decodedObservation // Cache it
                        completion()
                    } catch {
                        self.log.error("Error decoding Observation JSON: \(error)")
                    }
                }
            case .failure(let error):
                self.log.error("Error fetching Observation data: \(error)")
                if let responseData = response.data {
                    self.log.error("Response data: \(String(decoding: responseData, as: UTF8.self))")
                }
            }
        }
    }
}
