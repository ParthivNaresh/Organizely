//
//  LocationPickerSheetView.swift
//  Organizer
//
//  Created by Parthiv Naresh on 4/28/24.
//

import SwiftUI
import MapKit


struct LocationPickerSheetView: View {
    @Binding var showingLocationPicker: Bool
    @Binding var selectedLocation: CLLocationCoordinate2D?
    @State private var position = MapCameraPosition.region(MKCoordinateRegion(
        center: CLLocationCoordinate2D(
            latitude: 37.7749,
            longitude: -122.4194),
        latitudinalMeters: 1000,
        longitudinalMeters: 1000
    ))
    @State private var searchQuery = ""
    @State private var pointsOfInterest: [MKPointOfInterest] = []
    @State private var showResults = false

    var body: some View {
        NavigationView {
            VStack {
                TextField("Search locations", text: $searchQuery, onEditingChanged: { isEditing in
                    showResults = isEditing
                }, onCommit: {
                    searchLocation()
                })
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                
                if showResults {
                    List(pointsOfInterest, id: \.id) { poi in
                        Button(action: {
                            selectedLocation = poi.coordinate
                            position = .region(MKCoordinateRegion(center: poi.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000))
                            showResults = false
                        }) {
                            VStack(alignment: .leading) {
                                Text(poi.placemark.name ?? "Unknown")
                                    .fontWeight(.medium)
                                Text(poi.placemark.title ?? "")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                } else {
                    Map(
                        position: $position,
                        interactionModes: [.rotate, .zoom, .pan]
                    ) {
                        if let selectedCoord = selectedLocation {
                            Annotation(
                                "Selected Location",
                                coordinate: selectedCoord
                            ) {
                                ZStack {
                                    Image(systemName: "mappin")
                                        .foregroundColor(.red)
                                        .imageScale(.large)
                                    Circle()
                                        .foregroundColor(.red.opacity(0.3))
                                        .frame(width: 50, height: 50)
                                }
                            }
                        }
                    }
                        .mapStyle(.hybrid)
                        .frame(height: 300)
                }

                Button("Select Location") {
                    if let first = pointsOfInterest.first {
                        selectedLocation = first.coordinate
                        showingLocationPicker = false
                    }
                }
                .disabled(pointsOfInterest.isEmpty)
                .padding()

                Spacer()
            }
            .navigationBarTitle("Select Location", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        showingLocationPicker = false
                    }
                }
            }
        }
    }
    
    private func searchLocation() {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchQuery
        let search = MKLocalSearch(request: request)
        search.start { response, _ in
            guard let response = response else {
                showResults = false
                return
            }
            pointsOfInterest = response.mapItems.map { MKPointOfInterest(placemark: $0.placemark) }
            showResults = true
        }
    }
}

struct MKPointOfInterest: Identifiable {
    let id = UUID()
    let placemark: MKPlacemark

    var coordinate: CLLocationCoordinate2D {
        placemark.coordinate
    }
}
