//
//  GymLocationsStore.swift
//  Basketball Runs FInder2
//
//  Created by Luis Garibay on 3/10/25.
//

import SwiftUI
import MapKit

class GymLocationStore: ObservableObject {
    @Published var gymLocations: [String] = []  // Stores gym addresses

    func addGymLocation(from mapItem: MKMapItem) {
        let address = mapItem.placemark.title ?? "Unknown Address"
        if !gymLocations.contains(address) {
            gymLocations.append(address)
        }
    }
}
