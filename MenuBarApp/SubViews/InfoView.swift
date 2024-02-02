//
//  InfoView.swift
//  MenuBarApp
//
//  Created by Evert De Spiegeleer on 10/11/2023.
//

import SwiftUI
import MapKit
import Foundation

struct InfoView: View {
    var body: some View {
        VStack() {
            Spacer()
            Text("Made with ❤️ by")
            Link("Evert De Spiegeleer", destination: URL(string: "https://evertdespiegeleer.com")!)
            Spacer()
        }
    }
}

#Preview {
    InfoView()
}
