//
//  SwiftUIView.swift
//  Ravens
//
//  Created by Eric de Quartel on 14/02/2024.
//

import SwiftUI
import Alamofire

struct LookUpsView: View {
    @StateObject private var viewModel = SpeciesViewModel()

    var body: some View {
        Form() {
            List(viewModel.validationStatusD.values.sorted(by: { $0.name < $1.name })) { category in
                            Text("\(category.name): \(category.isActive ? "Active" : "Inactive")")
                        }

                        List(viewModel.rarityD.values.sorted(by: { $0.name < $1.name })) { category in
                            Text("\(category.name): \(category.isActive ? "Active" : "Inactive")")
                        }
            
            // Display views for each category using viewModel properties
//            Section("Validation Status:")
            List(viewModel.validationStatus) { category in
                Text("\(category.ID) \(category.name)")
            }
            

            List(viewModel.species_type) { category in
                Text("\(category.ID) \(category.name)")
            }

//            Section("Rarity:")
            List(viewModel.rarity) { category in
                Text("\(category.ID) \(category.name)")
            }
            //            Section("Rarity:")
            
            List(viewModel.counting_method) { category in
                Text("\(category.ID) \(category.name)")
            }
            
            List(viewModel.obscurity) { category in
                Text("\(category.ID) \(category.name)")
            }

            // Repeat similar sections for other categories
        }
        .onAppear {
            // Trigger the API request when the view appears
            viewModel.fetchSpeciesData()
        }
//        .padding()
    }
}

// Model
struct SpeciesCategory: Identifiable {
    let id = UUID()
    let ID: String
    let name: String
    let isActive: Bool
}

// ViewModel
class SpeciesViewModel: ObservableObject {
    @Published var validationStatus: [SpeciesCategory] = []
    @Published var rarity: [SpeciesCategory] = []
    @Published var counting_method: [SpeciesCategory] = []
    @Published var species_type: [SpeciesCategory] = []
    @Published var obscurity: [SpeciesCategory] = []
    
    @Published var validationStatusD: [String: SpeciesCategory] = [:]
    @Published var rarityD: [String: SpeciesCategory] = [:]
    @Published var countingMethodD: [String: SpeciesCategory] = [:]
    @Published var speciesTypeD: [String: SpeciesCategory] = [:]
    @Published var obscurityD: [String: SpeciesCategory] = [:]
    

    // Add properties for other categories
    func fetchSpeciesData() {
        let cachePolicy: URLRequest.CachePolicy = .returnCacheDataElseLoad

        AF.request("https://waarneming.nl/api/v1/lookups/")//, cachePolicy: cachePolicy)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success(let data):
                    if let jsonData = data as? [String: Any] {
                        self.validationStatus = self.createSpeciesCategories(from: jsonData["validation_status"])
                        self.rarity = self.createSpeciesCategories(from: jsonData["rarity"])
                        self.counting_method = self.createSpeciesCategories(from: jsonData["counting_method"])
                        self.species_type = self.createSpeciesCategories(from: jsonData["species_type"])
                        self.obscurity = self.createSpeciesCategories(from: jsonData["obscurity"])
                        // Dictionary
                        
                        self.validationStatusD = self.createSpeciesDictionary(from: jsonData["validation_status"])
                        self.rarityD = self.createSpeciesDictionary(from: jsonData["rarity"])
                        self.countingMethodD = self.createSpeciesDictionary(from: jsonData["counting_method"])
                        self.speciesTypeD = self.createSpeciesDictionary(from: jsonData["species_type"])
                        self.obscurityD = self.createSpeciesDictionary(from: jsonData["obscurity"])
                        
                    }
                case .failure(let error):
                    print("Error fetching species data: \(error.localizedDescription)")
                }
            }
    }

    private func createSpeciesDictionary(from data: Any?) -> [String: SpeciesCategory] {
        guard let categoriesData = data as? [[String: Any]] else { return [:] }
        return Dictionary(uniqueKeysWithValues: categoriesData.map { categoryData in
            let category = SpeciesCategory(
                ID: categoryData["id"] as? String ?? "",
                name: categoryData["name"] as? String ?? "",
                isActive: categoryData["is_active"] as? Bool ?? false
            )
            return (category.name, category)
        })
    }
    
    private func createSpeciesCategories(from data: Any?) -> [SpeciesCategory] {
        guard let categoriesData = data as? [[String: Any]] else { return [] }
        return categoriesData.map { categoryData in
            SpeciesCategory(
                ID: categoryData["id"] as? String ?? "",
                name: categoryData["name"] as? String ?? "",
                isActive: categoryData["is_active"] as? Bool ?? false
            )
        }
    }
    

}

#Preview {
    LookUpsView()
}
