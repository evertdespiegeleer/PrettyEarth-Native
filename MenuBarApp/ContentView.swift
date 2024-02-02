//
//  ContentView.swift
//  MenuBarApp
//
//  Created by Evert De Spiegeleer on 07/11/2023.
//

import SwiftUI
import MapKit

struct MenuItem {
    var systemImage: String
    var view: AnyView?
}

enum MenuItems: String, CaseIterable {
    case preview
    case directChange
    case settings
    case info

    func getItemDetails() -> MenuItem {
        switch self {
        case .preview:
            return MenuItem(systemImage: "newspaper", view: AnyView(PreviewView()))
        case .directChange:
            return MenuItem(systemImage: "globe.americas.fill", view: AnyView(DirectChangeView()))
        case .settings:
            return MenuItem(systemImage: "gearshape", view: AnyView(SettingsView()))
        case .info:
            return MenuItem(systemImage: "info.circle", view: AnyView(InfoView()))
        }
    }
}

struct ContentView: View {
    @State var currentView: MenuItems = .preview
    @EnvironmentObject var fetcher: EarthViewFetcher
    
    var body: some View {
        VStack(spacing: 0) {
            $currentView.wrappedValue.getItemDetails().view
                .frame(maxHeight: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                .environmentObject(fetcher)
                .clipped()
            Divider()
            HorizontalMenu(currentMenuItem: $currentView)
                .padding(EdgeInsets(top: 10, leading: 30, bottom: 10, trailing: 30))
        }
        .frame(width: 300, height: 200)
        .background(.windowBackground)
    }
}

//#Preview {
//    ContentView()
//}
