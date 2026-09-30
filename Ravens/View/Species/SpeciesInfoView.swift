//
//  SpeciesInfoView.swift
//  Ravens
//
//  Created by Eric de Quartel on 03/12/2024.
//
import SwiftUI
import SwiftyBeaver
import Kingfisher

struct SpeciesInfoView: View {
  var species: Species // Assuming Species is your data model
  var showView: Bool
  @EnvironmentObject var bookMarksViewModel: BookMarksViewModel
  @EnvironmentObject var notificationViewModel: NotificationsViewModel
  @EnvironmentObject var speciesSecondLangViewModel: SpeciesViewModel

  var body: some View {
    HStack(spacing: 8) {
      SpeciesINaturalistThumbnailView(scientificName: species.scientificName)

      VStack(alignment: .leading) {
        if showView { Text("SpeciesInfoView").font(.customTiny) }

        HStack(spacing: 4) {
          if species.date != nil {
            Image(
              systemName: "eye")
            .symbolRenderingMode(.palette)
            .foregroundStyle(rarityColor(value: species.rarity), .clear)
          } else {
            Image(
              systemName: "circle.fill")
            .symbolRenderingMode(.palette)
            .foregroundStyle(rarityColor(value: species.rarity), .clear)

          }

          if !(species.name.isEmpty) {
            Text("\(species.name)")
              .bold()
              .lineLimit(1)
              .truncationMode(.tail)
              .foregroundColor(species.recent ?? false ? .red : .primary)
          } else {
            Text("\(species.scientificName)")
              .italic()
              .lineLimit(1)
              .truncationMode(.tail)
              .foregroundColor(species.recent ?? false ? .red : .primary)
          }

          Spacer()

          if bookMarksViewModel.isSpeciesIDInRecords(speciesID: species.speciesId) {
            Image(systemName: "star.fill")
              .foregroundColor(Color.gray.opacity(0.8))
          }

          // Notifications
  //        if notificationViewModel.isSpeciesIDInRecords(speciesID: species.speciesId) {
  //          Image(systemSymbol: .clock)
  //            .foregroundColor(Color.gray.opacity(0.8))
  //        }

        }

        if let date = species.date {
          HStack {
            DateConversionView(dateString: date, timeString: species.time ?? "")
          }
          .font(.caption)
        }

        if (species.name) != (species.scientificName) {
          HStack {
            Text("\(species.scientificName)")
              .font(.caption)
              .italic()
              .lineLimit(1)
              .truncationMode(.tail)
          }
        }

        HStack {
          let speciesLang = speciesSecondLangViewModel.findSpeciesByID(
            speciesID: species.speciesId)
          if speciesLang?.lowercased() != species.scientificName.lowercased() {
            Text("\(speciesLang ?? "placeholder")")
              .font(.caption)
              .lineLimit(1)
              .truncationMode(.tail)
            Spacer()
          } else {
            Text(" ")
          }
        }
      }
    }
  }
}

struct SpeciesINaturalistThumbnailView: View {
  let scientificName: String
  var thumbnailSize: CGFloat = 56

  @State private var photoURL: URL?
  @State private var didLoad = false
  @State private var didRetryAfterFailure = false

  var body: some View {
    ZStack {
      if let photoURL {
        KFImage(photoURL)
          .cacheOriginalImage()
          .placeholder {
            placeholder
          }
          .onFailure { _ in
            retryPhotoLookupAfterImageFailure()
          }
          .resizable()
          .aspectRatio(contentMode: .fill)
      } else {
        placeholder
      }
    }
    .frame(width: thumbnailSize, height: thumbnailSize)
    .clipped()
    .clipShape(RoundedRectangle(cornerRadius: 8))
    .accessibilityHidden(true)
    .onAppear {
      guard !didLoad else { return }
      didLoad = true
      INaturalistSpeciesPhotoCache.shared.photoURL(for: scientificName) { url in
        photoURL = url
      }
    }
  }

