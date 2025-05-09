//
//  ViewController.swift
//  RefactorTest
//
//  Created by Dave Duprey on 28/04/2025.
//

import UIKit
import MapKit
import W3WSwiftApi


class ViewController: UIViewController, MKMapViewDelegate {
    
    let api = What3WordsV4(apiKey: "CTF89056")
    lazy var label = UILabel(frame: CGRect(x: 64.0, y: 64.0, width: view.frame.width - 128.0, height: 32.0))
    lazy var label2 = UILabel(frame: CGRect(x: 64.0, y: 64.0, width: view.frame.width - 128.0, height: 32.0))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let map = MKMapView()
        map.delegate = self
        self.view = map
        label.text = "Select a square"
        label.textAlignment = .center
        label.layer.cornerRadius = 8.0
        label.font = .boldSystemFont(ofSize: 24.0)
        label.backgroundColor = .white
        label.textColor = .red
        label.frame = CGRect(x: 64.0, y: 64.0, width: 300.0, height: 32.0)
        view.addSubview(label)
        label2.textAlignment = .center
        label2.layer.cornerRadius = 8.0
        label2.font = .boldSystemFont(ofSize: 24.0)
        label2.backgroundColor = .white
        label2.textColor = .blue
        label2.frame = CGRect(x: 64.0, y: 100.0, width: 300.0, height: 32.0)
        view.addSubview(label2)
    }

    func showCoordinate(coordinate: CLLocationCoordinate2D) {
        api.convertTo3wa(coordinates: coordinate, language: W3WBaseLanguage(code: "en")) { square, error in
            let annotation = ColorPointAnnotation()
            annotation.coordinate = coordinate
            annotation.color = .red
            annotation.title = square?.words ?? "\(coordinate.latitude), \(coordinate.longitude)"
            DispatchQueue.main.async {
                (self.view as? MKMapView)?.addAnnotation(annotation)
                self.label.text = square?.words ?? "\(coordinate.latitude), \(coordinate.longitude)"
            }
        }
        
        let antipole = antipole(coordinate: coordinate)
        api.convertTo3wa(coordinates: antipole, language: W3WBaseLanguage(code: "en")) { square, error in
            if let coordinate = square?.coordinates {
                let annotation2 = ColorPointAnnotation()
                annotation2.coordinate = coordinate
                annotation2.color = .blue
                annotation2.title = square?.words ?? "\(coordinate.latitude), \(coordinate.longitude)"
                DispatchQueue.main.async {
                    (self.view as? MKMapView)?.addAnnotation(annotation2)
                    self.label2.text = square?.words ?? "\(coordinate.latitude), \(coordinate.longitude)"
                }
            }
        }
        
        (view as? MKMapView)?.setCenter(antipole, animated: true)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            if let map = view as? MKMapView {
                let coord = map.convert(touch.location(in: touch.view), toCoordinateFrom: map)
                showCoordinate(coordinate: coord)
            }
        }
    }
    
    func antipole(coordinate: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        var longitude = coordinate.longitude + 180.0
        if longitude > 180.0 {
            longitude = longitude - 360.0
        }
        return CLLocationCoordinate2D(latitude: -coordinate.latitude, longitude: longitude)
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let colorPointAnnotation = annotation as? ColorPointAnnotation else {
            let defaultPin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "defaultPin")
            defaultPin.pinTintColor = .gray // Or any default color you prefer
            return defaultPin
        }
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: "ColoredPin") as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: colorPointAnnotation, reuseIdentifier: "ColoredPin")
        } else {
            pinView?.annotation = colorPointAnnotation
        }
        
        pinView?.pinTintColor = colorPointAnnotation.color ?? .black

        return pinView
    }
}

class ColorPointAnnotation: MKPointAnnotation {
    var color: UIColor?
}
