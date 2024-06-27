//
//  HTMLViewModel.swift
//  Ravens
//
//  Created by Eric de Quartel on 27/06/2024.
//

import SwiftUI
import SwiftSoup

class HTMLViewModel: ObservableObject {
    @Published var documents: [HTMLDocument] = []
    @Published var errorMessage: String?

    var Date: String = ""
    
    func speciesScientificNameExists(_ name: String) -> Bool {
        return documents.contains { $0.speciesScientificName == name }
    }
    
    func parseHTMLFromURL() {
        let urlString = "https://waarneming.nl/recent-rarities-content/?species_group=1"
        print("parsing...")
        
        // Ensure the URL is valid
        guard let url = URL(string: urlString) else {
            DispatchQueue.main.async {
                self.errorMessage = "Invalid URL"
            }
            return
        }
        
        // Create a URLSession data task to fetch the HTML content
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            // Check for errors or empty data
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Error fetching HTML from URL: \(error.localizedDescription)"
                }
                return
            }
            
            guard let data = data, let html = String(data: data, encoding: .utf8) else {
                DispatchQueue.main.async {
                    self.errorMessage = "Error converting data to string"
                }
                return
            }
            
            // Parse the HTML content
            do {
                try self.parseHTML(html: html)
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Error parsing HTML: \(error.localizedDescription)"
                }
            }
        }
        
        // Start the network request
        task.resume()
    }

    func parseHTMLFromFile() {
        do {
            guard let path = Bundle.main.path(forResource: "waarneming-rarities", ofType: "html") else {
                throw NSError(domain: "HTMLViewModel", code: 0, userInfo: [NSLocalizedDescriptionKey: "HTML file not found"])
            }
            
            let html = try String(contentsOfFile: path, encoding: .utf8)
            try parseHTML(html: html)
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Error loading HTML from file: \(error.localizedDescription)"
            }
        }
    }
    
    private func parseHTML(html: String) throws {
        let parseDoc = "<html><body><table>" + html + "</table></body></html>"
        let doc: Document = try SwiftSoup.parseBodyFragment(parseDoc)
        
        let rows = try doc.select("tbody tr")
        print(rows.count)
        var parsedDocuments: [HTMLDocument] = []
        
        for row in rows {
            let dateElement = try row.select(".rarity-date")
            let date = try dateElement.text()
            if !date.isEmpty {
                Date = date
            }

            let linkRarityElement = try row.select("td.rarity-date h4 a").first()
            let href = try linkRarityElement?.attr("href") ?? ""
            let rarity = extractRarity(from: href)
            
            let timeElement = try row.select(".rarity-time")
            let time = try timeElement.text()
            
            let speciesCommonNameElement = try row.select(".rarity-species .species-common-name")
            let speciesCommonName = try speciesCommonNameElement.text()
            
            let speciesScientificNameElement = try row.select(".rarity-species .species-scientific-name")
            let speciesScientificName = try speciesScientificNameElement.text()
            
            let linkSpeciesObservations = try row.select(".rarity-species div.truncate span.content a").attr("href")

            let locationElement = try row.select(".rarity-location .content")
            let location = try locationElement.text()
            let linkLocations = try row.select(".rarity-location .content a").attr("href")
            
            let descriptionElement = try row.select(".rarity-icons .far.fa-comment-alt-lines").first()
            let description = try descriptionElement?.attr("title")
            
            let numObservationsElement = try row.select(".rarity-num-observations .badge-primary")
            let numObservations = try numObservationsElement.text()
            
            let numObservationsInt = Int(numObservations) ?? 0
            
            let document = HTMLDocument(
                date: Date,
                time: time,
                linkRarity: "",
                rarity: rarity ?? -2,
                speciesCommonName: speciesCommonName,
                speciesScientificName: speciesScientificName,
                location: location,
                locationId: 0,
                numObservations: numObservationsInt,
                description: description,
                linkSpeciesObservations: linkSpeciesObservations,
                linkLocations: linkLocations
            )
            
            if numObservationsInt > 0 {
                parsedDocuments.append(document)
            }
        }
        
        DispatchQueue.main.async {
            self.documents = parsedDocuments
            self.errorMessage = nil
        }
    }
}

// Function to extract the number after "/species/" from a URL string
func extractSpeciesNumber(from url: String) -> String? {
    if let match = url.range(of: "/species/(\\d+)", options: .regularExpression) {
        let speciesNumber = url[match]
        if let numberRange = speciesNumber.range(of: "\\d+", options: .regularExpression) {
            return String(speciesNumber[numberRange])
        }
    }
    return nil
}

func extractLocationNumber(from url: String) -> String? {
    if let match = url.range(of: "/locations/(\\d+)", options: .regularExpression) {
        let speciesNumber = url[match]
        if let numberRange = speciesNumber.range(of: "\\d+", options: .regularExpression) {
            return String(speciesNumber[numberRange])
        }
    }
    return nil
}

func extractRarity(from url: String) -> Int? {
    let pattern = "rarity=(\\d+)"
    do {
        let regex = try NSRegularExpression(pattern: pattern, options: [])
        let nsString = url as NSString
        let results = regex.matches(in: url, options: [], range: NSRange(location: 0, length: nsString.length))
        
        if let match = results.first {
            let rarityRange = match.range(at: 1)
            let rarityString = nsString.substring(with: rarityRange)
            return Int(rarityString)
        }
    } catch let error {
        print("Invalid regex: \(error.localizedDescription)")
    }
    return nil
}

