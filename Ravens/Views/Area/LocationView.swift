//
//  LocationView.swift
//  Ravens
//
//  Created by Eric de Quartel on 13/05/2024.
//

import SwiftUI

struct LocationView: View {
    @State private var showFirstView = true
    @EnvironmentObject private var settings: Settings
    
    var body: some View {
       
        
        NavigationView {
            VStack {
                if showFirstView {
                    MapObservationsLocationView()
                } else {
                    ObservationsLocationView()
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showFirstView.toggle()
                    }) {
                        Image(systemName: "rectangle.2.swap") 
                    }
                }
                
//                ToolbarItem(placement: .navigationBarLeading) {
//                    Spacer()
//                }
                ToolbarItem() {
                    VStack {
                        Text("\(settings.locationName)")
//                            .font(.caption2)
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .foregroundColor(.blue)
                    }
                        
                }
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Spacer()
//                }

                
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: AreasView()) {
                        Label("Areas", systemImage: "pentagon.fill")
                    }
                }
            }
        }
//        .edgesIgnoringSafeArea(.all)
    }
}

#Preview {
    LocationView()
}

