////
////  RadiusView.swift
////  Ravens
////
////  Created by Eric de Quartel on 13/05/2024.
////
//
//import SwiftUI
//
//struct RadiusView: View {
////    @StateObject private var accessibilitySettings = AccessibilitySettings()
//    
//    @State private var showFirstView = true
//    
//    @EnvironmentObject var settings: Settings
//    
//    var body: some View {
//        NavigationView {
//            VStack {
//                if showFirstView && !settings.accessibility {
//                    MapObservationRadiusView()
//                } else {
//                    ObservationsRadiusView()
//                }
//            }
//            .navigationBarTitleDisplayMode(.inline)
//            
//            .toolbar {
//                
//                if !settings.accessibility {
//                    ToolbarItem(placement: .navigationBarLeading) {
//                        Button(action: {
//                            showFirstView.toggle()
//                        }) {
//                            Image(systemName: "rectangle.2.swap")
//                        }
//                    }
//                }
//                
//                ToolbarItem(placement: .navigationBarLeading) {
//                    Button(action: {
//                        settings.hidePictures.toggle()
////                        print("position: \(settings.position)")
//                    }) {
//                        Image(systemName: "smallcircle.filled.circle")
//                    }
//                }
//                
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button(action: {
//                        settings.hidePictures.toggle()
//                    }) {
//                        ImageWithOverlay(systemName: "photo", value: !settings.hidePictures)
//                    }
//                }
//                
//
//
//                
//                
//            }
//            .navigationTitle(settings.selectedSpeciesGroupName)
//
//        }
//        .onAppearOnce {
//            showFirstView = settings.mapPreference
//        }
//    }
//}
//
//struct ImageWithOverlay: View {
//    var systemName: String
//    var value: Bool
//
//    var body: some View {
//        ZStack {
//            Image(systemName: systemName)
//                .resizable()
//                .aspectRatio(contentMode: .fit)
//                .frame(width: 24, height: 24)
//            
//            if !value {
//                Image(systemName: "line.diagonal")
//                    .resizable()
//                    .aspectRatio(contentMode: .fit)
//                    .frame(width: 24, height: 24)
//            }
//        }
//    }
//}
//
//struct ImageWithOverlay_Previews: PreviewProvider {
//    static var previews: some View {
//        ImageWithOverlay(systemName: "star", value: false)
//    }
//}
//
//
//#Preview {
//    RadiusView()
//}
