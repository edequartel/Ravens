//
//  ExtensionsAndFunctions.swift
//  Ravens
//
//  Created by Eric de Quartel on 15/01/2024.
//

import Foundation
import SwiftUI

////werkhoven
//let longitude = 5.243376
//let latitude = 52.023861


//gouda en span nederland
let latitude = 52.013077-0.2
let longitude = 4.713450+0.1

let latitudeDelta = 4.5
let longitudeDelta = 3.0

func formatCurrentDate(value: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    
    let currentDate = value
    return dateFormatter.string(from: currentDate)
}

let bundleIdentifier = "ravens.app.bundle.identifier"

//waarneming-test.nl

extension Color {
    static let obsBlueButterfly = Color(red: 76/255, green: 253/255, blue: 251/255) //4CFDFB
    static let obsGreenSpider = Color(red: 31/255, green: 94/255, blue: 37/255) //1F5E25
    static let obsGreenFlower = Color(red: 203/255, green: 252/255, blue: 69/255) //CBFC45
    static let obsGreenEagle = Color(red: 29/255, green: 148/255, blue: 49/255) //1D9431
    static let obsBackground = Color(red: 106/255, green: 227/255, blue: 136/255) //6AE388
}

let obsStrGreenSpider = "1F5E25"
let obsStrGreenFlower = "CBFC45"
let obsStrGreenEagle = "1D9431"
let obsStrBackground = "6AE388"
let obsStrBlueButterfly = "4CFDFB"

let obsStrNorthSeaBlue = "75d0fa"
let obsStrDutchGreen = "c1e6ae"
let obsStrDutchOrange = "f7b731"

func GroupColor(value: Int) -> Color {
    switch value {
    case 0: return .gray   // all
    case 1: return .green  // birds
    case 2: return .blue   // mammals
    case 3: return .orange // reptiles and amfibian
    case 5: return .yellow    // butterflies
    case 6: return .pink    // dragonflies
    case 7: return .purple    // molluscs
    case 8: return .brown    // moth and micros
    case 9: return .gray    // fish
    case 10: return .obsBackground   // plants
    case 11: return .white   // fungi
    case 12: return .indigo   // mosses and lichen
    case 13: return .mint   // geleedpotigen
    case 14: return .teal   // locusts and crickets
    case 15: return .cyan   // wantsen cicaden en plantenluizen
//    case 16: return .olive   // bugs
//    case 17: return .lavender   // bees wasp ants
//    case 18: return .amber   // flies and mossies
//    case 19: return .coral   // algea
//    case 20: return .peach   // overige invertabrates
//    case 30: return .red   // verstoringen
    default:
        return .gray //You can provide a default color or handle other cases as needed
    }
}

func myColor(value: Int) -> Color {
    switch value {
    case 0:
        return .gray //onbekend
    case 1:
        return .green //algemeen
    case 2:
        return .blue //vrij algemeen
    case 3:
        return .orange //rare
    case 4:
        return .red //very rare
    default:
        return .gray //You can provide a default color or handle other cases as needed
    }
}

func SpeciesColor(value: Int) -> Color {
    switch value {
    case 0:
        return .gray //onbekend
    case 1:
        return .green //birds
    case 2:
        return .blue //vrij algemeen
    case 3:
        return .orange //rare
    case 4:
        return .red //very rare
    default:
        return .gray //You can provide a default color or handle other cases as needed
    }
}

extension AnyTransition {
    static var flipView: AnyTransition {
        AnyTransition.scale
            .combined(with: .opacity)
            .combined(with: .asymmetric(insertion: .opacity, removal: .scale))
    }
}


extension View {
    
    @ViewBuilder
    func applyIf<T: View>(_ condition: Bool, apply: (Self) -> T) -> some View {
        if condition {
            apply(self)
        } else {
            self
        }
    }
    
    func shadowedStyle() -> some View {
        self
            .shadow(color: .black.opacity(0.08), radius: 2, x: 0, y: 0)
            .shadow(color: .black.opacity(0.16), radius: 24, x: 0, y: 0)
    }
    
    func customButtonStyle(
        foreground: Color = .black,
        background: Color = .white
    ) -> some View {
        self.buttonStyle(
            ExampleButtonStyle(
                foreground: foreground,
                background: background
            )
        )
    }

#if os(iOS)
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
#endif
}

private struct ExampleButtonStyle: ButtonStyle {
    let foreground: Color
    let background: Color
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.45 : 1)
            .foregroundColor(configuration.isPressed ? foreground.opacity(0.55) : foreground)
            .background(configuration.isPressed ? background.opacity(0.55) : background)
    }
}

