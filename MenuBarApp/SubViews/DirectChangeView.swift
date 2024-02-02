//
//  DirectChangeView.swift
//  MenuBarApp
//
//  Created by Evert De Spiegeleer on 10/11/2023.
//

import SwiftUI
import MapKit
import Foundation

struct DirectChangeView: View {
    @EnvironmentObject var fetcher: EarthViewFetcher
    
    var body: some View {
        VStack() {
            Spacer()
            if (fetcher.isFetchingViewList || fetcher.isUpdatingView) {
                ProgressView()
                if (fetcher.isUpdatingView) {
                    Text("Updating...")
                        .padding(10)
                }
            } else {
                Button(action: {
                    Task {
                        try await fetcher.setRandomWallpaper()
                    }
                }, label: {
                    Label("New wallpaper", systemImage: "wand.and.stars")
                        .padding(10)
                })
            }
            Spacer()
        }
    }
}

#Preview {
    DirectChangeView()
}
