//
//  TestLocationsList.swift
//  Ravens
//
//  Created by Eric de Quartel on 12/06/2024.
//

import Foundation
import SwiftUI
import Alamofire
import Combine

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

struct LocationListView: View {
    @EnvironmentObject private var areasViewModel: AreasViewModel
    @EnvironmentObject private var settings: Settings
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @ObservedObject var viewModel = LocationXViewModel()
    
    @State private var searchText = ""
    @State private var locationID: Int = 0

    var body: some View {
        VStack(alignment: .leading) { // Vertically stack the views with alignment to leading edge
            Form {
                TextField("Search", text: $searchText)
                    .onSubmit {
                        viewModel.fetchLocations(searchString: searchText)
                    }
                    .autocapitalization(.none)
//                    .padding(.horizontal) // Add horizontal padding to TextField
                
                Picker("Location", selection: $locationID) {
                    ForEach(viewModel.locations, id: \.id) { location in
                        Text("\(location.name)")// \(location.id)")
                    }
                }
                .pickerStyle(.inline)
//                .padding(.horizontal)  Add horizontal padding to Picker
                .onChange(of: locationID) {
                    print("YYY: \(locationID)")
                    settings.locationName = viewModel.locations.first(where: { $0.id == locationID })?.name ?? ""
                    settings.locationId = locationID
                    settings.isLocationIDChanged = true
                    self.presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
}

// MARK: - Preview

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}

extension String: Identifiable {
    public var id: String { self }
}
