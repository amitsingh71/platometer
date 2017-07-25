//
//  MakePolygonModel.swift
//  Platometer
//
//  Created by Deblina Das on 22/07/17.
//  Copyright © 2017 Hummingwave Technologies. All rights reserved.
//

import Foundation
import MapKit

class MakePolygonModel {
    
    
    func sortConvex(input: [CLLocationCoordinate2D]) -> [CLLocationCoordinate2D] {
        
        // X = longitude
        // Y = latitude
        
        // 2D cross product of OA and OB vectors, i.e. z-component of their 3D cross product.
        // Returns a positive value, if OAB makes a counter-clockwise turn,
        // negative for clockwise turn, and zero if the points are collinear.
        func cross(point P: CLLocationCoordinate2D, pointA A: CLLocationCoordinate2D, pointB B: CLLocationCoordinate2D) -> Double {
            let part1 = (A.longitude - P.longitude) * (B.latitude - P.latitude)
            let part2 = (A.latitude - P.latitude) * (B.longitude - P.longitude)
            return part1 - part2;
        }
        
        // Sort points lexicographically
        let points = input.sorted() {
            $0.longitude == $1.longitude ? $0.latitude < $1.latitude : $0.longitude < $1.longitude
        }
        
        // Build the lower hull
        var lower: [CLLocationCoordinate2D] = []
        for p in points {
            while lower.count >= 2 && cross(point: lower[lower.count-2], pointA: lower[lower.count-1], pointB: p) <= 0 {
                lower.removeLast()
            }
            lower.append(p)
        }
        
        // Build upper hull
        var upper: [CLLocationCoordinate2D] = []
        for p in points.reversed() {
            while upper.count >= 2 && cross(point: upper[upper.count-2], pointA: upper[upper.count-1], pointB: p) <= 0 {
                upper.removeLast()
            }
            upper.append(p)
        }
        
        // Last point of upper list is omitted because it is repeated at the
        // beginning of the lower list.
        upper.removeLast()
        
        // Concatenation of the lower and upper hulls gives the convex hull.
        return (upper + lower)
    }
}
