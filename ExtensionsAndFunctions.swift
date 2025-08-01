//
//  ExtensionsAndFunctions.swift
//  Ravens
//
//  Created by Eric de Quartel on 15/01/2024.
//

import Foundation
import SwiftUI
import AudioToolbox
import SFSafeSymbols
import MapKit
import SVGView

let demo = false
 let showView = false
// let showView = true

// neeltje jans
// 51.631732, 3.698586

let latitudeDelta = 4.5
let longitudeDelta = 3.0

func cleanName(_ name: String) -> String {
  var cleanName = name.replacingOccurrences(of: " ", with: "_")
  let charactersToRemove = Set(["!", "?", "."])

  for character in charactersToRemove {
    cleanName = cleanName.replacingOccurrences(of: String(character), with: "")
  }
  return cleanName
}

func formatCurrentDate(value: Date) -> String {
  let dateFormatter = DateFormatter()
  dateFormatter.dateFormat = "yyyy-MM-dd"
  let currentDate = value
  return dateFormatter.string(from: currentDate)
}

var selectedInBetween = "waarneming.nl"
func endPoint(value: String = "") -> String {
  if value != "" {
    selectedInBetween = value
  }
  return "https://"+selectedInBetween+"/api/v1/"
}

let bundleIdentifier = "ravens.app.bundle.identifier"

let VOMap = "map"
let VOMapFavorite = "favorite map"
let VOAreas = "areas"

extension Color {
  static let obsBlueButterfly = Color(red: 76/255, green: 253/255, blue: 251/255) // 4CFDFB
  static let obsGreenSpider = Color(red: 31/255, green: 94/255, blue: 37/255) // 1F5E25
  static let obsGreenFlower = Color(red: 203/255, green: 252/255, blue: 69/255) // CBFC45
  static let obsGreenEagle = Color(red: 29/255, green: 148/255, blue: 49/255) // 1D9431
  static let obsBackground = Color(red: 106/255, green: 227/255, blue: 136/255) // 6AE388
  static let obsStar = Color(red: 29/255, green: 148/255, blue: 49/255) // 1D9431

  static let obsInformation = Color(red: 0/255, green: 0/255, blue: 255/255) // blue
  static let obsObserver = Color(red: 255/255, green: 0/255, blue: 0/255) // red
  static let obsBookmark = Color(red: 29/255, green: 148/255, blue: 49/255) // green
  static let obsArea = Color(red: 255/255, green: 165/255, blue: 0/255) // orange
  static let obsObservation = Color(red: 89/255, green: 173/255, blue: 195/255) // lightblue
  static let obsShareLink = Color(red: 0.5, green: 0.5, blue: 0.5) // gray
  static let obsToolbar = Color(red: 89/255, green: 173/255, blue: 195/255) // lightblue

  static let obsBirdInfo = Color(red: 240/255, green: 94/255, blue: 35/255) // orange
//  static let obsXCred = .purple Color(red: 0.5, green: 0.0, blue: 0.0) // darkred
}

let obsStrDutchOrange = "f7b731"

let SFShareLink = SFSymbol.squareAndArrowUp
let SFInformation = SFSymbol.info
let SFArea = SFSymbol.map
let SFAreaFill = SFSymbol.mapFill
let SFSpecies = SFSymbol.star
let SFSpeciesFill = SFSymbol.starFill
let SFObservation = SFSymbol.binocularsFill
let SFObserver = SFSymbol.person
let SFObserverFill = SFSymbol.personFill
let SFObserverPlus = SFSymbol.personFillBadgePlus
let SFObserverMin = SFSymbol.personFillBadgeMinus

func rarityColor(value: Int) -> Color {
  switch value {
  case 0:
    return .gray // onbekend
  case 1:
    return .green // algemeen
  case 2:
    return .blue // vrij algemeen
  case 3:
    return .orange // rare
  case 4:
    return .red // very rare
  default:
    return .gray // You can provide a default color or handle other cases as needed
  }
}

func speciesColor(value: Int) -> Color {
  switch value {
  case 0:
    return .gray // onbekend
  case 1:
    return .green // birds
  case 2:
    return .blue // vrij algemeen
  case 3:
    return .orange // rare
  case 4:
    return .red // very rare
  default:
    return .gray // You can provide a default color or handle other cases as needed
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

    let red = (rgbValue & 0xff0000) >> 16
    let green = (rgbValue & 0xff00) >> 8
    let blue = rgbValue & 0xff

    self.init(red: Double(red) / 0xff, green: Double(green) / 0xff, blue: Double(blue) / 0xff)
  }
}

extension View {
  func topLeft() -> some View {
    self
      .modifier(TopLeftModifier())
  }
}

