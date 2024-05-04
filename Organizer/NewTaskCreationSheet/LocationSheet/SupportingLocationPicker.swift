//
//  Supporting.swift
//  Organizer
//
//  Created by Parthiv Naresh on 5/2/24.
//

import CoreLocation


func reverseGeocode(latitude: CLLocationDegrees, longitude: CLLocationDegrees, completion: @escaping (String) -> Void) {
    let geocoder = CLGeocoder()
    let location = CLLocation(latitude: latitude, longitude: longitude)

    geocoder.reverseGeocodeLocation(location) { placemarks, error in
        if let error = error {
            print("Reverse geocoding failed: \(error.localizedDescription)")
            completion("Unable to find address")
            return
        }

        if let placemark = placemarks?.first,
           let street = placemark.thoroughfare,
           let city = placemark.locality,
           let state = placemark.administrativeArea,
           let postalCode = placemark.postalCode,
           let country = placemark.country {
            completion("\(street), \(city), \(state) \(postalCode), \(country)")
        } else {
            completion("Unable to find address")
        }
    }
}
