//
//  POIViewModel.swift
//  Ravens
//
//  Canonical filename for POI view model. Consolidates prior duplicates.
//

import Alamofire
import Foundation
import SwiftUI
import MapKit
import UIKit
import SwiftyBeaver

// To avoid duplicate symbol collisions with similarly named types elsewhere in the project,
// scope the model types inside the view model namespace and provide typealiases if needed.

// Primary ViewModel implementation is renamed locally to avoid redeclaration, while a typealias
// preserves the external API name `POIViewModel`.

// Note: Removed public typealias to avoid invalid redeclaration with other POIViewModel definitions.
@MainActor
public final class POIViewModelLocal: ObservableObject {
    public let log = SwiftyBeaver.self

    // Simple disk cache configuration
    private let cacheFileName = "poi-cache.json"
    private let defaultCacheExpiry: TimeInterval = 60 * 60 * 24 // 24 hours
    private var cacheExpiry: TimeInterval

    private var cacheURL: URL? {
        do {
            let caches = try FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            return caches.appendingPathComponent(cacheFileName)
        } catch {
            log.error("Failed to get caches directory: \(error.localizedDescription)")
            return nil
        }
    }

    private var now: Date { Date() }

    // Optional remote endpoint for live updates
    private var remoteURL: URL?

    // In-memory cache for current session
    private var memoryCache: [Model.POI]?

    // ETag persistence for conditional requests
    private let etagFileName = "poi-cache.etag"
    private var etagURL: URL? {
        do {
            let caches = try FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            return caches.appendingPathComponent(etagFileName)
        } catch {
            log.error("Failed to get caches directory for ETag: \(error.localizedDescription)")
            return nil
        }
    }

    private func readETag() -> String? {
        guard let url = etagURL else { return nil }
        return try? String(contentsOf: url, encoding: .utf8)
    }

    private func writeETag(_ etag: String) {
        guard let url = etagURL else { return }
        do {
            try etag.write(to: url, atomically: true, encoding: .utf8)
        } catch {
            log.warning("Failed to persist ETag: \(error.localizedDescription)")
        }
    }

    // MARK: - Cache Helpers
    private func readCacheData() -> Data? {
        guard let url = cacheURL else { return nil }
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
            if let modified = attributes[.modificationDate] as? Date {
                let age = now.timeIntervalSince(modified)
                if age > cacheExpiry {
                    log.info("Cache expired (age: \(Int(age))s).")
                    return nil
                }
            }
            let data = try Data(contentsOf: url)
            return data
        } catch {
            // Cache miss or read error is non-fatal
            log.info("No valid cache found: \(error.localizedDescription)")
            return nil
        }
    }

    private func writeCacheData(_ data: Data) {
        guard let url = cacheURL else { return }
        do {
            try data.write(to: url, options: .atomic)
            if let list = try? JSONDecoder().decode(Model.POIList.self, from: data) {
                self.memoryCache = list.poi
            }
            log.debug("Wrote POI cache to \(url.lastPathComponent).")
        } catch {
            log.error("Failed to write POI cache: \(error.localizedDescription)")
        }
    }

    @Published public var POIs: [Model.POI] = []

    public init(cacheExpiry: TimeInterval? = nil, remoteURL: URL? = nil) {
        self.cacheExpiry = cacheExpiry ?? defaultCacheExpiry
        self.remoteURL = remoteURL

        // Initial load
        Task { [weak self] in
            await self?.fetchPOIs()
        }

        // Background refresh on app foreground
        NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main) { [weak self] _ in
            guard let self else { return }
            // Prefer remote when app returns to foreground
            Task { await self.fetchPOIs(bypassCache: false, preferRemote: true) }
        }
    }

    // Public API to force refresh.
    // If forceRemote is true and remoteURL is set, tries network first.
    public func refresh(forceRemote: Bool = false) {
        Task { await fetchPOIs(bypassCache: forceRemote, preferRemote: forceRemote) }
    }

    public func fetchPOIs(bypassCache: Bool = false, preferRemote: Bool = false) async {
        let decoder = JSONDecoder()

        // In-memory cache hit if not bypassed
        if !bypassCache, let memory = memoryCache, !memory.isEmpty {
            self.POIs = memory
            log.debug("Loaded POIs from memory cache (\(memory.count) items).")
            return
        }

        // Optionally try remote first if requested
        if preferRemote, let url = remoteURL {
            if await fetchRemoteAndUpdate(decoder: decoder, url: url) { return }
            // If remote failed, continue to cache/bundle fallbacks
        }

        // Try disk cache unless bypassed
        if !bypassCache, let cached = readCacheData(), let list = try? decoder.decode(Model.POIList.self, from: cached) {
            self.POIs = list.poi
            self.memoryCache = list.poi
            log.debug("Loaded POIs from disk cache (\(list.poi.count) items).")
            return
        }

        // Fallback: load from bundled JSON
        if let localData = self.loadJsonFromFile() {
            if let list = try? decoder.decode(Model.POIList.self, from: localData) {
                self.POIs = list.poi
                self.memoryCache = list.poi
                writeCacheData(localData)
                log.debug("Loaded POIs from bundle (\(list.poi.count) items).")
            } else {
                log.error("Failed to decode poi.json into POIList")
            }
            return
        }

        // Try remote as a last resort if not already tried
        if let url = remoteURL {
            if await fetchRemoteAndUpdate(decoder: decoder, url: url) { return }
        }

        log.warning("No POI data available from memory, cache, bundle, or remote.")
    }

    // MARK: - Remote Fetch (async)
    @discardableResult
    private func fetchRemoteAndUpdate(decoder: JSONDecoder, url: URL) async -> Bool {
        do {
            var headers: HTTPHeaders = [:]
            if let etag = readETag() {
                headers.add(name: "If-None-Match", value: etag)
            }

            let request = AF.request(url, method: .get, headers: headers)
            let response = try await request.serializingData().response

            if response.response?.statusCode == 304 {
                // Not modified, keep current data (cache/memory already used)
                log.debug("Remote 304 Not Modified. Using cached data.")
                return true
            }

            guard let data = response.data else {
                log.warning("Remote returned no data.")
                return false
            }

            if let list = try? decoder.decode(Model.POIList.self, from: data) {
                self.POIs = list.poi
                self.memoryCache = list.poi
                self.writeCacheData(data)

                if let newETag = response.response?.allHeaderFields["Etag"] as? String ?? response.response?.allHeaderFields["ETag"] as? String {
                    self.writeETag(newETag)
                }

                log.debug("Loaded POIs from remote (\(list.poi.count) items).")
                return true
            } else {
                log.error("Remote data decode failed.")
                return false
            }
        } catch {
            log.warning("Remote fetch failed: \(error.localizedDescription)")
            return false
        }
    }

    private func loadJsonFromFile() -> Data? {
        if let path = Bundle.main.path(forResource: "poi", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                return data
            } catch {
                log.error("Error loading file: \(error.localizedDescription)")
            }
        } else {
            log.error("File poi.json not found in app bundle.")
        }
        return nil
    }

    // Namespace for model types to avoid global name collisions
    public enum Model {
        public struct POI: Decodable, Equatable {
            public let name: String
            public let coordinate: Coordinate
        }

        public struct Coordinate: Decodable, Equatable {
            public let latitude: Double
            public let longitude: Double

            public var cllocationCoordinate: CLLocationCoordinate2D {
                CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            }
        }

        public struct POIList: Decodable, Equatable {
            public let poi: [POI]
        }
    }
}