  private func retryPhotoLookupAfterImageFailure() {
    guard !didRetryAfterFailure else { return }
    didRetryAfterFailure = true

    INaturalistSpeciesPhotoCache.shared.invalidatePhotoURL(for: scientificName)
    INaturalistSpeciesPhotoCache.shared.photoURL(for: scientificName, forceRefresh: true) { url in
      photoURL = url
    }
  }

  private var placeholder: some View {
    ZStack {
      Color.gray.opacity(0.2)
      Image(systemName: "photo")
        .foregroundColor(.gray)
    }
  }
}

struct SpeciesINaturalistDetailPhotoView: View {
  let scientificName: String

  @State private var photoURL: URL?
  @State private var didLoad = false
  @State private var didRetryAfterFailure = false
  @State private var showPhoto = false

  var body: some View {
    ZStack {
      if let photoURL {
        KFImage(photoURL)
          .cacheOriginalImage()
          .placeholder {
            placeholder
          }
          .onFailure { _ in
            retryPhotoLookupAfterImageFailure()
          }
          .resizable()
          .aspectRatio(contentMode: .fit)
          .contentShape(Rectangle())
          .onTapGesture {
            showPhoto = true
          }
      } else {
        placeholder
      }
    }
    .frame(maxWidth: .infinity)
    .frame(minHeight: 180)
    .clipShape(RoundedRectangle(cornerRadius: 8))
    .accessibilityHidden(true)
    .onAppear {
      guard !didLoad else { return }
      didLoad = true
      INaturalistSpeciesPhotoCache.shared.photoURL(for: scientificName) { url in
        photoURL = url
      }
    }
    .fullScreenCover(isPresented: $showPhoto) {
      if let photoURL {
        ImagePagerView(imageURLs: [photoURL], isPresented: $showPhoto, startIndex: 0)
      }
    }
  }

  private func retryPhotoLookupAfterImageFailure() {
    guard !didRetryAfterFailure else { return }
    didRetryAfterFailure = true

    INaturalistSpeciesPhotoCache.shared.invalidatePhotoURL(for: scientificName)
    INaturalistSpeciesPhotoCache.shared.photoURL(for: scientificName, forceRefresh: true) { url in
      photoURL = url
    }
  }

  private var placeholder: some View {
    ZStack {
      Color.gray.opacity(0.2)
      Image(systemName: "photo")
        .foregroundColor(.gray)
    }
  }
}

final class INaturalistSpeciesPhotoCache {
  static let shared = INaturalistSpeciesPhotoCache()

  private let cacheKeyPrefix = "inaturalistSpeciesPhoto.v3."
  private let missingCacheKeyPrefix = "inaturalistSpeciesPhotoMissing.v3."
  private let missingCacheDuration: TimeInterval = 60 * 60 * 24
  private var memoryCache: [String: URL?] = [:]
  private var missingPhotoCache: [String: Date] = [:]
  private var inFlight: [String: [(URL?) -> Void]] = [:]

  private init() {}

  func photoURL(
    for scientificName: String,
    forceRefresh: Bool = false,
    completion: @escaping (URL?) -> Void
  ) {
    let normalizedName = scientificName.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !normalizedName.isEmpty else {
      completion(nil)
      return
    }

    let cacheKey = normalizedName.lowercased()

    if !forceRefresh, let cachedURL = memoryCache[cacheKey] {
      completion(cachedURL)
      return
    }

    if !forceRefresh, isMissingPhotoCacheValid(for: cacheKey) {
      completion(nil)
      return
    }

    if !forceRefresh, let cachedString = UserDefaults.standard.string(forKey: cacheKeyPrefix + cacheKey) {
      let cachedURL = URL(string: cachedString)
      memoryCache[cacheKey] = cachedURL
      completion(cachedURL)
      return
    }

    if inFlight[cacheKey] != nil {
      inFlight[cacheKey]?.append(completion)
      return
    }

    inFlight[cacheKey] = [completion]
    fetchPhotoURL(for: normalizedName) { [weak self] url in
      DispatchQueue.main.async {
        guard let self else { return }
        self.memoryCache[cacheKey] = url
        if let url {
          UserDefaults.standard.set(url.absoluteString, forKey: self.cacheKeyPrefix + cacheKey)
          UserDefaults.standard.removeObject(forKey: self.missingCacheKeyPrefix + cacheKey)
        } else {
          let now = Date()
          self.missingPhotoCache[cacheKey] = now
          UserDefaults.standard.set(now, forKey: self.missingCacheKeyPrefix + cacheKey)
        }

        let completions = self.inFlight.removeValue(forKey: cacheKey) ?? []
        completions.forEach { $0(url) }
      }
    }
  }

