//
//  MapPoint.swift
//  Platometer
//
//  Created by Deblina Das on 18/07/17.
//  Copyright © 2017 DeblinaOwned. All rights reserved.
//

import Foundation
import MapKit

class MapPoint: NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
        super.init()
    }
}
