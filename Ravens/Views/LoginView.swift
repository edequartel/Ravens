//
//  loginView.swift
//  Ravens
//
//  Created by Eric de Quartel on 17/01/2024.
//

import SwiftUI

struct loginView: View {
    @EnvironmentObject var settings: Settings
    
    var body: some View {
        VStack {
            Text("\(settings.login)")
            Text("\(settings.password)")
        }
    }
}

struct loginView_Previews: PreviewProvider {
    static var previews: some View {
        // Creating dummy data for preview
        let settings = Settings()

        // Setting up the environment objects for the preview
        loginView()
            .environmentObject(settings)
    }
}

