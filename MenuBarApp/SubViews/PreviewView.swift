//
//  PreviewView.swift
//  MenuBarApp
//
//  Created by Evert De Spiegeleer on 10/11/2023.
//

import SwiftUI
import AppKit
import MapKit
import Foundation

struct PreviewView: View {
    @EnvironmentObject var fetcher: EarthViewFetcher
    @State var hoveringMap: Bool = false;
    
    var body: some View {
        if (!fetcher.isFetchingViewList && !fetcher.isUpdatingView && (fetcher.chosenView != nil)) {
            ZStack {
                HStack(spacing: 0) {
                    ScrollView {
                        VStack(alignment: .leading) {
                            Text(fetcher.chosenView!.regionName)
                                .font(.title2)
                                .padding(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0))
                            Text(fetcher.chosenView!.country)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Divider()
                            if (fetcher.isFetchingWikiExtract) {
                                HStack(alignment: .center) {
                                    Spacer()
                                    ProgressView()
                                        .padding(10)
                                    Spacer()
                                }
                            }
                            else if (fetcher.wikiExtract != nil) {
                                Text(fetcher.wikiExtract!)
                                HStack{
                                    Spacer()
                                    Link(destination: fetcher.wikiLink) {
                                        Label("Continue reading on Wikipedia", systemImage: "book")
                                    }
                                    Spacer()
                                }
                            }
                        }
                    }
                    .padding(10)
                    // Place a rectangle here to keep the text the same width
                    Rectangle()
                        .frame(width: 80)
                        .opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/)
                }
                // Overlay in which the map is able to expand
                HStack(spacing: 0) {
                    Spacer()
                    ZStack {
                        //                        Map(initialPosition: .region(MKCoordinateRegion(center: fetcher.chosenView!.coordinates, latitudinalMeters:400, longitudinalMeters: 400)))
                        //                            .mapStyle(.imagery)
                        //                            .mapControlVisibility(.hidden)
                        //                            .disabled(true)
                        //                            .blur(radius: hoveringMap ? 3 : 0)
                        if (fetcher.downloadedCurrentImageLocation != nil) {
                            Image(nsImage: NSImage(contentsOf: fetcher.downloadedCurrentImageLocation!) ?? NSImage())
                                .resizable()
                                .blur(radius: hoveringMap ? 1 : 0)
                                .scaledToFill()
                                .frame(width: hoveringMap ? 150 : 80, alignment: .leading)
                                .clipped()
                        }
                        ZStack {
                            Rectangle()
                                .background(.windowBackground)
                                .opacity(0.6)
                            Text("Open maps →")
                                .foregroundStyle(.foreground)
                                .colorInvert()
                                .font(.system(size: 16))
                                .blur(radius: hoveringMap ? 0 : 3)
                        }
                        .onTapGesture {
                            openMaps(location: fetcher.chosenView!.coordinates, app: UserDefaults.standard.string(forKey: "map") == "Google Maps" ? .google : .apple)
                        }
                        .opacity(hoveringMap ? 1 : 0)
                    }
                    .onHover(perform: { hovering in
                        hoveringMap = hovering
                    })
                    .cursor(.pointingHand)
                    .frame(width: hoveringMap ? 150 : 80)
                    .clipped()
                    .shadow(radius: hoveringMap ? 5 : 0)
                    .animation(.easeInOut(duration: 0.2), value: hoveringMap)
                }
            }
        }
        else {
            HStack {
                Spacer()
                ProgressView()
                Spacer()
            }
        }
    }
}

//#Preview {
//    PreviewView(earthView: EarthViewMappedModel(id: "1234", country: "Belgium", imageUrl: URL(string: "https://www.gstatic.com/prettyearth/assets/full/1003.jpg")!, thumbUrl: URL(string: "https://www.gstatic.com/prettyearth/assets/preview/1003.jpg")!, coordinates: CLLocationCoordinate2D(latitude: 50, longitude: 3), regionName: "Herzele"))
//}