  func invalidatePhotoURL(for scientificName: String) {
    let cacheKey = scientificName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    guard !cacheKey.isEmpty else { return }

    memoryCache.removeValue(forKey: cacheKey)
    missingPhotoCache.removeValue(forKey: cacheKey)
    UserDefaults.standard.removeObject(forKey: cacheKeyPrefix + cacheKey)
    UserDefaults.standard.removeObject(forKey: missingCacheKeyPrefix + cacheKey)
  }

  private func isMissingPhotoCacheValid(for cacheKey: String) -> Bool {
    if let cachedDate = missingPhotoCache[cacheKey] {
      return Date().timeIntervalSince(cachedDate) < missingCacheDuration
    }

    if let cachedDate = UserDefaults.standard.object(forKey: missingCacheKeyPrefix + cacheKey) as? Date {
      if Date().timeIntervalSince(cachedDate) < missingCacheDuration {
        missingPhotoCache[cacheKey] = cachedDate
        return true
      }

      UserDefaults.standard.removeObject(forKey: missingCacheKeyPrefix + cacheKey)
      return false
    }

    if UserDefaults.standard.bool(forKey: missingCacheKeyPrefix + cacheKey) {
      UserDefaults.standard.removeObject(forKey: missingCacheKeyPrefix + cacheKey)
    }

    return false
  }

  private func fetchPhotoURL(for scientificName: String, completion: @escaping (URL?) -> Void) {
    var components = URLComponents(string: "https://api.inaturalist.org/v1/taxa/autocomplete")
    components?.queryItems = [
      URLQueryItem(name: "q", value: scientificName),
      URLQueryItem(name: "is_active", value: "true"),
      URLQueryItem(name: "per_page", value: "10")
    ]

    guard let url = components?.url else {
      completion(nil)
      return
    }

    var request = URLRequest(url: url)
    request.setValue("Ravens/1.0", forHTTPHeaderField: "User-Agent")

    URLSession.shared.dataTask(with: request) { data, _, _ in
      guard
        let data,
        let response = try? JSONDecoder().decode(INaturalistTaxaResponse.self, from: data),
        let photo = response.bestMatch(for: scientificName)?.defaultPhoto,
        let urlString = photo.smallURL ?? photo.mediumURL ?? photo.largeURL ?? photo.originalURL,
        let photoURL = URL(string: urlString)
      else {
        completion(nil)
        return
      }

      completion(photoURL)
    }.resume()
  }
}

private struct INaturalistTaxaResponse: Decodable {
  let results: [INaturalistTaxon]

  func bestMatch(for scientificName: String) -> INaturalistTaxon? {
    let normalizedName = scientificName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

    return results.first {
      $0.name.lowercased() == normalizedName && $0.defaultPhoto != nil
    }
  }
}

private struct INaturalistTaxon: Decodable {
  let name: String
  let defaultPhoto: INaturalistPhoto?

  enum CodingKeys: String, CodingKey {
    case name
    case defaultPhoto = "default_photo"
  }
}

private struct INaturalistPhoto: Decodable {
  let smallURL: String?
  let mediumURL: String?
  let largeURL: String?
  let originalURL: String?

  enum CodingKeys: String, CodingKey {
    case smallURL = "small_url"
    case mediumURL = "medium_url"
    case largeURL = "large_url"
    case originalURL = "original_url"
  }
}
