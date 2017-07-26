//
//  ViewModel.swift
//  Platometer
//
//  Created by Amit Singh on 26/07/17.
//  Copyright © 2017 Hummingwave Technologies. All rights reserved.
//

import UIKit
import CoreLocation

struct ViewModel {
    
    private var model = Model()
    
    var isSessionInProgress: Bool { get { return model.isSessionInProgress } set { model.isSessionInProgress = newValue } }
    
    var startStopButtonTitle: String { return model.isSessionInProgress ? "Stop" : "Start" }
    
    mutating func setAccuracy(_ accuracy: CLLocationDistance) { model.accuracy = accuracy }
    var accuracyText: String { return String(format: "%0.0fm", model.accuracy) }

}


struct Model {

    var accuracy: CLLocationDistance!
    var isSessionInProgress = false

}
