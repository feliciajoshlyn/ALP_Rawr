//
//  LocationModel.swift
//  ALP_Rawr
//
//  Created by Dave Wirjoatmodjo on 23/05/25.
//

import Foundation
import CoreLocation

struct LocationModel: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D // buat lokasi latitude dan longitude
}
