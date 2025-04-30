//
//  ViewB.swift
//  Basketball Runs Finder2
//
//  Created by Luis Garibay on 12/14/24.
//

import SwiftUI

struct BasketballLocation: Identifiable {
    var id = UUID()
    var isFollowing: Bool = false
    var filledCircles: Int = 0
    var selectedBox: Int? = nil
}

struct ViewB: View {
    var savedAddresses: [String]

    @State private var locations: [String: BasketballLocation]
    @State private var selectedAddress: String

    // Initialize with addresses and default location state per address
    init(savedAddresses: [String]) {
        self.savedAddresses = savedAddresses
        let initialAddress = savedAddresses.first ?? "No gym selected"
        _selectedAddress = State(initialValue: initialAddress)

        let locationDict = Dictionary(uniqueKeysWithValues:
            savedAddresses.map { ($0, BasketballLocation()) }
        )
        _locations = State(initialValue: locationDict)
    }

    // Binding to the current selected location
    private var currentLocationBinding: Binding<BasketballLocation> {
        Binding(
            get: { locations[selectedAddress] ?? BasketballLocation() },
            set: { newValue in locations[selectedAddress] = newValue }
        )
    }

    var body: some View {
        ZStack {
            Rectangle()
                .foregroundStyle(.orange.gradient.opacity(0.8))
                .ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: true) {
                VStack(spacing: 20) {
                    GroupBox {
                        VStack(spacing: 15) {
                            // Location Selection
                            HStack {
                                Text("Basketball Location:")
                                    .font(.headline)

                                Menu {
                                    ForEach(savedAddresses, id: \.self) { address in
                                        Button(address) {
                                            selectedAddress = address
                                        }
                                    }
                                } label: {
                                    HStack {
                                        Text(selectedAddress)
                                            .font(.subheadline)
                                            .foregroundColor(.orange)
                                        Image(systemName: "chevron.down")
                                            .foregroundColor(.gray)
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(Color.white.opacity(0.9))
                                    .cornerRadius(8)
                                    .shadow(radius: 2)
                                }
                            }
                            .padding(.bottom, 5)

                            GroupBox {
                                Image("outdoor_court")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 200)
                                    .clipShape(RoundedRectangle(cornerRadius: 15))
                                    .shadow(radius: 5)

                                HStack {
                                    Image(systemName: "basketball.circle.fill")
                                        .foregroundColor(.orange)
                                    Text("Basketball games 5v5")
                                        .font(.subheadline)
                                }

                                HStack {
                                    Image(systemName: "cursorarrow.click.badge.clock")
                                    Text("Games wait time:")
                                        .font(.subheadline)
                                }
                                .padding(.top, 5)
                            }

                            // Selection Boxes (0 to 4)
                            HStack(spacing: 15) {
                                ForEach(0...4, id: \.self) { num in
                                    Text("\(num)")
                                        .font(.title2)
                                        .frame(width: 50, height: 50)
                                        .background(
                                            currentLocationBinding.wrappedValue.selectedBox == num
                                                ? Color.orange.opacity(0.2)
                                                : Color.gray.opacity(0.2)
                                        )
                                        .cornerRadius(8)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(currentLocationBinding.wrappedValue.selectedBox == num ? Color.orange : Color.clear, lineWidth: 4)
                                                .shadow(color: currentLocationBinding.wrappedValue.selectedBox == num ? Color.orange.opacity(0.8) : Color.clear, radius: 5)
                                        )
                                        .onTapGesture {
                                            withAnimation {
                                                currentLocationBinding.wrappedValue.selectedBox = num
                                            }
                                        }
                                }
                            }
                            .padding(.top, 10)

                            // Follow / Unfollow Button with Circle Progress Logic
                            Button(action: {
                                withAnimation {
                                    currentLocationBinding.wrappedValue.isFollowing.toggle()
                                    currentLocationBinding.wrappedValue.filledCircles = currentLocationBinding.wrappedValue.isFollowing ? 1 : 0
                                }
                            }) {
                                Text(currentLocationBinding.wrappedValue.isFollowing ? "Unfollow" : "Follow")
                                    .font(.headline)
                                    .frame(width: 150, height: 40)
                                    .background(currentLocationBinding.wrappedValue.isFollowing ? Color.red : Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                    .shadow(radius: 3)
                            }
                            .padding(.top, 10)

                            // Circle Progress View (Turns green when following)
                            HStack(spacing: 8) {
                                ForEach(0..<10, id: \.self) { circleIndex in
                                    Circle()
                                        .frame(width: 20, height: 20)
                                        .foregroundColor(circleIndex < currentLocationBinding.wrappedValue.filledCircles ? .green : .gray.opacity(0.5))
                                }
                            }
                            .padding(.top, 10)
                        }
                    } label: {
                        Label("Now playing", systemImage: "figure.basketball")
                            .font(.headline)
                    }
                    .padding()
                }
                .padding(.vertical, 10)
            }
        }
    }
}

#Preview {
    ViewB(savedAddresses: [
        "Crosscourt: 333 N Mission Rd",
        "Leavey Gymnasium: 1901 Venice Blvd",
        "Lafayette Basketball Court: 2801 Wilshire Blvd"
    ])
}
