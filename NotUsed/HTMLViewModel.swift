////
////  HTMLViewModel.swift
////  Ravens
////
////  Created by Eric de Quartel on 27/06/2024.
////
//
//import SwiftUI
//import SwiftSoup
//import Alamofire
//
//class HTMLViewModel: ObservableObject {
//  @Published var documents: [HTMLDocument] = []
//  @Published var errorMessage: String?
//
//  var Date: String = ""
//
////  func findDocument(withScientificName scientificName: String) -> HTMLDocument? {
////      return documents.first(where: { $0.speciesScientificName == scientificName })
////  }
//
//
////  func speciesScientificNameExists(_ name: String) -> Bool {
////    return documents.contains { $0.speciesScientificName == name }
////  }
//
//  func parseHTMLFromURL(settings: Settings, completion: (() -> Void)? = nil) {
//    print("(settings.parseHTMLFromURL)")
//    print("groupID \(settings.selectedSpeciesGroupId)")
//
//    let urlString = "https://waarneming.nl/recent-species/?species_group=\(settings.selectedSpeciesGroupId)"
//    print("parsing... urlString: \(urlString)")
//
//    // Continue with your URL session or network request setup here
//    let headers: HTTPHeaders = [
//      "Accept-Language": settings.selectedLanguage
//    ]
//
//    AF.request(urlString, headers: headers).responseString { response in
//      switch response.result {
//      case .success(let html):
//        // Parse the HTML content
//        do {
//          try self.parseHTML(html: html)
//          completion?()
//        } catch {
//          print("Error parsing HTML: \(error.localizedDescription)")
//        }
//
//      case .failure(let error):
//        print("'Error fetching HTML from URL: \(error.localizedDescription)")
//
//      }
//    }
//  }
//
//  func parseHTMLFromFile() {
//    do {
//      guard let path = Bundle.main.path(forResource: "waarneming-rarities", ofType: "html") else {
//        throw NSError(domain: "HTMLViewModel", code: 0, userInfo: [NSLocalizedDescriptionKey: "HTML file not found"])
//      }
//
//      let html = try String(contentsOfFile: path, encoding: .utf8)
//      try parseHTML(html: html)
//    } catch {
//      DispatchQueue.main.async {
//        self.errorMessage = "Error loading HTML from file: \(error.localizedDescription)"
//      }
//    }
//  }
//
//  private func parseHTML(html: String) throws {
//    let parseDoc = "<html><body><table>" + html + "</table></body></html>"
//    let doc: Document = try SwiftSoup.parseBodyFragment(parseDoc)
//
//    let rows = try doc.select("tbody tr")
//    var parsedDocuments: [HTMLDocument] = []
//
//    for row in rows {
//      let dateElement = try row.select(".rarity-date")
//      let date = try dateElement.text()
//      if !date.isEmpty {
//        Date = date
//      }
//
//      let timeElement = try row.select(".rarity-time")
//      let time = try timeElement.text()
//
//      let speciesScientificNameElement = try row.select(".rarity-species .species-scientific-name")
//      let speciesScientificName = try speciesScientificNameElement.text()
//
//      let linkSpeciesObservations = try row.select(".rarity-species div.truncate span.content a").attr("href")
//
//      let numObservationsElement = try row.select(".rarity-num-observations .badge-primary")
//      let numObservations = try numObservationsElement.text()
//      let numObservationsInt = Int(numObservations) ?? 0
//
//      let document = HTMLDocument(
//        date: Date,
//        time: time,
//        speciesScientificName: speciesScientificName,
//        linkSpeciesObservations: linkSpeciesObservations,
//        numObservations: numObservationsInt
//      )
//
//      if numObservationsInt > 0 {
//        parsedDocuments.append(document)
//      }
//    }
//
//    self.documents = parsedDocuments
//  }
//}
//
//// Function to extract the number after "/species/" from a URL string
//func extractSpeciesNumber(from url: String) -> String? {
//  if let match = url.range(of: "/species/(\\d+)", options: .regularExpression) {
//    let speciesNumber = url[match]
//    if let numberRange = speciesNumber.range(of: "\\d+", options: .regularExpression) {
//      return String(speciesNumber[numberRange])
//    }
//  }
//  return nil
//}
//
//func extractLocationNumber(from url: String) -> String? {
//  if let match = url.range(of: "/locations/(\\d+)", options: .regularExpression) {
//    let speciesNumber = url[match]
//    if let numberRange = speciesNumber.range(of: "\\d+", options: .regularExpression) {
//      return String(speciesNumber[numberRange])
//    }
//  }
//  return nil
//}
//
//func extractRarity(from url: String) -> Int? {
//  let pattern = "rarity=(\\d+)"
//  do {
//    let regex = try NSRegularExpression(pattern: pattern, options: [])
//    let nsString = url as NSString
//    let results = regex.matches(in: url, options: [], range: NSRange(location: 0, length: nsString.length))
//
//    if let match = results.first {
//      let rarityRange = match.range(at: 1)
//      let rarityString = nsString.substring(with: rarityRange)
//      return Int(rarityString)
//    }
//  } catch let error {
//    print("Invalid regex: \(error.localizedDescription)")
//  }
//  return nil
//}
//
//// Custom error type
//enum ExtractionError: Error, LocalizedError {
//    case noNumberFound
//
//    var errorDescription: String? {
//        switch self {
//        case .noNumberFound:
//            return "No number was found in the provided string."
//        }
//    }
//}
//
//func extractInteger(from string: String) throws -> Int {
//    let pattern = "\\d+"  // Regular expression pattern to match digits
//    if let range = string.range(of: pattern, options: .regularExpression) {
//        let numberString = String(string[range])
//        if let number = Int(numberString) {
//            return number  // Convert to an integer and return
//        }
//    }
//    throw ExtractionError.noNumberFound  // Throw error if no number is found
//}
//
//func getFirstInteger(from string: String) -> Int? {
//    // Define a regular expression pattern to find integers
//    let pattern = "\\d+"
//
//    // Try to create the regex object
//    guard let regex = try? NSRegularExpression(pattern: pattern) else {
//        return nil
//    }
//
//    // Perform the regex search on the input string
//    let range = NSRange(location: 0, length: string.utf16.count)
//    if let match = regex.firstMatch(in: string, options: [], range: range) {
//        // Extract the matched substring
//        if let matchRange = Range(match.range, in: string) {
//            let matchedString = String(string[matchRange])
//            return Int(matchedString)
//        }
//    }
//    return nil
//}
//