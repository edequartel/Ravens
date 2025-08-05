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
  
  var datum: String = ""

  // Helper function to convert date and time strings into a Date object
  private func convertToDate(dateString: String, timeString: String) -> Date {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm" // Adjust format as per your date-time strings
    return dateFormatter.date(from: "\(dateString) \(timeString)") ?? Date.distantPast
  }

  //
  func fetchDataFirst(settings: Settings, completion: (() -> Void)? = nil) {
    log.info("SpeciesViewModel:")
    log.info(" >selectedSpeciesGroup : \(settings.selectedSpeciesGroup ?? -1)")
    log.info(" >selectedRegionId     : \(settings.selectedRegionId)")
    log.info(" >selectedRegionListId : \(settings.selectedRegionListId)")

    log.info("SpeciesViewModel fetchDataFirst \(settings.selectedLanguage) groupID \(settings.selectedRegionId)")

    let url = endPoint(value: settings.selectedInBetween)+"region-lists/\(settings.selectedRegionListId)/species/"
    log.info(" >url: \(url)")

    // Add the custom header 'Accept-Language: nl'
    let headers: HTTPHeaders = [
      "Accept-Language": settings.selectedLanguage
    ]
    
    AF.request(url, headers: headers).responseDecodable(of: [Species].self) { response in
      // Check if response data exists
      if let data = response.data {
        // Convert data to String and print
        let str = String(data: data, encoding: .utf8)
        self.log.verbose(str ?? "No data")
      }
      
      switch response.result {
      case .success:
        do {
          // Decode the JSON response into an array of Species objects
          let decoder = JSONDecoder()
          self.species = try decoder.decode([Species].self, from: response.data!)
          completion?() // call the completion handler if it exists
          //          self.parseHTMLFromURL(settings: settings, completion: {print("parseHTMLFromURL done")})xxz
        } catch {
          self.log.error("Error 3 SpeciesViewModel decoding JSON: \(error)")
        }
      case .failure(let error):
        self.log.error("Error 4 SpeciesViewModel fetching data \(url) \(error)")
      }
    }
  }
  
  func fetchDataSecondLanguage(settings: Settings, completion: (() -> Void)? = nil) {
    log.info("SpeciesViewModel fetchDataSecondLanguage \(settings.selectedSecondLanguage) groupID \(settings.selectedRegionListId)")

    let url = endPoint(value: settings.selectedInBetween)+"region-lists/\(settings.selectedRegionListId)/species/"
//    let url = endPoint(value: settings.selectedInBetween)+"region-lists/\(settings.selectedRegionListId)/species/"
    log.info(" > url \(url)")

    // Add the custom header 'Accept-Language: nl'
    let headers: HTTPHeaders = [
      "Accept-Language": settings.selectedSecondLanguage
    ]
    
    AF.request(url, headers: headers).responseDecodable(of: [Species].self) { response in
      // Check if response data exists
      if let data = response.data {
        // Convert data to String and print
        let str = String(data: data, encoding: .utf8)
        self.log.verbose(str ?? "No data")
      }
      
      switch response.result {
      case .success:
        do {
          // Decode the JSON response into an array of Species objects
          let decoder = JSONDecoder()
          self.speciesSecondLanguage = try decoder.decode([Species].self, from: response.data!)
          completion?() // call the completion handler if it exists
        } catch {
          self.log.error("Error 1 SpeciesViewModel decoding JSON: \(error)")
        }
      case .failure(let error):
        self.log.error("Error 2 SpeciesViewModel fetching data \(url) \(error)")
      }
    }
  }

  func findSpeciesByScientificName(scientificName: String) -> Species? {
    return species.first { $0.scientificName == scientificName }
  }

  func findSpeciesIndexByScientificName(scientificName: String) -> Int? {
    return species.firstIndex { $0.scientificName == scientificName }
  }
  
  func findSpeciesByID(speciesID: Int) -> String? {
    guard let index = species.firstIndex(where: { $0.speciesId == speciesID }) else {
      return nil
    }
    
    // Check if index is within the range of speciesSecondLanguage array
    guard index < speciesSecondLanguage.count else {
      log.info("Index is out of range")
      return nil
    }
    
    return speciesSecondLanguage[index].name
  }

  // Function to sort species based on the selected sort option
  func sortedSpecies(by sortOption: SortNameOption) -> [Species] {
    switch sortOption {
    case .name:
      return species.sorted { $0.name < $1.name }
    case .scientificName:
      return species.sorted { $0.scientificName < $1.scientificName }
    }
  }
}

extension SpeciesViewModel {
  /// Returns unique SpeciesName objects from any list of Species.
  /// Uniqueness is based on (name, scientificName) combo.
  func uniqueNames(from speciesList: [Species]) -> [SpeciesName] {
    var seen = Set<String>()
    var result: [SpeciesName] = []

    for item in speciesList {
      let key = "\(item.name)-\(item.scientificName)"
      if seen.insert(key).inserted {
        result.append(SpeciesName(commonName: item.name, scientificName: item.scientificName))
      }
    }

    return result
  }
}

extension SpeciesViewModel {
  func filteredSpecies(
    by sortOption: SortNameOption,
    searchText: String,
    filterOption: FilterAllOption,
    rarityFilterOption: FilteringRarityOption,
    isLatest: Bool,
    isBookmarked: Bool,
    isNotificationed: Bool,
    additionalIntArray: BookMarksViewModel,
    additionalNotificationIntArray: NotificationsViewModel
  ) -> [Species] {
    let sortedSpeciesList = sortedSpecies(by: sortOption)

    // Filter by search text if not empty
    var filteredList = searchText.isEmpty ? sortedSpeciesList : sortedSpeciesList.filter { species in
      species.name.lowercased().contains(searchText.lowercased()) ||
      species.scientificName.lowercased().contains(searchText.lowercased())
    }

    // Apply other filters
    filteredList = applyFilter(to: filteredList, with: filterOption)
    filteredList = applyRarityFilter(to: filteredList, with: rarityFilterOption)
    filteredList = applyNotificationFilter(to: filteredList, isNotificationed: isNotificationed, additionalIntArray: additionalNotificationIntArray.records)

    // Apply latest filter
    return applyBookmarkFilter(to: filteredList, isBookmarked: isBookmarked, additionalIntArray: additionalIntArray.records)
  }

  private func applyFilter(to species: [Species], with filterOption: FilterAllOption) -> [Species] {
    switch filterOption {
    case .all:
      return species
    case .native:
      return species.filter { $0.native }
    }
  }

  private func applyRarityFilter(to species: [Species], with filterOption: FilteringRarityOption) -> [Species] {
    switch filterOption {
    case .all:
      return species
    case .common:
      return species.filter { $0.rarity >= 1 }
    case .uncommon:
      return species.filter { $0.rarity >= 2 }
    case .rare:
      return species.filter { $0.rarity >= 3 }
    case .veryRare:
      return species.filter { $0.rarity >= 4 }
    }
  }

  private func applyBookmarkFilter(to species: [Species], isBookmarked: Bool, additionalIntArray: [BookMark]) -> [Species] {
    if isBookmarked {
      return species.filter { species in
        additionalIntArray.contains(where: { $0.speciesID == species.speciesId })
      }
    } else {
      return species
    }
  }

  private func applyNotificationFilter(to species: [Species], isNotificationed: Bool, additionalIntArray: [Notification]) -> [Species] {
    if isNotificationed {
      return species.filter { species in
        additionalIntArray.contains(where: { $0.speciesID == species.speciesId })
      }
    } else {
      return species
    }
  }

}
