//
//  SampleView.swift
//  Ravens
//
//  Created by Eric de Quartel on 18/04/2024.
//

import SwiftUI

//struct SampleView: View {
//    @State private var myBool : Bool = false
//    
//    var body: some View {
//        ZStack(alignment: .topLeading) {
//            // Background or other content
//            Color.gray.edgesIgnoringSafeArea(.all)
//            
//            CircleButton(isToggleOn: $myBool)
//                .padding([.top, .leading], 20) // Apply padding to the top and leading edges
//        }
//    }
//}

struct CircleButton: View {
    
    @Binding var isToggleOn : Bool
    
    var body: some View {
        Button(action: {
            // Action to perform
            isToggleOn.toggle()
        }) {
            isToggleOn
                ? Image(systemName: "map.fill")
                    .foregroundColor(.white)
                    .font(.title)
                : Image(systemName: "list.bullet")
                    .foregroundColor(.white)
//                    .font(.largeTitle)
                    .font(.title)

        }
        .buttonStyle(CircularButtonStyle())
    }
}

struct CircularButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(Color.blue) // Customize the button color
            .clipShape(Circle())
            .shadow(radius: 10)
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}



//#Preview {
//    SampleView()
//}
