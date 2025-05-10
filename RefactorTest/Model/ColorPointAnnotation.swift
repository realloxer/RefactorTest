//
//  ColorPointAnnotation.swift
//  RefactorTest
//
//  Created by LocNguyen on 9/5/25.
//

import MapKit

final class ColorPointAnnotation: MKPointAnnotation {
    var color: UIColor?
    
    init(coordinate: CLLocationCoordinate2D, title: String?, color: UIColor? = nil) {
        super.init()
        self.coordinate = coordinate
        self.title = title
        self.color = color
    }
}
