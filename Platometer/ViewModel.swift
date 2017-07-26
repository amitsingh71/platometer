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
    
    var accuracy: CLLocationDistance { get { return model.accuracy } set { model.accuracy = newValue } }
    var accuracyText: String { return String(format: "%0.0fm", accuracy) }

}


struct Model {

    var accuracy: CLLocationDistance!

}
