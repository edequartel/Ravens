import SwiftUI

//struct HTMLView: View {
////    @EnvironmentObject var viewModel: HTMLViewModel
//  
//  @State private var selectedSpeciesID: Int?
//
//  var body: some View {
//    NavigationView{
//      VStack {
//        if let errorMessage = viewModel.errorMessage {
//          Text(errorMessage)
//            .foregroundColor(.red)
//            .padding()
//        } else {
//          List {
//            // Group the documents by date
//            ForEach(groupedDocuments, id: \.key) { date, documents in
//              Section(header: Text(date)) {
//                ForEach(documents) { document in
//                    DocumentView(document: document)
//                  .swipeActions(edge: .trailing, allowsFullSwipe: false) {
//                    OpenObservationButton(linkSpeciesObservations: document.linkSpeciesObservations)
//                  }
//                }
//              }
//              .font(.headline)
//            }
//          }
//          //                    .listStyle(InsetGroupedListStyle())
//          .listStyle(PlainListStyle())
//        }
//      }
//      .onAppear {
//        viewModel.parseHTMLFromURL(settings: Settings())
//      }
//      .refreshable {
//        print("refreshed")
//        viewModel.parseHTMLFromURL(settings: Settings())
//      }
//      .navigationTitle("Recent")
//      .navigationBarTitleDisplayMode(.inline)
//    }
//  }
//
//    // Computed property to group documents by date
//    private var groupedDocuments: [(key: String, value: [HTMLDocument])] {
//        let grouped = Dictionary(grouping: viewModel.documents, by: { $0.date })
//        return grouped.sorted(by: { $0.key > $1.key })
//    }
//}

//struct DocumentView: View {
//    var document: HTMLDocument // Replace DocumentType with the actual type of your document
//
//    var body: some View {
//          VStack(alignment: .leading) {
//            HStack {
////              Image(systemName: "circle.fill")
////                .foregroundColor(RarityColor(value: document.rarity))
////              Text("\(document.speciesCommonName)")
////                .bold()
////              Text("\(document.numObservations)x")
////                .bold()
////              Spacer()
//              Text("\(document.date)")
//                .bold()
//              Text("\(document.time)")
//                .bold()
//            }
//            Text("\(document.speciesScientificName)")
//              .italic()
////            HStack {
//////              Text("\(document.date)")
////              Text("\(document.time)")
////            }
//          }
//          .font(.subheadline)
//    }
//}

//struct OpenObservationButton: View {
//    // Input property to accept the species observation link
//    let linkSpeciesObservations: String
//
//    var body: some View {
//        Button(action: openObservationLink) {
//            Image(systemName: SFObservation)
//        }
//        .tint(.obsObservation)
//        .accessibility(label: Text("Open observation"))
//    }
//
//    // Function to handle URL opening
//    private func openObservationLink() {
//        let baseURL = "https://waarneming.nl/"
//        if let url = URL(string: baseURL + linkSpeciesObservations) {
//            print("Opening URL: \(url)")
//            UIApplication.shared.open(url)
//        } else {
//            print("Invalid URL")
//        }
//    }
//}

//struct HTMLView_Previews: PreviewProvider {
//    static var previews: some View {
//        HTMLView()
//    }
//}




//{ document in
//  VStack(alignment: .leading) {
//    Text("Name: \(document.speciesCommonName)" )
//    Text("Scientfic: \(document.speciesScientificName)")
//    Text("Time: \(document.time)")
//    Text("Date: \(document.date)")
//    Text("Num: \(document.numObservations)x")
//    Text("Location: \(document.location)")
//    Text("LocationId: \(document.locationId)")
//    Divider()
//    Text("Descr: \(document.description ?? "")")
//    Text("Rarity: \(document.rarity)?")
//    Text("LinkObs: \(document.linkSpeciesObservations)?")
////                                  .Color(.blue)
//    Text("LinkLoc: \(document.linkLocations)")
////                                  .Color(.gray)
//    Text("Linkrarity: \(document.linkRarity)?")
//  }
//
//  .font(.subheadline)
//
//
//  .swipeActions(edge: .trailing, allowsFullSwipe: false) {
//
//    if !(document.linkSpeciesObservations.isEmpty) {
//      Button(action: {
//        if let url = URL(string: "https://waarneming.nl/" + document.linkSpeciesObservations) {
//          // Use the URL here
//          print(url)
//          UIApplication.shared.open(url)
//        } else {
//          // Handle the invalid URL case here
//          print("Invalid URL")
//        }
//      }) {
//        Image(systemName: SFObservation)
//      }
//      .tint(.obsObservation)
//      .accessibility(label: Text("Open observation"))
//    }
//
//  }
//}

//            Text("Location: \(document.location)")
//            Text("LocationId: \(document.locationId)")
//            Text("Descr: \(document.description ?? "")")

//            Text("LinkObs/Species: \(document.linkSpeciesObservations)")
//            Text("Species: \(extractSpeciesNumber(from: document.linkSpeciesObservations) ?? "")")
//              .foregroundColor(.blue)
//            Text("LinkLoc: \(document.linkLocations)")
//              .foregroundColor(.gray)
//            Text("Linkrarity: \(document.linkRarity)")
//              .foregroundColor(.green)
