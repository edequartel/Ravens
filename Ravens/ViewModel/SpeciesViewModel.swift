//
//  SpeciesViewModel.swift
//  Ravens
//
//  Created by Eric de Quartel on 08/01/2024.
//
// View Model for Species data

import Foundation
import Alamofire
import SwiftyBeaver
import SwiftSoup


class SpeciesViewModel: ObservableObject {
  let log = SwiftyBeaver.self
  @Published var species = [Species]()
  @Published var speciesSecondLanguage = [Species]()

  @Published var errorMessage: String?
  var Date: String = ""

//=================================================
//this one on timer...
  func parseHTMLFromURL(settings: Settings, completion: (() -> Void)? = nil) {
    print("(settings.parseHTMLFromURL)")
    print("groupID \(settings.selectedSpeciesGroupId)")

    let urlString = "https://waarneming.nl/recent-species/?species_group=\(settings.selectedSpeciesGroupId)"
    print("parsing... urlString: \(urlString)")

    // Continue with your URL session or network request setup here
    let headers: HTTPHeaders = [
      "Accept-Language": settings.selectedLanguage
    ]

    AF.request(urlString, headers: headers).responseString { response in
      switch response.result {
      case .success(let html):
        // Parse the HTML content
        do {
          try self.parseHTML(html: html)
          completion?()
        } catch {
          print("Error parsing HTML: \(error.localizedDescription)")
        }

      case .failure(let error):
        print("'Error fetching HTML from URL: \(error.localizedDescription)")

      }
    }
  }
//
  private func parseHTML(html: String) throws {
    let parseDoc = "<html><body><table>" + html + "</table></body></html>"
    let doc: Document = try SwiftSoup.parseBodyFragment(parseDoc)
    let rows = try doc.select("tbody tr")

    for row in rows {
      let dateElement = try row.select(".rarity-date")
      let date = try dateElement.text()
      if !date.isEmpty {
        Date = date
      }

      let timeElement = try row.select(".rarity-time")
      let time = try timeElement.text()
      let speciesScientificNameElement = try row.select(".rarity-species .species-scientific-name")
      let speciesScientificName = try speciesScientificNameElement.text()
      let linkSpeciesObservations = try row.select(".rarity-species div.truncate span.content a").attr("href")
      let numObservationsElement = try row.select(".rarity-num-observations .badge-primary")
      let numObservations = try numObservationsElement.text()
      let numObservationsInt = Int(numObservations) ?? 0
      let index = findSpeciesIndexByScientificName(scientificName: speciesScientificName)

      if let index = index {
        print("found \(speciesScientificName) at index \(index)")
        print("date \(Date) time \(time) numObservations \(numObservationsInt)")
        species[index].date = Date
        species[index].time = time
        species[index].nrof = numObservationsInt
      }
    }
  }
  //===================================================


  func fetchDataFirst(settings: Settings, completion: (() -> Void)? = nil) {
    log.info("SpeciesViewModel fetchDataFirst \(settings.selectedLanguage) groupID \(settings.selectedRegionListId)")
    let url = endPoint(value: settings.selectedInBetween)+"region-lists/\(settings.selectedRegionListId)/species/"


    // Add the custom header 'Accept-Language: nl'
    let headers: HTTPHeaders = [
      "Accept-Language": settings.selectedLanguage
    ]

    AF.request(url, headers: headers).responseDecodable(of: [Species].self){ response in
      // Check if response data exists
      if let data = response.data {
        // Convert data to String and print
        let str = String(data: data, encoding: .utf8)
        self.log.verbose(str ?? "No data")
      }

      switch response.result {
      case .success(_):
        do {
          // Decode the JSON response into an array of Species objects
          let decoder = JSONDecoder()
          self.species = try decoder.decode([Species].self, from: response.data!)
          completion?() // call the completion handler if it exists
//          self.parseHTMLFromURL(settings: settings, completion: {print("parseHTMLFromURL done")})
        } catch {
          self.log.error("Error SpeciesViewModel decoding JSON: \(error)")
        }
      case .failure(let error):
        self.log.error("Error SpeciesViewModel fetching data \(url) \(error)")
      }
    }
  }

