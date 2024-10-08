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

// MARK: - Model

struct LocationResponse: Codable {
  let count: Int
  let next: String?
  let previous: String?
  let results: [LocationX]
}

struct LocationX: Codable, Identifiable {
  let id: Int
  let name: String
  let countryCode: String
  let permalink: String

  enum CodingKeys: String, CodingKey {
    case id, name, permalink
    case countryCode = "country_code"
  }
}

// MARK: - ViewModel

class LocationXViewModel: ObservableObject {
  @Published var locations: [LocationX] = []
  @Published var errorMessage: String?

  private var keyChainViewModel =  KeychainViewModel()

  private var cancellables = Set<AnyCancellable>()

  func fetchLocations(searchString: String) {
    let url = "https://waarneming.nl/api/v1/locations/?name=\(searchString)"
    let headers: HTTPHeaders = [
      "Authorization": "Token "+keyChainViewModel.token
    ]

    print("getlocations")

    AF.request(url, headers: headers)
      .validate()
      .publishDecodable(type: LocationResponse.self)
      .sink { completion in
        if case .failure(let error) = completion {
          self.errorMessage = error.localizedDescription
        }
      } receiveValue: { response in
        if let locationResponse = response.value {
          self.locations = locationResponse.results
        } else {
          self.errorMessage = "Failed to fetch locations"
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

  @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

  @ObservedObject var viewModel = LocationXViewModel()

  @State private var searchText = ""
  @State private var locationID: Int = 0
  @State private var isFocused: Bool = true

  var body: some View {
//    NavigationView {
      Form {
        VStack {
          TextField("Search", text: $searchText)
//
//          }, onCommit: {
//            print("onCommit")
//            viewModel.fetchLocations(searchString: searchText)
//          })
//          .autocapitalization(.none)
//          .disableAutocorrection(true)
          //          .textFieldStyle(RoundedBorderTextFieldStyle())
//          .textFieldStyle(SearchTextFieldStyle())
          Button(action: {
            print("search")
            viewModel.fetchLocations(searchString: searchText)
          }) {
            Text("Search")
          }

          Text("\(viewModel.locations.count)")
        }

//        Picker("",selection: $locationID) {
//          ForEach(viewModel.locations, id: \.id) { location in
//            Text("\(location.name)")// \(location.id)")
//          }
//        }
//        .pickerStyle(.inline)
//        .onChange(of: locationID) {
//          settings.locationName = viewModel.locations.first(where: { $0.id == locationID })?.name ?? ""
//          settings.locationId = locationID
//
//          geoJSONViewModel.fetchGeoJsonData(
//            for: locationID,
//            completion: {
//              log.error("locationID \(settings.locationName) \(settings.locationId)")
//              settings.currentLocation = CLLocation(
//                latitude: geoJSONViewModel.span.latitude,
//                longitude: geoJSONViewModel.span.longitude)
//
//              settings.locationCoordinate = CLLocationCoordinate2D( //??
//                latitude: geoJSONViewModel.span.latitude,
//                longitude: geoJSONViewModel.span.longitude)
//              log.error("==> locationCoordinate \(settings.locationCoordinate?.latitude ?? 0) \(settings.locationCoordinate?.longitude ?? 0)")
//              // settings.isAreaChanged = true
//              settings.isLocationIDChanged = true
//              log.info("\(geoJSONViewModel.span.latitude) \(geoJSONViewModel.span.longitude)")
//              self.presentationMode.wrappedValue.dismiss()
//            } )
//        }
//      }
    }
  }
}


//struct SearchTextFieldStyle: TextFieldStyle {
//  func _body(configuration: TextField<Self._Label>) -> some View {
//    HStack {
//      // Add the image inside the TextField
//      Image(systemName: "magnifyingglass")
//        .foregroundColor(.gray)
//        .padding(.leading, 8)
//      // Apply the configuration (actual TextField)
//      configuration
//        .padding(8)
//    }
//    .background(
//      RoundedRectangle(cornerRadius: 8)
//        .stroke(Color.gray, lineWidth: 1)
//    )
//    //.frame(height: 40) // Ensures the height of the custom TextField
//  }
//}


// MARK: - Preview
struct SearchLocationView_Previews: PreviewProvider {
    static var previews: some View {
      SearchLocationView()
    }
}


