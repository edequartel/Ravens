
import SwiftUI
import Alamofire

// MARK: - Data Model

// Enum definitions, similar to those in your original model
enum AnimalSeen: String, Codable {
    case no = "no"
    case unknown = "unknown"
    case yes = "yes"
}

enum En: String, Codable {
    case blackTailedGodwit = "Black-tailed Godwit"
}

enum Gen: String, Codable {
    case limosa = "Limosa"
}

enum Group: String, Codable {
    case birds = "birds"
}

enum Lic: String, Codable {
    case creativecommonsOrgLicensesByNc40 = "//creativecommons.org/licenses/by-nc/4.0/"
    // Add other cases as required
}

enum Method: String, Codable {
    case fieldRecording = "field recording"
    case inTheHand = "in the hand"
}

struct Osci: Codable {
    let small, med, large, full: String?
}

enum Q: String, Codable {
    case a = "A"
    case b = "B"
    case c = "C"
}

enum Sex: String, Codable {
    case empty = ""
    case female = "female"
    case male = "male"
    case uncertain = "uncertain"
}

enum SP: String, Codable {
    case limosa = "Limosa"
}

enum Stage: String, Codable {
    case adult = "adult"
    case juvenile = "juvenile"
    case uncertain = "uncertain"
}

struct Recording: Codable {
    let id: String?
    let gen: Gen?
    let sp, ssp: SP?
    let group: Group?
    let en: En?
    let rec, cnt, loc: String?
    let lat, lng: String?
    let alt, type: String?
    let sex: Sex?
    let stage: Stage?
    let method: Method?
    let url: String?
    let file: String?
    let fileName: String?
    let sono, osci: Osci?
    let lic: Lic?
    let q: Q?
    let length, time, date, uploaded: String?
    let also: [String]?
    let rmk: String?
    let birdSeen, animalSeen, playbackUsed: AnimalSeen?
    let temp, regnr: String?
    let auto: AnimalSeen?
    let dvc, mic, smp: String?
}

struct Santo: Codable {
    let numRecordings, numSpecies: String?
    let page, numPages: Int?
    let recordings: [Recording]?
}

// MARK: - ViewModel

class SantoViewModel: ObservableObject {
    @Published var santo: Santo?
    @Published var isLoading = false

    func loadSantoData(from url: String) {
        isLoading = true
        AF.request(url).responseDecodable(of: Santo.self) { [weak self] response in
          print(response.data)
            DispatchQueue.main.async {
                self?.isLoading = false
                switch response.result {
                case .success(let data):
                    self?.santo = data
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
    }
}

// MARK: - SwiftUI View

struct SantoView: View {
    @StateObject private var viewModel = SantoViewModel()

    var body: some View {
        NavigationView {
            if viewModel.isLoading {
                ProgressView("Loading...")
            } else {
                List {
                    if let santo = viewModel.santo, let recordings = santo.recordings {
                        ForEach(recordings, id: \.id) { recording in
                            VStack(alignment: .leading) {
                                Text(recording.en?.rawValue ?? "Unknown Bird")
                                    .font(.headline)
                                Text("Recorded at: \(recording.loc ?? "Unknown location")")
                                    .font(.subheadline)
                            }
                        }
                    } else {
                        Text("No recordings available")
                    }
                }
                .navigationTitle("Recordings")
            }

        }
        .onAppear {
            viewModel.loadSantoData(from: "https://xeno-canto.org/api/2/recordings?query=limosa+limosa")
        }
    }
}

// MARK: - SwiftUI App Entry Point

//@main
//struct MyApp: App {
//    var body: some Scene {
//        WindowGroup {
//            SantoView()
//        }
//    }
//}

///
////  xanto.swift
////  Ravens
////
////  Created by Eric de Quartel on 28/08/2024.
////
//
//import Foundation
//import SwiftUI
//import Alamofire
//import Combine
//
//struct ApiResponse1: Decodable {
//    var numRecordings: String
//    var numSpecies: String
//    var page: Int
//    var numPages: Int
//    var recordings: [Recording]
//}
//
//struct Recording: Decodable, Identifiable {
//    var id: String
//    var gen: String
//    var sp: String
//    var ssp: String
//    var group: String
//    var en: String
//    var rec: String
//    var cnt: String
//    var loc: String
//    var lat: String
//    var lng: String
//    var alt: String
//    var type: String
//    var sex: String
//    var stage: String
//    var method: String
//    var url: String
//    var file: String
//    var filename: String?
//    var sono: SonoImages
//    var osci: SonoImages
//    var lic: String
//    var q: String
//    var length: String
//    var time: String
//    var date: String
//    var uploaded: String
//    var also: [String]
//    var rmk: String
//    var birdseen: String
//    var animalseen: String
//    var playbackused: String
//    var temp: String
//    var regnr: String
//    var auto: String
//    var dvc: String
//    var mic: String
//    var smp: String
//
//
//
////    enum CodingKeys: String, CodingKey {
////        case id, gen, sp, ssp, group, en, rec, cnt, loc, lat, lng, alt, type, sex, stage, method, url, file, sono, osci, lic, q, length, time, date, uploaded, also, rmk, birdSeen = "bird-seen", animalSeen = "animal-seen", playbackUsed = "playback-used", temp, regnr, auto, dvc, mic, smp
////        case fileName = "file-name"
////    }
//}
//
//struct SonoImages: Decodable {
//    var small: String
//    var med: String
//    var large: String
//    var full: String?
//}
//
//
//
//class RecordingsViewModel: ObservableObject {
//    @Published var recordings = [Recording]()
//    @Published var isLoading = false
//
//    func fetchRecordings(query: String) {
//        isLoading = true
//        let urlString = "https://xeno-canto.org/api/2/recordings?query=limosa+limosa"
//
//        AF.request(urlString).responseDecodable(of: ApiResponse1.self) { [weak self] response in
//            self?.isLoading = false
//          print(response.result)
////            switch response.result {
////            case .success(let data):
////                self?.recordings = data.recordings
////                print("Recordings: \(data.recordings)")
////
////                // Loop through each recording and print its details
////                for recording in data.recordings {
////                    print("Recording: \(recording)")
////                }
////
////            case .failure(let error):
////                print(">>>>"+error.localizedDescription)
////            }
//        }
//    }
//}
//
//
//struct RecordingsView: View {
//    @StateObject private var viewModel = RecordingsViewModel()
//
//    var body: some View {
//        NavigationView {
//            List(viewModel.recordings) { recording in
//                VStack(alignment: .leading) {
//                    Text(recording.en)
//                    Text(recording.loc)
//                    Text("Date: \(recording.date)")
//                }
//            }
//            .navigationBarTitle("Recordings")
//            .onAppear {
//                viewModel.fetchRecordings(query: "buteo+buteo")
//            }
//        }
//    }
//}
