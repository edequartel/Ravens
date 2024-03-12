////
////  DictionaryView.swift
////  Ravens
////
////  Created by Eric de Quartel on 14/02/2024.
////
//
import SwiftUI
//import SwiftData
//
//// Model
//struct Singer {
//    let id = UUID()
//    let firstName: String
//    let surname: String
//    let song: String
//    let genre: String
//}
//
//// ViewModel
//class SingersViewModel: ObservableObject {
//    @Published var singers: [String: Singer] = [:]
//
//    init() {
//        // Populate the singers dictionary with some sample data
//        singers["Adele"] = Singer(firstName: "Adele", surname: "Adkins", song: "Someone Like You", genre: "Pop")
//        singers["Ed Sheeran"] = Singer(firstName: "Ed", surname: "Sheeran", song: "Shape of You", genre: "Pop")
//        singers["Freddie Mercury"] = Singer(firstName: "Freddie", surname: "Mercury", song: "Bohemian Rhapsody", genre: "Rock")
//    }
//
//    func getSinger(byName name: String) -> Singer? {
//        return singers[name]
//    }
//}
//
//// SwiftUI View
//struct SingersView: View {
//    @StateObject private var viewModel = SingersViewModel()
//    @State private var selectedSingerName: String = ""
//
//    var body: some View {
//        VStack {
//            List(Array(viewModel.singers.keys).sorted(), id: \.self) { singerName in
//                NavigationLink(destination: SingerDetailsView(singer: viewModel.singers[singerName]!)) {
//                    Text(singerName)
//                }
//            }
//            
//            // Display a picker to select a singer
//            Picker("Select a Singer", selection: $selectedSingerName) {
//                ForEach(Array(viewModel.singers.keys).sorted(), id: \.self) { singerName in
//                    Text(singerName)
//                }
//            }
//            .pickerStyle(DefaultPickerStyle())
//            .padding()
//
//            // Display singer information
//            if let selectedSinger = viewModel.getSinger(byName: selectedSingerName) {
//                Text("Name: \(selectedSinger.firstName) \(selectedSinger.surname)")
//                Text("Song: \(selectedSinger.song)")
//                Text("Genre: \(selectedSinger.genre)")
//            } else {
//                Text("Select a singer to view details")
//            }
//        }
//    }
//}
//
//struct SingerDetailsView: View {
//    let singer: Singer
//
//    var body: some View {
//        VStack {
//            Text("Name: \(singer.firstName) \(singer.surname)")
//            Text("Song: \(singer.song)")
//            Text("Genre: \(singer.genre)")
//        }
//        .navigationTitle("\(singer.firstName) \(singer.surname)")
//    }
//}
//
//
//// SwiftUI Preview
//struct SingersView_Previews: PreviewProvider {
//    static var previews: some View {
//        SingersView()
//    }
//}
