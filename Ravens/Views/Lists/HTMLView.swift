import SwiftUI
import SwiftSoup

struct HTMLDocument {
    let id: UUID = UUID()
    let date: String
    let time: String
    let linkRarity: String
    let rarity: Int
    
    let speciesCommonName: String
    let speciesScientificName: String
    
    let location: String
    let locationId: Int
    
    let numObservations: Int
//    let soundsLink: String?
//    let photosLink: String?
    let description: String?
    
    let linkSpeciesObservations: String
    let linkLocations: String
}

class HTMLViewModel: ObservableObject {
    @Published var documents: [HTMLDocument] = []
    @Published var errorMessage: String?
    

    func parseHTMLFromURL() {
        let urlString = "https://waarneming.nl/recent-rarities-content/?species_group=1"
        
        // Ensure the URL is valid
        guard let url = URL(string: urlString) else {
            self.errorMessage = "Invalid URL"
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
            self.errorMessage = "Error loading HTML from file: \(error.localizedDescription)"
        }
    }
    
    private func parseHTML(html: String) throws {
        let parseDoc = "<html><body><table>" + html + "</table></body></html>"
//        let parseDoc = html
        let doc: Document = try SwiftSoup.parseBodyFragment(parseDoc)
//        let doc: Document = try SwiftSoup.parse(html)
        
//        let rows = try doc.select("tr")
        let rows = try doc.select("tbody tr")
        print(rows.count)
        var parsedDocuments: [HTMLDocument] = []
        
        for row in rows {
            let dateElement = try row.select(".rarity-date")// h4 a")
            let date = try dateElement.text()

                //                        try document.select(".rarity-date h4 a").first()
            let linkRarityElement = try row.select(".rarity-date h4 a").first()
            let linkRarity = try linkRarityElement?.attr("href") ?? ""
            let rarity = "3"
            
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
            
            let numObservationsElement = try row.select(".rarity-num-observations .badge-primary")
            let numObservations = try numObservationsElement.text()
            
            
            let descriptionElement = try row.select(".rarity-icons .far.fa-comment-alt-lines").first()
            let description = try descriptionElement?.attr("title")
            
            let numObservationsInt = Int(numObservations) ?? 0
            
            let document = HTMLDocument(
                date: date,
                time: time,
                linkRarity: linkRarity,
                rarity: Int(rarity) ?? 0,
                speciesCommonName: speciesCommonName,
                speciesScientificName: speciesScientificName,
                location: location,
                locationId: 0,
                numObservations: numObservationsInt,
                description: description,
                linkSpeciesObservations: linkSpeciesObservations,
                linkLocations: linkLocations
            )
            
            parsedDocuments.append(document)
        }
        
        self.documents = parsedDocuments
        self.errorMessage = nil
    }

}



import SwiftUI

struct HTMLView: View {
    @ObservedObject var viewModel: HTMLViewModel

    var body: some View {
        VStack {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            } else {
                List(viewModel.documents, id: \.id) { document in
                    VStack(alignment: .leading) {
                        if !document.date.isEmpty {
                            Text("Date: \(document.date)")
                                .font(.headline)
                        } else {
                            
                            Text("\(document.rarity) \(document.speciesCommonName)")// - \(document.speciesScientificName)")
                                .font(.subheadline)
                                .bold()
                            
                            Text("LinkRarity: \(document.linkRarity)")
                                .font(.subheadline)
                            
                            Text("\(document.time)")
                                .font(.subheadline)
                            
                            Text("Speciesnr: \(extractSpeciesNumber(from: document.linkSpeciesObservations) ?? "noSpeciesNumber")")
                                .font(.subheadline)
                            //                        Text("Location: \(document.location)")
                            //                            .font(.subheadline)
                            Text("Location: \(document.linkLocations)")
                                .font(.subheadline)
                            Text("Location: \(extractLocationNumber(from: document.linkLocations) ?? "noLocationNumber")")
                                .font(.subheadline)
                            Text("Number: \(document.numObservations)")
                                .font(.subheadline)
                            if let description = document.description {
                                Text("\(description)")
                                    .font(.subheadline)
                                    .italic()
                            }
                        }
                    }
                    .padding()
                }
                .listStyle(InsetGroupedListStyle())
            }
        }
        .onAppear {
//            viewModel.parseHTMLFromFile()
            viewModel.parseHTMLFromURL()
        }
        .refreshable {
            viewModel.parseHTMLFromURL()
        }
        .navigationTitle("HTML Data")
    }
    
    // Function to extract the number after "/species/" from a URL string
    func extractSpeciesNumber(from url: String) -> String? {
        // Use regex to find the number after "/species/"
        if let match = url.range(of: "/species/(\\d+)", options: .regularExpression) {
            // Extract the matched string
            let speciesNumber = url[match]
            
            // Extract the number part from the matched string
            if let numberRange = speciesNumber.range(of: "\\d+", options: .regularExpression) {
                return String(speciesNumber[numberRange])
            }
        }
        return nil
    }
    
    func extractLocationNumber(from url: String) -> String? {
        // Use regex to find the number after "/location/"
        if let match = url.range(of: "/locations/(\\d+)", options: .regularExpression) {
            // Extract the matched string
            let speciesNumber = url[match]
            
            // Extract the number part from the matched string
            if let numberRange = speciesNumber.range(of: "\\d+", options: .regularExpression) {
                return String(speciesNumber[numberRange])
            }
        }
        return nil
    }
    
    func getRarityValue(from urlString: String) -> String? {
        // Define the regex pattern to find the 'rarity' parameter
        let pattern = "rarity=([^&]*)"
        
        // Create a regular expression object
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            print("Invalid regex pattern")
            return nil
        }
        
        // Search for matches in the urlString
        let range = NSRange(location: 0, length: urlString.utf16.count)
        if let match = regex.firstMatch(in: urlString, options: [], range: range) {
            // Extract the captured group, which is the value of 'rarity'
            if let rarityRange = Range(match.range(at: 1), in: urlString) {
                let rarityValue = String(urlString[rarityRange])
                return rarityValue
            }
        }
        
        // If no match is found, return nil
        return nil
    }

}

struct HTMLView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = HTMLViewModel()
        HTMLView(viewModel: viewModel)
    }
}
