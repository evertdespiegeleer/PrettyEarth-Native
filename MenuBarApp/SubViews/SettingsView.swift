//
//  SettingsView.swift
//  MenuBarApp
//
//  Created by Evert De Spiegeleer on 10/11/2023.
//

import SwiftUI
import LaunchAtLogin

enum AutoChangeWallpaperFrequencies: Int, CaseIterable {
    case every1m = 60000
    case every2m = 120000
    case every15m = 90000
    case every30m = 180000
    case every1h = 3600000
    case every2h = 7200000
    case every6h = 21600000
    case every12h = 43200000
    case every1d = 86400000
    case every2d = 172800000
    case every7d = 604800000
    case every14d = 1209600000
    case every30d = 2592000000

    var info: (label: String, durationMillis: Int) {
        switch self {
        case .every1m:
            return ("every 1m", 1 * 60000)
        case .every2m:
            return ("every 2m", 2 * 60000)
        case .every15m:
            return ("every 15m", 15 * 60000)
        case .every30m:
            return ("every 30m", 30 * 60000)
        case .every1h:
            return ("every 1h", 60 * 60000)
        case .every2h:
            return ("every 2h", 2 * 60 * 60000)
        case .every6h:
            return ("every 6h", 6 * 60 * 60000)
        case .every12h:
            return ("every 12h", 12 * 60 * 60000)
        case .every1d:
            return ("every 1d", 24 * 60 * 60000)
        case .every2d:
            return ("every 2d", 2 * 24 * 60 * 60000)
        case .every7d:
            return ("every 7d", 7 * 24 * 60 * 60000)
        case .every14d:
            return ("every 14d", 14 * 24 * 60 * 60000)
        case .every30d:
            return ("every 30d", 30 * 24 * 60 * 60000)
        }
    }
}

let mapOptions = [
    "Google Maps",
    "Apple Maps"
]

struct SettingsView: View {
    @State var doAutoChange: Bool = UserDefaults.standard.bool(forKey: "doAutoChange")
    @State var mapOption: String = UserDefaults.standard.string(forKey: "map") ?? "Google Maps"
    @State var autoChangeWallpaperFrequency: AutoChangeWallpaperFrequencies = AutoChangeWallpaperFrequencies(rawValue: UserDefaults.standard.integer(forKey: "autoChangeWallpaperFrequency"))!
    
    let defaults = UserDefaults.standard
    
    @ObservedObject private var launchAtLogin = LaunchAtLogin.observable
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                HStack {
                    Text("Automatically change \nwallpaper")
                    Spacer()
                    Toggle(isOn: $doAutoChange) {
                    }.toggleStyle(.checkbox)
                        .onChange(of: doAutoChange) {
                            UserDefaults.standard.setValue(doAutoChange, forKey: "doAutoChange")
                        }
                }
                
                HStack {
                    Text("Frequency")
                    Spacer()
                    Picker("", selection: $autoChangeWallpaperFrequency) {
                        ForEach(AutoChangeWallpaperFrequencies.allCases, id: \.self) { option in
                            Text(option.info.label)
                        }
                    }.pickerStyle(.menu)
                        .frame(maxWidth: 120)
                        .disabled(!doAutoChange)
                        .onChange(of: autoChangeWallpaperFrequency) {
                            UserDefaults.standard.setValue(autoChangeWallpaperFrequency.rawValue, forKey: "autoChangeWallpaperFrequency")
                        }
                }
                
                Divider()
                    .padding(10)
                
                HStack {
                    Text("Open location in")
                    Spacer()
                    Picker("", selection: $mapOption) {
                        ForEach(mapOptions, id: \.self) { option in
                            Text(option)
                        }
                    }.pickerStyle(.menu)
                        .frame(maxWidth: 120)
                        .onChange(of: mapOption) {
                            UserDefaults.standard.setValue(mapOption, forKey: "map")
                        }
                }
                
                Divider()
                    .padding(10)
                
                HStack {
                    Text("Start PrettyEarth at login")
                    Spacer()
                    Toggle(isOn: $launchAtLogin.isEnabled) {
                    }.toggleStyle(.checkbox)
                }
                
                Divider()
                    .padding(10)
                
                HStack {
                    Spacer()
                    Button(action: {
                        exit(0)
                    }, label: {
                        Label("Quit PrettyEarth", systemImage: "stop.circle.fill")
                            .padding(5)
                    })
                }
                
            }.padding()
        }
    }
}

#Preview {
    SettingsView()
}
