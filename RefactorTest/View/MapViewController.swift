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

final class MapViewController: UIViewController, MKMapViewDelegate {

    private var mainLabel: UILabel!
    private var antipodeLabel: UILabel!
    private var mapView: MKMapView!
    private var viewModel: MapViewModel!
    private var cancellables: Set<AnyCancellable> = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView()
        setupLabels()
        setupViewModel()
    }

    deinit {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
    }

    private func setupMapView() {
        mapView = MKMapView()
        mapView.delegate = self
        self.view = mapView
    }

    private func setupLabels() {
        mainLabel = UILabel.mapLabel(topOffset: 64, textColor: .red)
        antipodeLabel = UILabel.mapLabel(topOffset: 100, textColor: .blue)
        view.addSubview(mainLabel)
        view.addSubview(antipodeLabel)
    }

    private func setupViewModel() {
        viewModel = MapViewModel(service: What3WordsV4Service(apiKey: "CTF89056"))
        viewModel.$mainText
            .receive(on: DispatchQueue.main)
            .assign(to: \.text, on: mainLabel)
            .store(in: &cancellables)

        viewModel.$antipodeText
            .receive(on: DispatchQueue.main)
            .assign(to: \.text, on: antipodeLabel)
            .store(in: &cancellables)

        viewModel.$tappedAnnotation
            .receive(on: DispatchQueue.main)
            .sink { [weak self] annotation in
                guard let self, let annotation else { return }
                self.mapView.addAnnotation(annotation)
            }
            .store(in: &cancellables)

        viewModel.$antipoleAnnotation
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
