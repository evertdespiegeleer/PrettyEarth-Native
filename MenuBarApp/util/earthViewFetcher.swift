//
//  earthViewFetcher.swift
//  MenuBarApp
//
//  Created by Evert De Spiegeleer on 13/11/2023.
//

import Foundation
import MapKit

class EarthViewFetcher: ObservableObject {
    var earthViews: [EarthViewMappedModel] = []
    @Published public var isFetchingViewList: Bool = true
    @Published public var isUpdatingView: Bool = true
    @Published public var chosenView: EarthViewMappedModel?
    @Published public var downloadedCurrentImageLocation: URL?
    @Published public var lastWallpaperSetTime: Date = Date(timeIntervalSince1970: TimeInterval(0))
    @Published public var isFetchingWikiExtract: Bool = true
    @Published public var wikiExtract: String? = nil
    @Published public var wikiLink: URL = URL(string: "https://en.wikipedia.org/wiki")!
    
    init () {
        self.isFetchingViewList = true
        Task{
            do {
                try await self.loadViewsList()
                try await self.setRandomWallpaper()
            }
            catch {
                print("Error loading views: \(error)")
            }
        }
    }
    
    private func loadViewsList() async throws {
        do {
//            try await Task.sleep(nanoseconds: UInt64(5 * 1000000000))
            let views = try await fetchEarthViewsData()
            DispatchQueue.main.sync {
                self.earthViews = views
                self.isFetchingViewList = false
                print(self.earthViews[0].imageUrl)
            }
        } catch {
            throw EarthViewFetcherError.loadFailed
        }
    }
    
    private func chooseRandomView () {
        DispatchQueue.main.sync {
            self.chosenView = earthViews[Int.random(in: Range(uncheckedBounds: (0, earthViews.count - 1)))]
        }
    }
    
    private func clearViewsFolder () async throws {
        let parentPath = FileManager.default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("PrettyEarth")
        
        let fileManager = FileManager.default
        
        // Check if the folder exists
        guard fileManager.fileExists(atPath: parentPath.path) else {
            print("Views folder doesn't exist, nothing to clear.")
            return
        }
        
        do {
                // Get the contents of the folder
                let contents = try fileManager.contentsOfDirectory(at: parentPath, includingPropertiesForKeys: nil, options: [])
                
                // Loop through and remove each item in the folder
                for item in contents {
                    try fileManager.removeItem(at: item)
                }
                
                print("Contents of the folder deleted successfully.")
            } catch {
                print("Error deleting contents of the folder: \(error)")
                throw error
            }
        
        DispatchQueue.main.sync {
            downloadedCurrentImageLocation = nil
        }

    }
    
    public func getViewFolderLocation () throws -> URL {
        if (self.chosenView == nil) {
            print("downloadChosenView: chosen view not specified")
            throw EarthViewFetcherError.chosenViewNotSpecified
        }
        
        return FileManager.default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("PrettyEarth")
            .appendingPathComponent(self.chosenView!.id)
    }
    
    public func getViewImageLocation () throws -> URL {
        return try getViewFolderLocation().appendingPathExtension("wallpaper.jpg")
    }
    
    private func downloadChosenView() async throws {
        if (self.chosenView == nil) {
            print("downloadChosenView: chosen view not specified")
            throw EarthViewFetcherError.chosenViewNotSpecified
        }
        
        // Create the folder path
        let folderPath = try self.getViewFolderLocation()
        
        // Create the folder if it doesn't exist
        do {
            try FileManager.default.createDirectory(at: folderPath, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("downloadChosenView: viewFolderCreationFailed")
            throw EarthViewFetcherError.viewFolderCreationFailed
        }
        
        // Construct the destination URL
        let destinationUrl = folderPath.appendingPathComponent("wallpaper.jpg")
        
        // Create a URLSession task to download the image
        do {
            let (_data, _) = try await URLSession.shared.data(from: self.chosenView!.imageUrl)
            try _data.write(to: destinationUrl)
        } catch {
            print("downloadChosenView: viewImageDownloadFailed")
            throw EarthViewFetcherError.viewImageDownloadFailed
        }
        
        DispatchQueue.main.sync {
            downloadedCurrentImageLocation = destinationUrl
        }
    }
    
    private func setDownloadedChosenViewAsWallpaper() throws {
        try setWallpaper(url: self.getViewFolderLocation().appendingPathComponent("wallpaper.jpg"))
        DispatchQueue.main.sync { self.lastWallpaperSetTime = Date() }
    }

    private func fetchWikiExtractForChosenView () {
//        let searchTerm = "\(self.chosenView!.regionName),\(self.chosenView!.country)"
        let searchTerm = self.chosenView!.regionName
        let link = URL(string: "https://en.wikipedia.org/wiki/\(searchTerm.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")")!
        DispatchQueue.main.sync {
            self.isFetchingWikiExtract = true
            self.wikiExtract = nil
        }
        fetchWikipediaExtract(for: searchTerm) { result in
                switch result {
                case .success(let extract):
                    DispatchQueue.main.sync {
                        self.wikiExtract = extract
                        self.isFetchingWikiExtract = false
                        self.wikiLink = link
                    }
                case .failure(let error):
                    print("fetchWikiExtractForChosenView: \(error)")
                    DispatchQueue.main.sync { self.isFetchingWikiExtract = false }
                }
        }
    }
    
    public func setRandomWallpaper() async throws {
        DispatchQueue.main.sync { self.isUpdatingView = true }
        do {
            self.chooseRandomView()
            try await self.clearViewsFolder()
            try await self.downloadChosenView()
            try self.setDownloadedChosenViewAsWallpaper()
            fetchWikiExtractForChosenView()
            DispatchQueue.main.sync { self.isUpdatingView = false }
        } catch {
            DispatchQueue.main.sync { self.isUpdatingView = false }
            throw error
        }
    }
}

enum EarthViewFetcherError: Error {
    case loadFailed
    case chosenViewNotSpecified
    case viewImageDownloadFailed
    case viewFolderCreationFailed
}
