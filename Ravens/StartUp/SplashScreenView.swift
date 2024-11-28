//
//  SplashScreenView.swift
//  Braille
//
//  Created by Eric de Quartel on 03/06/2022.
//

import SwiftUI
import Alamofire
import SwiftyBeaver

struct SplashScreenView: View {
    let log = SwiftyBeaver.self
    
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.locale) private var locale
    
    var body: some View {
            ContentView()
    }
}

struct SplashScreenView_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreenView()
    }
}
