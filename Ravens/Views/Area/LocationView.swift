//
//  LocationView.swift
//  Ravens
//
//  Created by Eric de Quartel on 13/05/2024.
//

import SwiftUI
import SwiftyBeaver

struct LocationView: View {
    let log = SwiftyBeaver.self
    @EnvironmentObject private var settings: Settings
    @EnvironmentObject private var areasViewModel: AreasViewModel
    
    @State private var searchText: String = ""
    @State private var showFirstView = true
    @State private var isShowingLocationList = false
    
    var body: some View {
        NavigationView {
            VStack {
                if showFirstView && !settings.accessibility {
                    MapObservationsLocationView()
                } else {
                    ObservationsLocationView()
                }
            }
//            .navigationTitle(settings.locationName)
            .navigationBarTitleDisplayMode(.inline)

            .toolbar {
                if !settings.accessibility {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            showFirstView.toggle()
                        }) {
                            Image(systemName: "rectangle.2.swap")
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        settings.hidePictures.toggle()
//                        print("position: \(settings.position)")
                    }) {
                        Image(systemName: "smallcircle.filled.circle")
                    }
                }
    
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        if areasViewModel.isIDInRecords(areaID: settings.locationId) {
                            areasViewModel.removeRecord(areaID: settings.locationId)
                        } else {
                            log.error("\(settings.locationName) \(settings.locationId) \(settings.locationCoordinate?.latitude ?? 0) \(settings.locationCoordinate?.longitude ?? 0)")
                            
                            areasViewModel.appendRecord(
                                areaName: settings.locationName,
                                areaID: settings.locationId,
                                latitude: settings.locationCoordinate?.latitude ?? 0,
                                longitude: settings.locationCoordinate?.longitude ?? 0
                            )
                            //
                            
                        }
                    }) {
                        Image(systemName: areasViewModel.isIDInRecords(areaID: settings.locationId) ? "pentagon.fill" : "pentagon")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: AreasView()) {
                        Label("Areas", systemImage: "list.bullet")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: LocationListView()) {
                        Image(systemName: "magnifyingglass")
                        
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        settings.hidePictures.toggle()
                    }) {
                        ImageWithOverlay(systemName: "photo", value: !settings.hidePictures)
                    }
                }
                
            }
            .onAppear {
                log.info("LocationView onAppear")
            }
            .onAppearOnce {
                showFirstView = settings.mapPreference
            }
        }
    }
}

#Preview {
    LocationView()
}

