//
//  ObservationsYearViewModel.swift
//  Ravens
//
//  Created by Eric de Quartel on 18/01/2024.
//

import Foundation
import Alamofire
import MapKit
import SwiftyBeaver

class ObservationsYearViewModel: ObservableObject {
    let log = SwiftyBeaver.self
    @Published var observationsSpecies: Observations?
    @Published var months: [Int] = [0,0,0, 0,0,0, 0,0,0, 0,0,0]
    private var maanden: [Int] = [0,0,0, 0,0,0, 0,0,0, 0,0,0]
    
    private var keyChainViewModel =  KeychainViewModel()
    
    
    func fetchMonthData(language: String, speciesId: Int) {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let folderURL = documentsURL.appendingPathComponent("countObservations")
        var count = 0
        
        log.error(folderURL)
        let fileURL = folderURL.appendingPathComponent("\(speciesId).json")
        
        //        if false { 
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                log.error("filexists")
                let jsonData = try Data(contentsOf: fileURL)
                if let dataDict = try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as? [String: Any] {
                    log.error("Loaded data from file: \(dataDict)")
                    if let loadedMonths = dataDict["months"] as? [Int] {
                        self.months = loadedMonths
                    } else {
                        log.error("Failed to decode months array from JSON data.")
                    }
                } else {
                    log.error("Failed to decode JSON data.")
                }
            } catch {
                log.error("Failed to load data from file: \(error)")
            }
        } else {
            log.error("file does not exists")
            
            
            for m in 1...12 {
                let monthString = String(format: "%02d", m)
                let daystring = String(format: "%02d", numberOfDaysInMonth(year: 2023, month: m) ?? 0)
//                print("\(m) \(daystring)")
                fetchData(language: language, speciesId: speciesId, date_after: "2023-\(monthString)-01", date_before: "2023-\(monthString)-\(daystring)") { (value) in
                    count = count + 1
                    self.log.error("count \(count)")
                    self.log.error("\(monthString) : value: \(value)")
                    self.maanden[m-1] = (value) //deze waarde later meenemen
//                    self.months[m-1] = (value)
                    
                    if count == 12 {
                        self.months = self.maanden
                        
                        let dataDict: [String: Any] = [
                            "months": self.months,
                            "date_after": "2023-\(monthString)-01",
                            "date_before": "2023-\(monthString)-28"
                        ]
                        
                        guard let jsonData = try? JSONSerialization.data(withJSONObject: dataDict, options: .prettyPrinted) else {
                            self.log.error("Failed to create JSON data.")
                            return
                        }
                        
                        do {
                            if !FileManager.default.fileExists(atPath: folderURL.path) {
                                try FileManager.default.createDirectory(atPath: folderURL.path, withIntermediateDirectories: true, attributes: nil)
                            }
                        } catch {
                            self.log.error("Failed to create directory: \(error.localizedDescription)")
                        }
                        
                        do {
                            try jsonData.write(to: fileURL)
                            self.log.info("Successfully saved data to \(fileURL)")
                        } catch {
                            self.log.error("Failed to write JSON data: \(error.localizedDescription)")
                        }
                        
                        
                        //                        self.maanden[m-1] = (value) //deze waarde later meenemen

                    }
                }
            }
        }
    }
    
    func numberOfDaysInMonth(year: Int, month: Int) -> Int? {
        let calendar = Calendar.current
        let components = DateComponents(year: year, month: month)
        
        guard let date = calendar.date(from: components),
            let range = calendar.range(of: .day, in: .month, for: date) else {
            return nil
        }
        
        return range.count
    }
    
    func deleteFilesInFolder() {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let folderURL = documentsURL.appendingPathComponent("countObservations")
        
        let fileManager = FileManager.default
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil)
            for fileURL in fileURLs {
                try fileManager.removeItem(at: fileURL)
            }
        } catch {
            // Handle the error
            print("Error while deleting files: \(error)")
        }
    }
    
    func fetchData(language: String, speciesId: Int, date_after: String, date_before: String, completion: @escaping (Int) -> Void) {
        log.error("fetchData ObservationsYearViewModel - speciesID \(speciesId)")
        keyChainViewModel.retrieveCredentials()
        
        // Add the custom header
        let headers: HTTPHeaders = [
            "Authorization": "Token "+keyChainViewModel.token,
            "Accept-Language": language
        ]
        
        let url = endPoint() + "species/\(speciesId)/observations/?date_after=\(date_after)&date_before=\(date_before)&limit=100&offset=0"
        
        log.info("url \(url)")
        
        AF.request(url, headers: headers).responseString { response in
            switch response.result {
            case .success(let stringResponse):
                if let data = stringResponse.data(using: .utf8) {
                    do {
                        let decoder = JSONDecoder()
                        let observationsSpecies = try decoder.decode(Observations.self, from: data)
                        DispatchQueue.main.async {
                            let value = observationsSpecies.count ?? 0
                            completion(value)
                        }
                    } catch {
                        self.log.error("Error ObservationsYearViewModel decoding JSON: \(error)")
                        //                        self.log.error("\(url)")
                    }
                }
            case .failure(let error):
                self.log.error("Error ObservationsYearViewModel: \(error)")
            }
        }
    }
}
