//
//  LabView.swift
//  Ravens
//
//  Created by Eric de Quartel on 01/02/2024.
//

import SwiftUI

struct LabView: View {
    var body: some View {
            NavigationView {
                List {
                    ForEach(0...5, id: \.self) { index in
                        NavigationLink(destination: Text("Destination \(index)")) {
                            HStack {
                                // Replace "binoculars.fill" with the name of your binoculars image in the Assets catalog
                                Image(systemName: "binoculars.fill")
                                    .renderingMode(.template)
                                    .foregroundColor(.blue) // Adjust color as needed
                                    .frame(width: 24, height: 24) // Adjust size as needed
                                Text("Go to Destination \(index)")
                            }
                        }
                    }
                }
                .navigationBarTitle("Main View")
            }
        }
    }

#Preview {
    LabView()
}

