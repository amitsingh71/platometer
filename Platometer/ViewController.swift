//
//  ViewController.swift
//  Platometer
//
//  Created by Deblina Das on 18/07/17.
//  Copyright © 2017 DeblinaOwned. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate {

    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var startSessionButton: UIButton!
    @IBOutlet var areaLabel: UILabel!
    
    var locationManager = CLLocationManager()
    // Array of annotations - modified when the points are changed.
    var annotations = [MapPoint]()
    // Current polygon displayed in the overlay.
    var polygon: MKPolygon?
    private(set) var makePolygon = MakePolygonModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = 1 // 1 meter
        locationManager.distanceFilter = 1
        locationManager.requestWhenInUseAuthorization()
    }

    var locationCordinates = [CLLocationCoordinate2D]()
    
    func addPolyLine() {
        mapView.overlays.forEach {
            mapView.removeOverlays([$0])
        }
        //Close path polyline
        var localAnnotations = annotations.map{$0}
        localAnnotations.append(annotations.first!)
        mapView.add(MKPolyline(coordinates: localAnnotations.map{$0.coordinate}, count: annotations.map{$0.coordinate}.count + 1))
    }
    
    func addAnnotation(to location: CLLocation) {
        let annotation = MapPoint(coordinate: location.coordinate)
        mapView.addAnnotation(annotation)
        annotations.append(annotation)
    }

    private var isStarted:Bool = false
    
    @IBAction func startSessionButtonTapped(_ sender: UIButton) {
        isStarted = isStarted ? false : true
        if isStarted {
            locationManager.startUpdatingLocation()
        } else {
            locationManager.stopUpdatingLocation()
        }
        DispatchQueue.main.async {
            self.startSessionButton.setTitle(self.isStarted ? "END" : "START", for: .normal)
            self.startSessionButton.tintColor = self.isStarted ? UIColor.blue : UIColor.red
        }
    }
    
    func updateOverlay() {
        
        // Remove existing overlay.
        if let polygon = self.polygon { mapView.remove(polygon) }
        self.polygon = nil
        if annotations.count < 3 { print("Not enough coordinates")
            return
        }
        // Create coordinates for new overlay.
        let coordinates = annotations.map({ $0.coordinate })
        // Sort the coordinates to create a path surrounding the points.
        // Remove this if you only want to draw lines between the points.
        var hull = makePolygon.sortConvex(input: coordinates)
        let polygon = MKPolygon(coordinates: &hull, count: hull.count)
        areaLabel.text = "\(polygon.boundingMapRect.size.width * polygon.boundingMapRect.size.height) sq."
        //print(polygon.boundingMapRect)
        mapView.add(polygon)
        self.polygon = polygon
    }
}

extension ViewController: MKMapViewDelegate, UIGestureRecognizerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        locations.forEach {self.locationCordinates.append($0.coordinate)}
        addAnnotation(to: location)
        updateOverlay()
        addPolyLine()
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard overlay is MKPolyline else { return MKOverlayRenderer(overlay: overlay) }
        let polylineRenderer = MKPolylineRenderer(overlay: overlay)
        polylineRenderer.strokeColor = UIColor(red: 0, green: 178.0/255.0, blue: 1, alpha: 1)
        polylineRenderer.lineWidth = 4
        return polylineRenderer
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? MapPoint else { return nil }
        let reuseIdentifier = "Reuse Identifier for location"
        let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier) ??
            MKAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
        annotationView.image = UIImage(named: "annotation")
        annotationView.isDraggable = true
        
        let longPress = UILongPressGestureRecognizer.init(target: self, action: #selector(deleteAnnotationOnLongPress(gesture:annotationView:)))
        longPress.minimumPressDuration = 0.3
        longPress.delegate = self
        annotationView.addGestureRecognizer(longPress)
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
        if newState == .ending || newState == .canceling {
            view.dragState = .none
            updateOverlay()
            addPolyLine()
        } else if newState == .starting {
            view.dragState = .dragging
        }
    }
    
    func deleteAnnotationOnLongPress(gesture: UIGestureRecognizer, annotationView: MKAnnotationView) {
        for annotation in mapView.annotations {
            if let annotation = annotation as? MapPoint, annotationView.annotation as? MapPoint == annotation {
                self.annotations = self.annotations.filter{$0 != annotationView.annotation as? MapPoint}
                self.mapView.removeAnnotation(annotation)
            }
            updateOverlay()
            addPolyLine()
        }
    }
}

