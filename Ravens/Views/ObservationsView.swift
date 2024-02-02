//
//  ObservationsView.swift
//  Ravens
//
//  Created by Eric de Quartel on 11/01/2024.
//

import SwiftUI
//import MapKit

struct ObservationsView: View {
    @EnvironmentObject var observationsViewModel: ObservationsViewModel
    @EnvironmentObject var settings: Settings
    
    @Binding var isShowing: Bool
    
    var body: some View {
        VStack {
            HStack {
                Text("Results \(observationsViewModel.observations?.results.count ?? 0)/\(observationsViewModel.observations?.count ?? 0)")
                    .bold()
            }
            .padding(16)
            
            List {
                if let results = observationsViewModel.observations?.results {
                    ForEach(results.sorted(by: { ($1.rarity, $1.date, $0.species_detail.name) < ($0.rarity, $0.date, $1.species_detail.name) }), id: \.id) { result in
                        LazyVStack(alignment: .leading) {
                            HStack {
                                Image(systemName: "circle.fill")
                                    .foregroundColor(Color(myColor(value: result.rarity)))
                                HStack {
                                    Text("\(result.species_detail.name)")
                                    Spacer()
                                    Text("\(result.user)")
                                }
                                Spacer()
                                HStack {
                                    if result.has_sound { Image(systemName: "speaker.fill" ) }
                                    if result.has_photo { Image(systemName: "photo.fill") }
                                }
                            }
                            
                            HStack {
                                Text("\(result.date)")
                                Text("\(result.time ?? "no time")")
                                Spacer()
                                
                            }
                            
                            Text("\(result.location_detail.name)")
                        }
                        .font(.subheadline)
                        .onTapGesture {
                            if let url = URL(string: result.permalink) {
                                UIApplication.shared.open(url)
                            }
                        }
                    }
                    
                    
                } else {
                    // Handle the case when observationsViewModel.observations?.results is nil
                    Text("nobsavaliable")
                }
            }
        }
        .onAppear(){
            // Get the current locations of all the observations
            observationsViewModel.fetchData(days: settings.days, endDate: settings.selectedDate,
                                            lat: settings.currentLocation?.coordinate.latitude ?? latitude,
                                            long: settings.currentLocation?.coordinate.longitude ?? longitude,
                                            radius: settings.radius,
                                            species_group: settings.selectedGroupId,
                                            min_rarity: settings.selectedRarity,
                                            language: settings.selectedLanguage)
        }
//        .padding(16)
//        .background(Color.white.cornerRadius(18))
//        .shadowedStyle()
//        .padding(.horizontal, 8)
//        .padding(.bottom, 30)
    }
}

struct ObservationsView_Previews: PreviewProvider {
    static var previews: some View {
        // Setting up the environment objects for the preview
        ObservationsView(isShowing: .constant(false))
            .environmentObject(ObservationsViewModel())
            .environmentObject(Settings())
    }
}

//            Button {
//                isShowing = false
//                print("showingoff")
//            } label: {
//                Text("Close")
//                    .buttonStyle(.plain)
//                    .font(.system(size: 17))
//                    .frame(maxWidth: .infinity)
//                    .frame(height: 44)
//                    .background {
//                        RoundedRectangle(cornerRadius: 12)
//                            .fill(Color(red: 0.29, green: 0.38, blue: 1))
//                    }
//            }
//            .buttonStyle(.plain)
//            .foregroundColor(.white)
//            .padding()

//            Form {
