//
//  Platometer.swift
//  Platometer
//
//  Created by Trinetra K S on 26/07/17.
//  Copyright © 2017 Hummingwave Technologies. All rights reserved.
//

import UIKit
import CoreLocation

struct PolygonPoint {
    let x: CLLocationDistance
    let y: CLLocationDistance
}

// Area in SqFeet
func areaOfGeo(points: [CLLocation]) -> Double? {
    guard points.count > 1 else { return nil }
    let referencePoint = points.first!
    let pointsInMetres: [PolygonPoint] = points.map {
        let xAxisPoint = CLLocation(latitude: referencePoint.coordinate.latitude, longitude: $0.coordinate.longitude)
        var xDistance  = referencePoint.distance(from: xAxisPoint)
        xDistance = $0.coordinate.longitude > referencePoint.coordinate.longitude ? xDistance : -xDistance
        let yAxisPoint = CLLocation(latitude: $0.coordinate.latitude, longitude: referencePoint.coordinate.longitude)
        var yDistance  = referencePoint.distance(from: yAxisPoint)
        yDistance = $0.coordinate.latitude > referencePoint.coordinate.latitude   ? yDistance : -yDistance
        return PolygonPoint(x: xDistance, y: yDistance)
    }
    return areaOfPolygon(points: pointsInMetres) * 10.76391041671
}

// Algorithm to find the area of a polygon.
private func areaOfPolygon(points: [PolygonPoint]) -> Double {
    var area: Double = 0.0         // Accumulates area in the loop
    var j: Int = points.count - 1  // The last vertex is the 'previous' one to the first
    for i in 0...(points.count - 1) {
        area = area +  (points[j].x + points[i].x) * (points[j].y - points[i].y)
        j = i;                     // j is previous vertex to i
    }
    return area / 2;
}

