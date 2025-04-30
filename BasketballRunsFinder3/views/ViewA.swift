//
//  ViewA.swift
//  Basketball Runs FInder2
//
//  Created by Luis Garibay on 12/14/24.
//

import SwiftUI
import MapKit

struct ViewA: View {
    @Binding var savedAddresses: [String]
    @State private var cameraPosition: MapCameraPosition = .region(.userRegion)
    @State private var searchText = ""
    @State private var results = [MKMapItem]()
    @State private var mapSelection: MKMapItem?
    @State private var showDetails = false
    @State private var getDirections = false
    @State private var routeDisplaying = false
    @State private var route: MKRoute?
    @State private var routeDestination: MKMapItem?
    @State private var selectedGymName: String = "No location selected"
    @State private var showSaved = false

    var body: some View {
        VStack {
            Map(position: $cameraPosition, selection: $mapSelection){
                Annotation("My location", coordinate: .userLocation){
                    ZStack{
                        Circle()
                            .frame(width: 32, height: 32)
                            .foregroundColor(.blue.opacity(0.25))

                        Circle()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.white)

                        Circle()
                            .frame(width: 12, height: 12)
                            .foregroundColor(.blue)
                    }
                }

                ForEach(results, id: \.self){ item in
                    let placemark = item.placemark
                    Marker(placemark.name ?? "", coordinate: placemark.coordinate)
                }

                if let route {
                    MapPolyline(route.polyline)
                        .stroke(.blue, lineWidth: 6)
                }
            }
            .frame(height: 400)
            .overlay(alignment: .top){
                TextField("Search for a location...", text: $searchText)
                    .font(.subheadline)
                    .padding(12)
                    .background(.white)
                    .padding()
                    .shadow(radius: 10)
            }
            .onSubmit(of: .text){
                Task{ await searchPlaces() }
            }
            .onChange(of: getDirections, { oldValue, newValue in
                if newValue {
                    fetchRoute()
                }
            })
            .onChange(of: mapSelection) { oldValue, newValue in
                showDetails = newValue != nil
                if let placemark = newValue?.placemark {
                    selectedGymName = placemark.name ?? "Unknown Location"

                    let address = formatAddress(from: placemark)
                    if !savedAddresses.contains(address) {
                        savedAddresses.append(address)
                    }
                }
            }
            .sheet(isPresented: $showDetails, content: {
                LocationDetailView(mapSelection: $mapSelection, show: $showDetails, getDirections: $getDirections)
                    .presentationDetents([.height(340)])
                    .presentationBackgroundInteraction(.enabled(upThrough: .height(340)))
                    .presentationCornerRadius(12)
            })
            .mapControls {
                MapPitchToggle()
                MapUserLocationButton()
                MapCompass()
            }

            Button("Show Saved Addresses") {
                showSaved = true
            }
            .padding()
            .sheet(isPresented: $showSaved) {
                VStack {
                    Text("Saved Addresses")
                        .font(.headline)
                        .padding()

                    List(savedAddresses, id: \.self) { address in
                        Text(address)
                    }

                    Button("Close") {
                        showSaved = false
                    }
                    .padding()
                }
            }
        }
    }
}

extension ViewA {
    func searchPlaces() async {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        request.region = .userRegion

        let results = try? await MKLocalSearch(request: request).start()
        self.results = results?.mapItems ?? []
    }

    func fetchRoute(){
        if let mapSelection {
            let request = MKDirections.Request()
            request.source = MKMapItem(placemark: .init(coordinate: .userLocation))
            request.destination = mapSelection

            Task {
                let result = try? await MKDirections(request: request).calculate()
                route = result?.routes.first
                routeDestination = mapSelection

                withAnimation(.snappy){
                    routeDisplaying = true
                    showDetails = false

                    if let rect = route?.polyline.boundingMapRect, routeDisplaying {
                        cameraPosition = .rect(rect)
                    }
                }
            }
        }
    }

    func formatAddress(from placemark: MKPlacemark) -> String {
        var address = ""

        if let subThoroughfare = placemark.subThoroughfare {
            address += subThoroughfare + " "
        }

        if let thoroughfare = placemark.thoroughfare {
            address += thoroughfare + ", "
        }

        if let locality = placemark.locality {
            address += locality + ", "
        }

        if let administrativeArea = placemark.administrativeArea {
            address += administrativeArea + " "
        }

        if let postalCode = placemark.postalCode {
            address += postalCode
        }

        return address
    }
}

extension CLLocationCoordinate2D{
    static var userLocation: CLLocationCoordinate2D{
        return .init(latitude: 34.0549, longitude: -118.2426)
    }
}

extension MKCoordinateRegion {
    static var userRegion: MKCoordinateRegion {
        return .init(center: .userLocation,
                    latitudinalMeters: 10000,
                    longitudinalMeters: 10000)
    }
}

#Preview {
    ViewA(savedAddresses: .constant([]))
}