#if os(iOS)
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
#endif

class Constants {
    static let privacyPolicy = """
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam consectetur orci eget rutrum dignissim. Vivamus aliquam a massa a scelerisque. Integer eleifend lectus non blandit ultricies. Maecenas volutpat neque ut elit facilisis sodales. Mauris et iaculis tellus. Etiam nec mi consequat, ornare quam in, ornare magna. Donec quis egestas nunc. Morbi vel orci leo. Suspendisse eget lectus a erat dignissim interdum et quis neque. Fusce dapibus rhoncus nulla. Cras sed ipsum congue, tempus mi nec, vestibulum lorem.

Mauris rutrum urna ex, eget bibendum lectus vehicula nec. Mauris quis porttitor sapien, id vestibulum nibh. Proin mi lectus, pretium sed nulla bibendum, fringilla dignissim lacus. Vestibulum eget ante quis urna facilisis tristique. Curabitur mollis cursus mauris, vitae sollicitudin lacus fermentum nec. Etiam accumsan venenatis feugiat. Curabitur vitae posuere quam, imperdiet mattis elit. Nulla sollicitudin non neque sed aliquet. Donec lobortis iaculis interdum.

Nam eu feugiat arcu. Suspendisse porta eu sapien et eleifend. Fusce viverra laoreet tellus, eget convallis odio. Vivamus eget mollis dui. Sed euismod sed justo in fermentum. Nam at augue convallis, vulputate ligula eu, convallis risus. Proin egestas pretium nibh, in blandit ipsum varius quis. Aenean dolor mauris, luctus vel consequat id, tristique sit amet sem. Donec at pulvinar sem. Mauris diam lacus, placerat eget dolor ac, hendrerit elementum velit.

Integer sagittis ultricies commodo. Nullam eu diam at justo ornare viverra. Praesent ante metus, rhoncus ac condimentum id, malesuada viverra arcu. Nunc porta, odio at elementum viverra, tortor sem placerat lacus, eget scelerisque turpis odio at nisl. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Nulla varius luctus ex, eu sagittis leo tempor nec. Etiam viverra molestie iaculis. Fusce in cursus ipsum, et elementum metus. Nullam sed sodales ligula. Aliquam erat volutpat. Proin mattis nisi et lectus rutrum, quis aliquet metus aliquet. Nulla est nisi, condimentum sed pretium ac, scelerisque semper eros. Nullam varius diam at augue vehicula elementum eget a leo. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae; Etiam nisi enim, euismod ac tellus at, hendrerit dignissim turpis. Proin sit amet sapien posuere, facilisis velit quis, placerat purus.

Maecenas eget felis in lacus pharetra tristique. Nunc vehicula porttitor dolor, non viverra magna blandit sit amet. Phasellus et pellentesque ante, at sollicitudin leo. Etiam at quam nec ex rhoncus sagittis. Nullam tempor lectus id felis efficitur tempus eget eget lectus. Mauris vitae odio nisi. Fusce pellentesque mattis enim, vitae tincidunt nisl tempus sed. Sed et lacus vitae lectus pretium congue nec molestie odio. Phasellus nec libero ac enim consequat dapibus. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Morbi suscipit, urna vel elementum consequat, eros urna tempor nulla, vel mattis arcu ex quis nisl. Phasellus consequat porta lectus, eu tristique ipsum laoreet sit amet. Nam scelerisque ipsum sem, vitae sodales risus gravida in.

Maecenas felis velit, sodales ut diam vitae, sagittis aliquet neque. Duis tristique nisl at tristique hendrerit. Suspendisse sed egestas orci. Phasellus tempor cursus tellus, eget rhoncus justo mattis id. In a dapibus enim. Nulla eu neque tincidunt tellus finibus mattis. Mauris congue tellus vitae tortor laoreet accumsan.

Aenean iaculis porta consectetur. Vivamus tristique erat consectetur mi congue sollicitudin. Donec pellentesque, arcu pellentesque rhoncus vestibulum, massa diam vehicula nulla, non lacinia nunc lacus ut felis. Nam euismod finibus quam nec placerat. In imperdiet egestas sapien, sed elementum purus. Nullam interdum nisl fermentum ultrices elementum. Quisque eu mi sapien. Morbi vestibulum urna vel lacinia ultrices. Ut urna tortor, luctus in lorem eget, euismod volutpat magna. Etiam a accumsan massa. Fusce finibus blandit diam ac tincidunt. Nullam vitae dolor augue.

Maecenas maximus feugiat tellus sed vulputate. Proin ut ante vitae justo pulvinar laoreet. Donec fringilla justo consectetur mi consequat porttitor. Sed at mollis metus. Quisque at magna quis est malesuada aliquam sit amet at augue. Mauris hendrerit nunc ligula, in faucibus erat commodo quis. Nulla lacus dolor, cursus quis ligula eu, lacinia sollicitudin felis. Praesent odio tellus, pellentesque vitae leo ac, faucibus facilisis augue. Pellentesque bibendum nisl eget vehicula convallis. Maecenas velit urna, hendrerit quis nulla vitae, aliquam posuere erat. Integer accumsan sed arcu nec tempus. Etiam pharetra suscipit sapien id venenatis. Donec ultricies quis nisi vitae consectetur.
"""
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        // Define the points for the triangle
        let topPoint = CGPoint(x: rect.midX, y: rect.minY)
        let bottomLeftPoint = CGPoint(x: rect.minX, y: rect.maxY)
        let bottomRightPoint = CGPoint(x: rect.maxX, y: rect.maxY)

