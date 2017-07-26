//
//  MapPoint.swift
//  Platometer
//
//  Created by Deblina Das on 18/07/17.
//  Copyright © 2017 Hummingwave Technologies. All rights reserved.
//

import Foundation
import MapKit

class MapPoint: NSObject, MKAnnotation {
    
    static let reuseIdentifier = "Reuse Identifier for Map Point"
    static let image = #imageLiteral(resourceName: "annotation")
    var coordinate: CLLocationCoordinate2D
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
        super.init()
    }
    
}

class AnnotationView: MKAnnotationView {
    
    convenience init(annotation: MKAnnotation) {
        self.init(annotation: annotation, reuseIdentifier: MapPoint.reuseIdentifier)
        image = MapPoint.image
        isDraggable = true
    }
    
    private override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
