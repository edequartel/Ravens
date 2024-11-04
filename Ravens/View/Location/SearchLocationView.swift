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
  //  let id: Int
  let location_id: Int
  let name: String
  let countryCode: String
  let permalink: String

  enum CodingKeys: String, CodingKey {
    case name, permalink
    case countryCode = "country_code"
    case location_id = "id"
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

  var body: some View {
    if showView { Text("SearchLocationView").font(.customTiny) }
    Form {

      //      VStack {
//      Section(header: Text("Search for a location")) {
        HStack {
          TextField("Search", text: $searchText, onCommit: {
            print("Searching for locations with: \(searchText)")
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
          .textFieldStyle(SearchTextFieldStyle())

          if isLoading {
            ProgressView().padding(.leading, 5) // Visual loading indicator
          }
        }
//      }

      Section(header: Text("Search results")) {


        List(viewModel.locations, id: \.id) { location in
          Button(action: {
            print("Location ID set to: \(locationID)")
            print("Settings locationName: \(settings.locationName), locationId: \(settings.locationId)")

            locationID = location.location_id
            settings.locationName = location.name
            settings.locationId = locationID

            //             Trigger geoJSON data fetching and update settings
            geoJSONViewModel.fetchGeoJsonData(for: locationID) {
              log.error("Selected locationID: \(settings.locationName) \(settings.locationId)")
              settings.currentLocation = CLLocation(
                latitude: geoJSONViewModel.span.latitude,
                longitude: geoJSONViewModel.span.longitude
              )
              settings.locationCoordinate = CLLocationCoordinate2D(
                latitude: geoJSONViewModel.span.latitude,
                longitude: geoJSONViewModel.span.longitude
              )
              log.error("==> locationCoordinate: \(settings.locationCoordinate?.latitude ?? 0) \(settings.locationCoordinate?.longitude ?? 0)")
              settings.isLocationIDChanged = true
              log.info("Latitude: \(geoJSONViewModel.span.latitude), Longitude: \(geoJSONViewModel.span.longitude)")
              self.presentationMode.wrappedValue.dismiss()
            }
          }) {
            Text("\(location.name) \(location.location_id)")
              .frame(maxWidth: .infinity, alignment: .leading)
          }
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


struct SearchTextFieldStyle: TextFieldStyle {
  func _body(configuration: TextField<Self._Label>) -> some View {
    HStack {
      // Add the image inside the TextField
      Image(systemName: "magnifyingglass")
        .foregroundColor(.gray)
        .padding(.leading, 8)
      // Apply the configuration (actual TextField)
      configuration
        .padding(8)
    }
    .background(
      RoundedRectangle(cornerRadius: 8)
        .stroke(Color.gray, lineWidth: 1)
    )
    //.frame(height: 40) // Ensures the height of the custom TextField
  }
}
