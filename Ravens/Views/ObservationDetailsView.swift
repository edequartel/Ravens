//
//  ObservationDetailsView.swift
//  Ravens
//
//  Created by Eric de Quartel on 15/01/2024.
//

import SwiftUI

struct ObservationDetailsView: View {
    var link: String // Add link as a property

    var body: some View {
        Text("\(link)")
    }
    
}

struct ObservationDetailsView_Previews: PreviewProvider {
    static var previews: some View {

        // Binding the dummy observation for the preview
        ObservationDetailsView(link: "")
    }
}
