//
//  ContentView.swift
//  Basketball Runs Finder2
//
//  Created by Luis Garibay on 12/14/24.
//

import SwiftUI

struct ContentView: View {
    @State private var savedAddresses: [String] = []

    var body: some View {
        TabView {
            ViewA(savedAddresses: $savedAddresses)
                .tabItem {
                    Image(systemName: "mappin.and.ellipse.circle.fill")
                    Text("Maps")
                }

            ViewB(savedAddresses: savedAddresses)
                .tabItem {
                    Image(systemName: "sportscourt")
                    Text("Courts")
                }

            ViewC()
                .tabItem {
                    Image(systemName: "basketball.fill")
                    Text("Adult Leagues")
                }
        }
    }
}

#Preview {
    ContentView()
}