        // Move to the top point of the triangle
        path.move(to: topPoint)

        // Add lines to the bottom left and bottom right points to complete the triangle
        path.addLine(to: bottomLeftPoint)
        path.addLine(to: bottomRightPoint)

        // Close the path to form a closed triangle
        path.closeSubpath()

        return path
    }
}

extension Font {
    static var customTiny: Font {
        return .system(size: 10)
    }
    
    static var customSmall: Font {
        return .system(size: 12)
    }

    static var customMedium: Font {
        return .system(size: 16)
    }

    static var customLarge: Font {
        return .system(size: 20)
    }

    static var customExtraLarge: Font {
        return .system(size: 24)
    }
}

func deleteAllFiles() {
    let documentsDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
    let fileManager = FileManager.default

    do {
        let files = try fileManager.contentsOfDirectory(atPath: documentsDirectoryPath as String)
        
        for file in files {
            let filePath = documentsDirectoryPath.appendingPathComponent(file)
            try fileManager.removeItem(atPath: filePath)
        }
    } catch {
        print("Error deleting files: \(error)")
    }
}

func calculateLocalStorageSize() -> String {
    let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
    let fileManager = FileManager.default
    var totalSize: UInt64 = 0

    do {
        let files = try fileManager.contentsOfDirectory(atPath: documentDirectoryPath as String)
        
        for file in files {
            let filePath = documentDirectoryPath.appendingPathComponent(file)
            let fileAttributes = try fileManager.attributesOfItem(atPath: filePath)
            if let fileSize = fileAttributes[FileAttributeKey.size] as? UInt64 {
                totalSize += fileSize
            }
        }
    } catch {
        print("Error getting file attributes: \(error)")
    }

    // Convert total size in bytes to MB
    let sizeInMB = Double(totalSize) / 1024.0 / 1024.0
    return String(format: "%.2f MB", sizeInMB)
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

extension View {
    func topLeft() -> some View {
        self
            .modifier(TopLeftModifier())
    }
}

struct TopLeftModifier: ViewModifier {
    func body(content: Content) -> some View {
        VStack {
            HStack {
                content
                    .padding([.top, .leading], 10)
                Spacer() // Pushes the view to the left
            }
            Spacer() // Pushes the view to the top
        }
    }
}

extension Text {
    func footnoteGrayStyle() -> some View {
        self
            .foregroundColor(.gray)
            .font(.footnote)
            .italic()
            .lineLimit(1)
            .truncationMode(.tail)
    }
}



struct RoundButtonStyle: ViewModifier {
    var iconName: String
    var backgroundColor: Color
    var foregroundColor: Color
    var shadowRadius: CGFloat

    func body(content: Content) -> some View {
        content
            .font(.title)  // Adjust the size of the image
            .foregroundColor(foregroundColor)  // Color of the icon
            .padding()  // Padding around the icon
            .background(Circle()  // Creates a circular background
                .fill(backgroundColor)  // Background color of the circle
                .shadow(radius: shadowRadius))  // Shadow with a radius
    }
}

// Extension to apply the modifier more easily
extension View {
    func roundButtonStyle(
        iconName: String,
        backgroundColor: Color,
        foregroundColor: Color,
        shadowRadius: CGFloat) -> some View {
        self.modifier(
            RoundButtonStyle(
                iconName: iconName,
                backgroundColor: backgroundColor,
                foregroundColor: foregroundColor,
                shadowRadius: shadowRadius))
    }
}


