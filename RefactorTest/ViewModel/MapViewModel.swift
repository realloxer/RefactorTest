//
//  MapViewModel.swift
//  RefactorTest
//
//  Created by LocNguyen on 9/5/25.
//

import Foundation
import CoreLocation
import MapKit

class MapViewModel: NSObject {
    @Published var mainText: String? = "Select a square"
    @Published var antipodeText: String? = ""
    @Published var tappedAnnotation: ColorPointAnnotation?
    @Published var antipoleAnnotation: ColorPointAnnotation?

    private let service: What3WordsService

    init(service: What3WordsService) {
        self.service = service
    }

    func selectCoordinate(_ coordinate: CLLocationCoordinate2D) {
        service.convertTo3wa(coordinate: coordinate) { [weak self] square, _ in
            let annotation = ColorPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = square?.words ?? "\(coordinate.latitude), \(coordinate.longitude)"
            annotation.color = .red

            DispatchQueue.main.async {
                self?.mainText = annotation.title ?? ""
                self?.tappedAnnotation = annotation
            }
        }

        let antipode = antipode(for: coordinate)

        service.convertTo3wa(coordinate: antipode) { [weak self] square, _ in
            guard let coordinate = square?.coordinates else { return }

            let annotation = ColorPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = square?.words ?? "\(coordinate.latitude), \(coordinate.longitude)"
            annotation.color = .blue

            DispatchQueue.main.async {
                self?.antipodeText = annotation.title ?? ""
                self?.antipoleAnnotation = annotation
            }
        }
    }

    func antipode(for coordinate: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        var longitude = coordinate.longitude + 180.0
        if longitude > 180.0 {
            longitude -= 360.0
        }
        return CLLocationCoordinate2D(latitude: -coordinate.latitude, longitude: longitude)
    }
}
