//
//  LocationView.swift
//  Ravens
//
//  Created by Eric de Quartel on 13/05/2024.
//

import SwiftUI

struct LocationView: View {
    @State private var showFirstView = true
    
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
                        Image(systemName: "rectangle.2.swap") // Replace with your desired image
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: AreasView()) {
                        Label("Areas", systemImage: "pentagon.fill")
                    }
                }
                    
//                        ToolbarItem() {
//                            HStack {
//        //                        Text("Observer")
//                                Text("\(settings.userName)")
//                            }
//                        }

            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}

#Preview {
    LocationView()
}

