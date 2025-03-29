////
////  MapsView.swift
////  Ravens
////
////  Created by Eric de Quartel on 28/03/2025.
////
//
//import SwiftUI
//import CoreLocation
//
//import SwiftUI
//import CoreLocation
//
//struct OpenMapsView: View {
//    let coordinate: CLLocationCoordinate2D
//
//    var body: some View {
//        Text("Opening Maps...")
//            .onAppear {
//                openMapsApp()
//            }
//            .padding()
//    }
//
//    private func openMapsApp() {
//        let latitude = coordinate.latitude
//        let longitude = coordinate.longitude
//        let name = "Bird Location"
//
//        let query = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "Location"
//        let urlString = "maps://?q=\(query)&ll=\(latitude),\(longitude)"
//
//        if let url = URL(string: urlString),
//           UIApplication.shared.canOpenURL(url) {
//            UIApplication.shared.open(url)
//        }
//    }
//}
//
////#Preview {
////    OpenMapsView()
////}
