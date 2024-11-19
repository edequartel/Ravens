//
//  TestLocationsList.swift
//  Ravens
//
//  Created by Eric de Quartel on 12/06/2024.
//

import Foundation
import SwiftUI
import Alamofire
import MapKit
import Combine
import SwiftyBeaver
import SFSafeSymbols

// MARK: - Model

struct LocationResponse: Codable {
  let count: Int
  let next: String?
  let previous: String?
  let results: [SearchLocation]
}

struct SearchLocation: Codable, Identifiable {
  var id = UUID()
  let locationId: Int
  let name: String
  let countryCode: String
  let permalink: String
  
  enum CodingKeys: String, CodingKey {
    case name, permalink
    case countryCode = "country_code"
    case locationId = "id"
  }
}

// MARK: - ViewModel

class SearchLocationViewModel: ObservableObject {
  @Published var locations: [SearchLocation] = []
  @Published var errorMessage: String?
  
  private var keyChainViewModel = KeychainViewModel()
  private var cancellables = Set<AnyCancellable>()
  
  func fetchLocations(searchString: String, completion: ((Bool) -> Void)? = nil) {
    let url = "https://waarneming.nl/api/v1/locations/?name=\(searchString)"
    let headers: HTTPHeaders = [
      "Authorization": "Token " + keyChainViewModel.token
    ]
    
    print("Fetching locations from: \(url)")
    
    AF.request(url, headers: headers)
      .validate()
      .publishDecodable(type: LocationResponse.self)
      .receive(on: DispatchQueue.main) // Ensure UI updates on the main thread
      .sink { completionEvent in
        if case .failure(let error) = completionEvent {
          self.errorMessage = "Network error: \(error.localizedDescription)"
          completion?(false) // Call completion with failure
        }
      } receiveValue: { response in
        if let locationResponse = response.value {
          self.locations = locationResponse.results
          self.errorMessage = nil
          completion?(true) // Call completion with success
        } else {
          self.errorMessage = "Failed to decode location response"
          completion?(false) // Call completion with failure
        }
      }
      .store(in: &self.cancellables)
  }
}

// MARK: - View

struct SearchLocationView: View {
  let log = SwiftyBeaver.self
  @EnvironmentObject private var areasViewModel: AreasViewModel
  @EnvironmentObject private var settings: Settings
  @EnvironmentObject private var geoJSONViewModel: GeoJSONViewModel
  @EnvironmentObject private var viewModel: SearchLocationViewModel
  
  @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
  
  
  @State private var searchText = ""
  @State private var locationID: Int = 0
  @State private var isFocused: Bool = true
  @State private var isLoading = false // Loading indicator
  @FocusState private var isSearchFieldFocused: Bool
  
  
  var body: some View {
    if showView { Text("SearchLocationView").font(.customTiny) }
    HStack {
        TextField("Search", text: $searchText, onCommit: {
            isLoading = true
            viewModel.fetchLocations(searchString: searchText) { success in
                isLoading = false
                if success {
                    print("Location fetch completed successfully")
                } else {
                    print("Location fetch failed")
                }
            }
        })
        .autocapitalization(.none)
        .disableAutocorrection(true)
        .focused($isSearchFieldFocused) // Bind the focus state here
        .padding(.leading, 30) // Space for the image
        .overlay(
            Image(systemSymbol: .magnifyingglass)
                .foregroundColor(.gray)
                .padding(.leading, 5),
            alignment: .leading
        )
        .padding(10) // Add padding for the content
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray, lineWidth: 1) // Add the border
        )

      //        if isLoading {
      //            ProgressView()
      //                .padding(.trailing, 10) // Add padding to match the layout
      //        }

    }
    .padding(.horizontal) // Adjust spacing from other components
    .onAppear {
        isSearchFieldFocused = true // Set the focus state on appear
    }



    Section() {
      // SwiftUI List
      List(viewModel.locations, id: \.id) { location in
        Button(action: {
          log.info("Location ID set to: \(locationID)")
          log.info("Settings locationName: \(settings.locationName), locationId: \(settings.locationId)")
          
          
          locationID = location.locationId
          settings.locationName = location.name
          settings.locationId = locationID
          
          
          // Trigger geoJSON data fetching and update settings
          geoJSONViewModel.fetchGeoJsonData(
            for: locationID,
            completion: {
              log.error("Selected locationID: \(settings.locationName),\(settings.locationId)")

              log.error("Span: \(geoJSONViewModel.span.latitude),\(geoJSONViewModel.span.longitude)")

              settings.currentLocation = CLLocation(
                latitude: geoJSONViewModel.span.latitude,
                longitude: geoJSONViewModel.span.longitude
              )

              settings.locationCoordinate = CLLocationCoordinate2D(
                latitude: geoJSONViewModel.span.latitude,
                longitude: geoJSONViewModel.span.longitude
              )

              log.error("LocationCoordinate: \(settings.locationCoordinate?.latitude ?? 0) \(settings.locationCoordinate?.longitude ?? 0)")

              settings.isLocationIDChanged = true
              log.info("Latitude: \(geoJSONViewModel.span.latitude), Longitude: \(geoJSONViewModel.span.longitude)")
              
              areasViewModel.appendRecord(
                areaName: location.name,
                areaID: location.locationId,
                latitude: geoJSONViewModel.span.latitude,
                longitude: geoJSONViewModel.span.longitude
              )
              
              
              self.presentationMode.wrappedValue.dismiss()
            }
          )
        }) {
          Text("\(location.name)")// \(location.locationId)")
            .frame(maxWidth: .infinity, alignment: .leading)
        }
      }
    }
  }
}

// MARK: - Preview
struct SearchLocationView_Previews: PreviewProvider {
  static var previews: some View {
    SearchLocationView()
  }
}

