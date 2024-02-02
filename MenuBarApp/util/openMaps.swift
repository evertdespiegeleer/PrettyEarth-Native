//
//  openMaps.swift
//  MenuBarApp
//
//  Created by Evert De Spiegeleer on 11/11/2023.
//

import Foundation
import MapKit
import AppKit

enum MapsProviders: String {
    case apple, google
}

func openMaps(location: CLLocationCoordinate2D, app: MapsProviders) {
    var url: URL
    switch (app) {
        case .apple: do {
            url = URL(string: "http://maps.apple.com/?ll=\(location.latitude),\(location.longitude)")!
        }
        case .google: do {
            url = URL(string: "http://www.google.com/maps/place/\(location.latitude),\(location.longitude)/data=!3m1!1e3")!
        }
    }

    NSWorkspace.shared.open(url)
}
