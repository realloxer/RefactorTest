//
//  MapViewController.swift
//  RefactorTest
//
//  Created by Dave Duprey on 28/04/2025.
//

import UIKit
import MapKit
import W3WSwiftApi
import Combine

class MapViewController: UIViewController, MKMapViewDelegate {

    lazy var label = UILabel(frame: CGRect(x: 64.0, y: 64.0, width: view.frame.width - 128.0, height: 32.0))
    lazy var label2 = UILabel(frame: CGRect(x: 64.0, y: 64.0, width: view.frame.width - 128.0, height: 32.0))
    private var mapView = MKMapView()
    private var viewModel: MapViewModel!
    private var cancellables: Set<AnyCancellable> = []

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        self.view = mapView
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

        let service = What3WordsService(apiKey: "CTF89056")
        viewModel = MapViewModel(service: service)
        bindData()
    }

    private func bindData() {
        viewModel?.$mainText
            .receive(on: DispatchQueue.main)
            .assign(to: \.text, on: label)
            .store(in: &cancellables)

        viewModel?.$antipodeText
            .receive(on: DispatchQueue.main)
            .assign(to: \.text, on: label2)
            .store(in: &cancellables)

        viewModel?.$tappedAnnotation
            .receive(on: DispatchQueue.main)
            .sink { [weak self] annotation in
                guard let self, let annotation else { return }
                self.mapView.addAnnotation(annotation)
            }
            .store(in: &cancellables)

        viewModel?.$antipoleAnnotation
            .receive(on: DispatchQueue.main)
            .sink { [weak self] annotation in
                guard let self, let annotation else { return }
                self.mapView.addAnnotation(annotation)
                self.mapView.setCenter(annotation.coordinate, animated: true)
            }
            .store(in: &cancellables)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: mapView)
        let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
        viewModel.selectCoordinate(coordinate)
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
