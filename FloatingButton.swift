//
//  FloatingButton.swift
//  Ravens
//
//  Created by Eric de Quartel on 21/01/2024.
//

import Foundation
import SwiftUI
import FloatingButton


//struct ScreenCircle: View {
//    @Binding var toggle : Bool
//    
//    var body: some View {
//        VStack {
//            Spacer()
//            HStack {
//                Button {
//                    toggle.toggle()
//                } label: {
//                    Text("Flip")
//                        .buttonStyle(.bordered)
//                        .font(.system(size: 17))
//                        .frame(maxWidth: .infinity)
//                        .frame(height: 44)
//                        .background {
//                            RoundedRectangle(cornerRadius: 12)
//                                .fill(Color(red: 0.29, green: 0.38, blue: 1))
//                        }
//                }
//                .buttonStyle(.plain)
//                .foregroundColor(.white)
//                .padding(.top, 12)
//                Spacer()
//            }
//            .padding(20)
//        }
//        .padding(20)
//    }
//}


struct ObservationCircle: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @Binding var toggle : Bool
    
    var colorHex: String // Add this property
    
    var body: some View {
        let mainButton = MainButton(imageName: toggle ? "map" : "list.bullet" , colorHex: colorHex, toggle: $toggle)
        let buttonsImage = MockData.iconImageNames.enumerated().map { index, value in
            IconButton(imageName: value, color: MockData.colors[index])
        }
        
        let menu = FloatingButton(mainButtonView: mainButton, buttons: buttonsImage.dropLast())
            .circle()
            .startAngle(3/2 * .pi)
            .endAngle(2 * .pi)
            .radius(70)
        
        return VStack {
            Spacer()
            HStack {
                menu
                Spacer()
            }
            .padding()
        }
    }
}

struct MainButton: View {
    var imageName: String
    var colorHex: String
    var width: CGFloat = 50
    
    @Binding var toggle : Bool
    
    var body: some View {
        ZStack {
            Color(hex: colorHex)
                .frame(width: width, height: width)
                .cornerRadius(width / 2)
                .shadow(color: Color(hex: colorHex).opacity(0.3), radius: 15, x: 0, y: 15)
            Image(systemName: imageName)
                .foregroundColor(.white)
        }
        .onTapGesture {
            // Call the action closure when tapped
            toggle.toggle()
        }
    }
}

struct IconButton: View {
    var imageName: String
    var color: Color
    let imageWidth: CGFloat = 20
    let buttonWidth: CGFloat = 45
    
//    @Binding var toggle : Bool
    
    var body: some View {
        ZStack {
            color
            Image(systemName: imageName)
                .frame(width: imageWidth, height: imageWidth)
                .foregroundColor(.white)
        }
        .frame(width: buttonWidth, height: buttonWidth)
        .cornerRadius(buttonWidth / 2)
        .onTapGesture {
            // Call the action closure when tapped
            print("action()")
        }
    }
}

struct IconTextButton: View {
    var imageName: String
    var color: Color
    let imageWidth: CGFloat = 20
    let buttonWidth: CGFloat = 45
    
    @Binding var value : String
    
    var body: some View {
        ZStack {
            color
            Image(systemName: imageName)
                .frame(width: imageWidth, height: imageWidth)
                .foregroundColor(.white)
        }
        .frame(width: buttonWidth, height: buttonWidth)
        .cornerRadius(buttonWidth / 2)
        .onTapGesture {
            // Call the action closure when tapped
            value = "mytext"
            print("action()")
        }
    }
}

struct MockData {
    
    static let colors = [
                "e84393",
                "0984e3",
                "6c5ce7",
        "00b894"
    ].map { Color(hex: $0) }
    
    static let iconImageNames = [
                "sun.max.fill",
                "cloud.fill",
                "cloud.rain.fill",
        "cloud.snow.fill"
    ]
}


extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        
        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff
        
        self.init(red: Double(r) / 0xff, green: Double(g) / 0xff, blue: Double(b) / 0xff)
    }
}
