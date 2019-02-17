//
//  Pin+Extensions.swift
//  Virtual Tourist
//
//  Created by makramia on 22/01/2019.
//  Copyright © 2019 makramia. All rights reserved.
//

import Foundation
import CoreData
import MapKit

extension Pin: MKAnnotation{
    public var coordinate: CLLocationCoordinate2D {
        
        let latDeg = CLLocationDegrees(latitude)
        let longDeg = CLLocationDegrees(longitude)
        return CLLocationCoordinate2D(latitude: latDeg, longitude: longDeg)
    }
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        creationDate = Date()
    }
   
    
    
}
