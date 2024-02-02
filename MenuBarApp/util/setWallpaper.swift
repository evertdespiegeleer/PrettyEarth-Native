//
//  setWallpaper.swift
//  MenuBarApp
//
//  Created by Evert De Spiegeleer on 10/11/2023.
//

import Foundation
import AppKit

func setWallpaper(url: URL) {
    do {
        let imgurl = url
        let workspace = NSWorkspace.shared
        try NSScreen.screens.forEach { screen in
            try workspace.setDesktopImageURL(url, for: screen, options: [:])
        }
    } catch {
        print(error)
    }
}
