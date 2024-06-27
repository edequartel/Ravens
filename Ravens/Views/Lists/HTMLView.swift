import SwiftUI

struct HTMLView: View {
    @EnvironmentObject var viewModel: HTMLViewModel

    var body: some View {
        NavigationView{
            VStack {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                } else {
                    List {
                        // Group the documents by date
                        ForEach(groupedDocuments, id: \.key) { date, documents in
                            Section(header: Text(date)) {
                                ForEach(documents) { document in
                                    VStack(alignment: .leading) {
                                        HStack {
                                            if !(document.linkSpeciesObservations.isEmpty) {
                                                Image(systemName: SFObservation)
                                                    .foregroundColor(.obsObservation)
                                            }
                                            Text("\(document.speciesCommonName) - \(document.time) - \(document.numObservations)x")
                                                .font(.subheadline)
                                                .bold()
                                            Spacer()
                                        }
                                        
                                        //                                    Text("\(document.speciesScientificName)")
                                        //                                        .font(.subheadline)
                                        //                                        .foregroundColor(.gray)
                                        
                                        Text("\(document.location)")
                                            .font(.subheadline)
                                        
                                        //                                    if !(document.linkSpeciesObservations.isEmpty) {
                                        //                                        Text("Species: \(extractSpeciesNumber(from: document.linkSpeciesObservations) ?? "")")
                                        //                                            .font(.subheadline)
                                        //                                    }
                                        ////
                                        //                                    if !document.linkLocations.isEmpty {
                                        //                                        Text("Location: \(extractLocationNumber(from: document.linkLocations) ?? "")")
                                        //                                            .font(.subheadline)
                                        //                                    }
                                        ////
                                        //                                    if let description = document.description {
                                        //                                        Text("\(description)")
                                        //                                            .font(.subheadline)
                                        //                                            .italic()
                                        //                                    }
                                    }
                                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                        
                                        if !(document.linkSpeciesObservations.isEmpty) {
                                            Button(action: {
                                                if let url = URL(string: "https://waarneming.nl/" + document.linkSpeciesObservations) {
                                                    // Use the URL here
                                                    print(url)
                                                    UIApplication.shared.open(url)
                                                } else {
                                                    // Handle the invalid URL case here
                                                    print("Invalid URL")
                                                }
                                            }) {
                                                Image(systemName: SFObservation)
                                            }
                                            .tint(.obsObservation)
                                            .accessibility(label: Text("Open observation"))
                                        }
                                        
                                    }
                                    
                                    //                                .padding()
                                }
                            }
                            .font(.headline)
//                            .foregroundColor(color: .obsArea)
                        }
                    }
//                    .listStyle(InsetGroupedListStyle())
                    .listStyle(PlainListStyle())
                }
            }
            .onAppear {
                viewModel.parseHTMLFromURL()
            }
            .refreshable {
                viewModel.parseHTMLFromURL()
            }
            .navigationTitle("Recent")
            .navigationBarTitleDisplayMode(.inline)
            
        }

            
    }

    // Computed property to group documents by date
    private var groupedDocuments: [(key: String, value: [HTMLDocument])] {
        let grouped = Dictionary(grouping: viewModel.documents, by: { $0.date })
        return grouped.sorted(by: { $0.key > $1.key })
    }
}

struct HTMLView_Previews: PreviewProvider {
    static var previews: some View {
        HTMLView()
    }
}
