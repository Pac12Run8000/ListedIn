//
//  Address.swift
//  ListedIn
//
//  Created by Michelle Grover on 1/20/19.
//  Copyright © 2019 Norbert Grover. All rights reserved.
//

import Foundation
import MapKit

struct Address {
    var name:String?
    var coordinate:CLLocationCoordinate2D?
    
    init() {
        name = nil
        coordinate = nil
    }
}
