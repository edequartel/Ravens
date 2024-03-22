//
//  SplashScreenView.swift
//  Braille
//
//  Created by Eric de Quartel on 03/06/2022.
//


//let player = AudioPlayer()
//let audioItem = DefaultAudioItem(audioUrl: "someUrl", sourceType: .stream)
//player.load(item: audioItem, playWhenReady: true) // Load the item and start playing when the player is ready.

import SwiftUI
import Alamofire
import SwiftyBeaver

struct SplashScreenView: View {
    let log = SwiftyBeaver.self
    
    @Environment(\.scenePhase) private var scenePhase
//    @EnvironmentObject var viewModel: LouisViewModel
    @Environment(\.locale) private var locale
    
    var body: some View {
//        if (isActive) {
            ContentView()
//        } else {
//            VStack {
////                LottieView(lottieFile: "bartimeusbigb")
//                    .frame(width: 150, height: 150)
//            }
//        }
    }
}

struct SplashScreenView_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreenView()
//            .environmentObject(LouisViewModel())
    }
}
