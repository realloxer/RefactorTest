//
//  What3WordsService.swift
//  RefactorTest
//
//  Created by LocNguyen on 9/5/25.
//

import CoreLocation
import W3WSwiftApi

protocol What3WordsService {
    func convertTo3wa(coordinate: CLLocationCoordinate2D, completion: @escaping (W3WSquare?, Error?) -> Void)
}

final class What3WordsV4Service: What3WordsService {
    private let api: What3WordsV4

    init(apiKey: String) {
        self.api = What3WordsV4(apiKey: apiKey)
    }

    func convertTo3wa(coordinate: CLLocationCoordinate2D, completion: @escaping (W3WSquare?, Error?) -> Void) {
        api.convertTo3wa(coordinates: coordinate, language: W3WBaseLanguage(code: "en"), completion: completion)
    }
}