  func fetchDataSecondLanguage(settings: Settings, completion: (() -> Void)? = nil) {
    log.info("SpeciesViewModel fetchDataSecondLanguage \(settings.selectedSecondLanguage) groupID \(settings.selectedRegionListId)")

    let url = endPoint(value: settings.selectedInBetween)+"region-lists/\(settings.selectedRegionListId)/species/"

    // Add the custom header 'Accept-Language: nl'
    let headers: HTTPHeaders = [
      "Accept-Language": settings.selectedSecondLanguage
    ]

    AF.request(url, headers: headers).responseDecodable(of: [Species].self){ response in
      // Check if response data exists
      if let data = response.data {
        // Convert data to String and print
        let str = String(data: data, encoding: .utf8)
        self.log.verbose(str ?? "No data")
      }

      switch response.result {
      case .success(_):
        do {
          // Decode the JSON response into an array of Species objects
          let decoder = JSONDecoder()
          self.speciesSecondLanguage = try decoder.decode([Species].self, from: response.data!)
          completion?() // call the completion handler if it exists
        } catch {
          self.log.error("Error SpeciesViewModel decoding JSON: \(error)")
        }
      case .failure(let error):
        self.log.error("Error SpeciesViewModel fetching data \(url) \(error)")
      }
    }
  }


  func findSpeciesByScientificName(scientificName: String) -> Species? {
    return species.first { $0.scientific_name == scientificName }
  }


  func findSpeciesIndexByScientificName(scientificName: String) -> Int? {
      return species.firstIndex { $0.scientific_name == scientificName }
  }

  //    func findSpeciesByID(speciesID: Int) -> Species? {
  func findSpeciesByID(speciesID: Int) -> String? {
    guard let index = species.firstIndex(where: { $0.id == speciesID }) else {
      return nil
    }

    // Check if index is within the range of speciesSecondLanguage array
    guard index < speciesSecondLanguage.count else {
      print("Index is out of range")
      return nil
    }

    return speciesSecondLanguage[index].name
  }


//  func convertToDate(dateString: String, timeString: String) -> Date? {
//    let formatter = DateFormatter()
//    formatter.timeZone = TimeZone.current
//
//    // Check if timeString is empty
//    if timeString.isEmpty {
//      // Use only the date format if time is missing
//      formatter.dateFormat = "yyyy-MM-dd"
//      return formatter.date(from: dateString)
//    } else {
//      // Use date and time format if both are provided
//      formatter.dateFormat = "yyyy-MM-dd HH:mm"
//      let combinedString = "\(dateString) \(timeString)"
//      return formatter.date(from: combinedString)
//    }
//  }

  func sortedSpecies(by sortOption: SortNameOption) -> [Species] {
    switch sortOption {
    case .name:
      return species.sorted { $0.name < $1.name }
    case .scientific_name:
      return species.sorted { $0.scientific_name < $1.scientific_name }
    case .lastSeen:
      return species.sorted { (species1, species2) -> Bool in

//        let doc1 = documents.first { $0.speciesScientificName == species1.scientific_name }
//        let doc2 = documents.first { $0.speciesScientificName == species2.scientific_name }
//
//        if let doc1 = doc1, let doc2 = doc2 {
//          // Convert date and time to Date objects for both documents
//          if let date1 = convertToDate(dateString: doc1.date, timeString: doc1.time),
//             let date2 = convertToDate(dateString: doc2.date, timeString: doc2.time) {
//            // Compare based on the converted Date objects
//            return date1 > date2
//          }
//        } else if doc1 != nil {
//          // Only species1 is in the documents, it should appear before species2
//          return true
//        } else if doc2 != nil {
//          // Only species2 is in the documents, it should appear before species1
//          return false
//        }
//
//        // Neither species is in the documents, fall back to rarity sorting
        return species1.rarity > species2.rarity
      }
    }
  }
}
