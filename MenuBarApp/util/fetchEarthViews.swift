//
//  fetchEarthViews.swift
//  MenuBarApp
//
//  Created by Evert De Spiegeleer on 11/11/2023.
//

import Foundation
import MapKit

struct EarthViewApiModel: Codable {
  let id: String
  let country: String
  let image: String
    let thumb: String
    let map: String
    let region: String
}

typealias EarthViewApiResponse = [EarthViewApiModel]

struct EarthViewMappedModel {
    let id: String
    let country: String
    let imageUrl: URL
      let thumbUrl: URL
      let coordinates: CLLocationCoordinate2D
      let regionName: String
}

func coordinateFromGoogleMapsURL(_ url: URL) -> CLLocationCoordinate2D? {
    guard let urlString = url.absoluteString.removingPercentEncoding else {
        return nil
    }
    
    let pattern = #"\@([-0-9.]+),([-0-9.]+)"#
    let regex = try! NSRegularExpression(pattern: pattern)
    let matches = regex.matches(in:urlString, range:NSMakeRange(0, urlString.utf16.count))
    
    let latRange = matches[0].range(at: 1)
    let lngRange = matches[0].range(at: 2)
    
    let lat = Double(urlString[Range(latRange, in: urlString)!])!
    let lng = Double(urlString[Range(lngRange, in: urlString)!])!

    return CLLocationCoordinate2D(latitude: lat, longitude: lng)
}

func fetchEarthViewsData() async throws -> [EarthViewMappedModel] {
    guard let url = URL(string: "https://raw.githubusercontent.com/evertdespiegeleer/PrettyEarth-webscraper/master/output/prettyOutput.json") else {
        throw ViewsFetchingError.invalidURL
    }
    
    var data: Data = Data()
    do {
        let (_data, _) = try await URLSession.shared.data(from: url)
        data = _data
    } catch {
        throw ViewsFetchingError.fetchingFailed
    }
    
    var mapped: [EarthViewMappedModel] = []
    do {
        let views = try JSONDecoder().decode(EarthViewApiResponse.self, from: data)
        mapped = try views.map { apiView in
            guard let mapUrl = URL(string: apiView.map) else {
                throw ViewsFetchingError.invalidURL
            }
            guard let coordinates = coordinateFromGoogleMapsURL(mapUrl) else {
                throw ViewsFetchingError.invalidCoordinates
            }
            return EarthViewMappedModel(id: apiView.id, country: apiView.country, imageUrl: URL(string: apiView.image)!, thumbUrl: URL(string: apiView.thumb)!, coordinates: coordinates, regionName: apiView.region)
        }
    } catch {
        throw ViewsFetchingError.parsingFailed
    }
    
    return mapped
}

enum ViewsFetchingError: Error {
    case invalidURL
    case invalidCoordinates
    case parsingFailed
    case missingData
    case fetchingFailed
}