extension View {
  func topRight() -> some View {
    self
      .modifier(TopRightModifier())
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

struct TopRightModifier: ViewModifier {
  func body(content: Content) -> some View {
    VStack {
      HStack {
        Spacer() // Pushes the view to the right
        content
          .padding([.top, .trailing], 10)
      }
      Spacer() // Pushes the view to the top
    }
  }
}

extension VStack {
  func footnoteGrayStyle() -> some View {
    self
      .foregroundColor(.gray)
      .font(.footnote)
      .italic()
      .lineLimit(1)
      .truncationMode(.tail)
  }
}

extension Text {
  func footnoteGrayStyle() -> some View {
    self
    //            .foregroundColor(.black)
      .font(.footnote)
    //            .italic()
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

struct RunOnceModifier: ViewModifier {
  @State private var hasRun = false
  let action: () -> Void

  func body(content: Content) -> some View {
    content
      .onAppear {
        if !hasRun {
          action()
          hasRun = true
        }
      }
  }
}

extension View {
  func onAppearOnce(perform action: @escaping () -> Void) -> some View {
    self.modifier(RunOnceModifier(action: action))
  }
}

struct HorizontalLine: View {
  var body: some View {
    Rectangle()
      .frame(height: 0.4)
      .foregroundColor(.gray)
  }
}

func vibrate() {
  AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
}

// make Int directly Identifiable
extension Int: @retroactive Identifiable {
  public var id: Int { self }
}

extension String: @retroactive Identifiable {
  public var id: String { self }
}

/// Applies a consistent size, aspect ratio, and optional padding to system images for visual alignment across the UI.
///
/// - Returns: A view that renders the image at 24×24 points with a 4-point padding and aspect fit scaling.
extension Image {
  func uniformSize() -> some View {
        self
            .resizable() // Makes the image resizable
            .aspectRatio(contentMode: .fit) // Maintains aspect ratio
            .frame(width: 24, height: 24) // Sets the uniform siz#
            .padding(4) // Adds padding around the image
            .overlay(
                RoundedRectangle(cornerRadius: 4) // Adds a rounded rectangle border
                  .stroke(Color.blue, lineWidth: 1)
            )
    }
}

/// Applies a soft, rounded, lightly shadowed background to the view—similar to a floating "island" appearance.
///
/// - Parameters:
///   - cornerRadius: The corner radius of the rounded rectangle. Default is `8`.
///   - shadowRadius: The shadow blur radius applied around the background. Default is `2`.
/// - Returns: A view with a rounded, translucent gray background and subtle shadow.
extension View {
    func islandBackground(cornerRadius: CGFloat = 8, shadowRadius: CGFloat = 2) -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color.gray.opacity(0.1)) // Light gray background with opacity
                    .shadow(radius: shadowRadius)
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}

struct ImageWithOverlay: View {
    var systemName: String
    var value: Bool

    var body: some View {
        ZStack {
            Image(systemName: systemName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)

            if !value {
              Image(systemSymbol: .lineDiagonal)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
            }
        }
    }
}

struct ImageWithOverlay_Previews: PreviewProvider {
    static var previews: some View {
        ImageWithOverlay(systemName: "star", value: false)
    }
}

func formatDate(date: Date) -> String {
  let formatter = DateFormatter()
  formatter.dateFormat = "yyyy-MM-dd"
  return formatter.string(from: date)
}

public struct CapsuleButtonStyle: ButtonStyle {
    public func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .frame(minWidth: 0, minHeight: 44) // Minimum height for tap target
            .padding(.horizontal, 20)
            .foregroundColor(.accentColor)
            .background(background)
            .bold()
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }

    var background: some View {
        Capsule(style: .continuous)
            .stroke(Color.accentColor, lineWidth: 1)
    }
}

struct CapsuleButtonStyle_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            Button("Action!") {
            }.buttonStyle(CapsuleButtonStyle())
        }
    }
}

extension SVGView {
  /// Applies a consistent size, aspect ratio, and optional padding to SVGView
  /// for alignment with other system icons or images.
  func uniformSize() -> some View {
    self
      .aspectRatio(contentMode: .fit)
      .frame(width: 24, height: 24)
      .padding(4)
//      .overlay(
//        RoundedRectangle(cornerRadius: 4)
//          .stroke(Color.blue, lineWidth: 1)
//      )
  }
}

struct SVGImage: View {
  let svg: String
  let width: CGFloat?
  let height: CGFloat?
  let padding: CGFloat

  init(svg: String, width: CGFloat = 24, height: CGFloat = 24, padding: CGFloat = 4) {
    self.svg = svg
    self.width = width
    self.height = height
    self.padding = padding
  }

  var body: some View {
    if let url = Bundle.main.url(forResource: svg, withExtension: "svg") {
      SVGView(contentsOf: url)
        .aspectRatio(contentMode: .fit)
        .frame(width: width, height: height)
        .padding(padding)
            .overlay(
              RoundedRectangle(cornerRadius: 4)
                .stroke(Color.blue, lineWidth: 1)
            )
    } else {
      EmptyView()
    }
  }
} 


