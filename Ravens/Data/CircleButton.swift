//
//  CircleButton.swift
//  Ravens
//
//  Created by Eric de Quartel on 18/04/2024.
//

import SwiftUI

struct CircleButton: View {
    
    @Binding var isToggleOn : Bool
    
    var body: some View {
        Button(action: {
            isToggleOn.toggle()
        }) {
            isToggleOn
                ? Image(systemName: "map.fill")
                    .foregroundColor(.white)
                    .font(.title)
                : Image(systemName: "list.bullet")
                    .foregroundColor(.white)
                    .font(.title)

        }
        .buttonStyle(CircularButtonStyle())
    }
}

struct CircularButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
//            .background(Color.blue) // Customize the button color
//            .background(Color(red: 12, green: 0, blue: 0)) 
            .background(Color(hex: "f7b731"))
//            .background(Color(hex: "cbfc45"))
            .clipShape(Circle())
            .shadow(radius: 5)
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}
