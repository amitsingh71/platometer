//
//  ViewController.swift
//  Platometer
//
//  Created by Deblina Das on 18/07/17.
//  Copyright © 2017 Hummingwave Technologies. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var startStopButton: UIButton!
    
    @IBOutlet weak var areaInSqM: UILabel!
    @IBOutlet weak var areaInSqFt: UILabel!
    @IBOutlet weak var accuracy: UILabel!
    
    fileprivate lazy var viewModel = ViewModel()
    fileprivate lazy var zoomInFirstOnceToken = false
    fileprivate var lastRenderedCoordinate: CLLocationCoordinate2D?
    fileprivate var closingLine: MKPolyline?
    
    private lazy var locationManager: CLLocationManager = {
        let aManager = CLLocationManager()
        aManager.delegate = self
        aManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        return aManager
    }()
    
    // Current polygon displayed in the overlay.
    var polygon: MKPolygon?
    private(set) var makePolygon = MakePolygonModel()

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    @IBAction func startStopButtonTapped(_ sender: UIButton) {
        viewModel.isSessionInProgress = !viewModel.isSessionInProgress
        startStopButton.setTitle(viewModel.startStopButtonTitle, for: .normal)
    }

}

// MARK: Location Manager Delegate
extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        updateAccuracy(from: locations.last!)
        zoomInFirstTime(to: locations.last!)
        let usefulLocations = updateLocations(locations)
        updatePolyline(from: usefulLocations)
    }
    
    private func updateAccuracy(from location: CLLocation) {
        print("Accuracy: \(location.horizontalAccuracy)")
        viewModel.setAccuracy(location.horizontalAccuracy)
        accuracy.text = viewModel.accuracyText
    }
    
    private func zoomInFirstTime(to location: CLLocation) {
        if zoomInFirstOnceToken { return }
        zoomInFirstOnceToken = true
        let region = MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpanMake(0.001, 0.001))
        mapView.setRegion(region, animated: true)
    }
    
    private func updateLocations(_ locations: [CLLocation]) -> [CLLocation]? {
        if !viewModel.isSessionInProgress { return nil }                        // Record points only if a session is on.
        let aLocations = locations.filter { $0.horizontalAccuracy <= 100 }      // Ignore points that are not accurate.
        let annotations = aLocations.map { MapPoint(coordinate: $0.coordinate) }
        mapView.addAnnotations(annotations)
        return aLocations
    }

    func updatePolyline(from locations: [CLLocation]?) {
        guard let locations = locations, locations.count > 0 else { return }
        
        var coordinatesForPolyline = [CLLocationCoordinate2D]()
        if let lastCoordinate = lastRenderedCoordinate { coordinatesForPolyline.append(lastCoordinate) }
        let newCoordinates = locations.map { $0.coordinate }
        coordinatesForPolyline.append(contentsOf: newCoordinates)
        let polyline = MKPolyline(coordinates: coordinatesForPolyline, count: coordinatesForPolyline.count)
        mapView.add(polyline)
        lastRenderedCoordinate = newCoordinates.last

        if let firstPoint = mapView.annotations.first?.coordinate {
            if let closingLine = self.closingLine { mapView.remove(closingLine) }
            closingLine = MKPolyline(coordinates: [locations.last!.coordinate, firstPoint], count: 2)
            mapView.add(closingLine!)
        }
    }

}

// MARK: Map View Delegate
extension ViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard overlay is MKPolyline else { return MKOverlayRenderer(overlay: overlay) }
        let polylineRenderer = MKPolylineRenderer(overlay: overlay)
        polylineRenderer.strokeColor = UIColor(red: 0, green: 178.0/255.0, blue: 1, alpha: 1)
        polylineRenderer.lineWidth = 4
        return polylineRenderer
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? MapPoint else { return nil }
        return mapView.dequeueReusableAnnotationView(withIdentifier: MapPoint.reuseIdentifier) ??
            AnnotationView(annotation: annotation)
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
        if newState == .ending || newState == .canceling {
            view.dragState = .none
//            updateOverlay()
//            updatePolyLine()
        } else if newState == .starting {
            view.dragState = .dragging
        }
    }
    
}
