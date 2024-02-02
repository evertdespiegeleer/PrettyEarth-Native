//
//  MenuBarAppApp.swift
//  MenuBarApp
//
//  Created by Evert De Spiegeleer on 07/11/2023.
//

import SwiftUI

@main
struct MenuBarAppApp: App {
    @State private var alertShown: Bool = false
    @State private var fetcher = EarthViewFetcher()
    
    init() {
        UserDefaults.standard.register(defaults: ["doAutoChange" : true])
        UserDefaults.standard.register(defaults: ["map" : "Google Maps"])
        UserDefaults.standard.register(defaults: ["autoChangeWallpaperFrequency" : AutoChangeWallpaperFrequencies.every12h.rawValue])
        self.scheduledNewView()
    }
    
    func scheduledNewView() {
        print("scheduledNewView")
        let doAutoChange: Bool = UserDefaults.standard.bool(forKey: "doAutoChange")
        let autoChangeWallpaperFrequency: AutoChangeWallpaperFrequencies = AutoChangeWallpaperFrequencies(rawValue: UserDefaults.standard.integer(forKey: "autoChangeWallpaperFrequency"))!

        if (doAutoChange && !fetcher.isFetchingViewList) {
            if (-1 * fetcher.lastWallpaperSetTime.timeIntervalSinceNow >= Double(autoChangeWallpaperFrequency.info.durationMillis) / 1000) {
                Task {
                    print("scheduledNewView: Set new wallpaper")
                    try await fetcher.setRandomWallpaper()
                }
            }
        }
        
        // Rerun this function in 20s
        DispatchQueue.main.asyncAfter(deadline: .now() + 20.0) { [self] in
            self.scheduledNewView()
        }
    }
    
    var body: some Scene {
        MenuBarExtra("PrettyEarth", systemImage: "globe.europe.africa.fill") {
                ContentView()
                    .environmentObject(fetcher)
//                    .onAppear() {
//                        self.scheduledNewView()
//                    }
        }
        .menuBarExtraStyle(.window)
    }
}
