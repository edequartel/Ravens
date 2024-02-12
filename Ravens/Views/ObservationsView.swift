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
                          ObsAltView(obs: result)
//                        ObsView(obsID: result.id)
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
    }
}


struct ObsAltView: View {
    
    var obs: Observation
 
    var body: some View {
        LazyVStack(alignment: .leading) {
            HStack {
                Image(systemName: "circle.fill")
                    .foregroundColor(Color(myColor(value: obs.rarity)))
                VStack(alignment: .leading, content: {
                    Text("\(obs.species_detail.name)")
////                    Spacer()
//                    //                                    Text("\(result.user)")
//                    Text("obs id: \(obs.id)")
//                        .foregroundColor(.red)
//                    Text("date: \(obs.date)")
//                    Text("rarirty: \(obs.rarity)")
//                    Text("activirty: \(obs.activity)")
                })
                Spacer()
                HStack {
                    if obs.has_sound { Image(systemName: "speaker.fill" ) }
                    if obs.has_photo { Image(systemName: "photo.fill") }
                }
            }
            
            HStack {
                Text("\(obs.date)")
                Text("\(obs.time ?? "no time")")
                Spacer()
            }
            
            Text("\(obs.location_detail.name)")
        }
        .font(.subheadline)
        .onTapGesture {
            if let url = URL(string: obs.permalink) {
                UIApplication.shared.open(url)
            }
        }
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




//LazyVStack(alignment: .leading) {
//    HStack {
//        Image(systemName: "circle.fill")
//            .foregroundColor(Color(myColor(value: result.rarity)))
//        HStack {
//            Text("\(result.species_detail.name)")
//            Spacer()
////                                    Text("\(result.user)")
//            Text("obs id: \(result.id)")
//            
//            
////                                    ObsSpeciesView(obsSpecies: result.id)
////                                    ObsSpeciesView(obsSpecies: )
//            
//            
//        }
//        Spacer()
//        HStack {
//            if result.has_sound { Image(systemName: "speaker.fill" ) }
//            if result.has_photo { Image(systemName: "photo.fill") }
//        }
//    }
//    
//    HStack {
//        Text("\(result.date)")
//        Text("\(result.time ?? "no time")")
//        Spacer()
//       
//        
//        
//    }
//    
//    Text("\(result.location_detail.name)")
//}
//.font(.subheadline)
//.onTapGesture {
//    if let url = URL(string: result.permalink) {
//        UIApplication.shared.open(url)
//    }
