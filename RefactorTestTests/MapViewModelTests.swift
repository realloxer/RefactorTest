//
//  MapViewModel.swift
//  RefactorTest
//
//  Created by LocNguyen on 10/5/25.
//

import XCTest
import CoreLocation
import W3WSwiftApi
@testable import RefactorTest

final class MockWhat3WordsService: What3WordsService {
    var shouldReturnError = false
    var mockW3WSquare: MockW3WSquare?

    func convertTo3wa(coordinate: CLLocationCoordinate2D, completion: @escaping (W3WSquare?, Error?) -> Void) {
        if shouldReturnError {
            completion(nil, NSError(domain: "MockError", code: -1, userInfo: nil))
        } else {
            completion(mockW3WSquare, nil)
        }
    }
}

final class MockW3WSquare: W3WSquare {
    init(words: String?, coordinates: CLLocationCoordinate2D?) {
        self.words = words
        self.coordinates = coordinates
    }
    
    var words: String?
    
    var country: (any W3WSwiftCore.W3WCountry)?
    
    var nearestPlace: String?
    
    var distanceToFocus: (any W3WSwiftCore.W3WDistance)?
    
    var language: (any W3WSwiftCore.W3WLanguage)?
    
    var coordinates: CLLocationCoordinate2D?
    
    var bounds: W3WSwiftCore.W3WBaseBox?
}

final class MapViewModelTests: XCTestCase {
    var mockService: MockWhat3WordsService!
    var viewModel: MapViewModel!

    override func setUp() {
        super.setUp()
        mockService = MockWhat3WordsService()
        viewModel = MapViewModel(service: mockService)
    }
    
    override func tearDown() {
        viewModel = nil
        mockService = nil
    }

    func testSelectCoordinate_Success() {
        // Given
        let coordinate = CLLocationCoordinate2D(latitude: 10, longitude: 20)
        mockService.mockW3WSquare = MockW3WSquare(words: "dummyWords", coordinates: coordinate)

        let expectation1 = expectation(description: "Main annotation set expectation")
        let expectation2 = expectation(description: "Antipode annotation set expectation")

        let cancellable1 = viewModel.$mainText.dropFirst().sink { text in
            expectation1.fulfill()
        }

        let cancellable2 = viewModel.$antipodeText.dropFirst().sink { text in
            expectation2.fulfill()
        }

        // When
        viewModel.selectCoordinate(coordinate)

        // Then
        wait(for: [expectation1, expectation2], timeout: 1.0)
        XCTAssertEqual(viewModel.mainText, "dummyWords")
        XCTAssertEqual(viewModel.antipodeText, "dummyWords")
        XCTAssertEqual(viewModel.tappedAnnotation?.coordinate.latitude, coordinate.latitude)
        XCTAssertEqual(viewModel.tappedAnnotation?.coordinate.longitude, coordinate.longitude)
        XCTAssertEqual(viewModel.antipoleAnnotation?.coordinate.latitude, coordinate.latitude)
        XCTAssertEqual(viewModel.antipoleAnnotation?.coordinate.longitude, coordinate.longitude)
        cancellable1.cancel()
        cancellable2.cancel()
    }
    
    func testSelectCoordinate_Success_NilWords() {
        // Given
        let coordinate = CLLocationCoordinate2D(latitude: 10, longitude: 20)
        mockService.mockW3WSquare = MockW3WSquare(words: nil, coordinates: coordinate)

        let expectation1 = expectation(description: "Main annotation set expectation")
        let expectation2 = expectation(description: "Antipode annotation set expectation")

        let cancellable1 = viewModel.$mainText.dropFirst().sink { text in
            expectation1.fulfill()
        }

        let cancellable2 = viewModel.$antipodeText.dropFirst().sink { text in
            expectation2.fulfill()
        }

        // When
        viewModel.selectCoordinate(coordinate)

        // Then
        wait(for: [expectation1, expectation2], timeout: 1.0)
        XCTAssertEqual(viewModel.mainText, "10.0, 20.0")
        XCTAssertEqual(viewModel.antipodeText, "10.0, 20.0")
        XCTAssertEqual(viewModel.tappedAnnotation?.coordinate.latitude, coordinate.latitude)
        XCTAssertEqual(viewModel.tappedAnnotation?.coordinate.longitude, coordinate.longitude)
        XCTAssertEqual(viewModel.antipoleAnnotation?.coordinate.latitude, coordinate.latitude)
        XCTAssertEqual(viewModel.antipoleAnnotation?.coordinate.longitude, coordinate.longitude)
        cancellable1.cancel()
        cancellable2.cancel()
    }

    func testSelectCoordinate_Error() {
        // Given
        mockService.shouldReturnError = true
        let coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)

        let expectation = expectation(description: "No annotation set expectation")
        expectation.isInverted = true

        let cancellable = viewModel.$mainText.dropFirst().sink { _ in
            expectation.fulfill()
        }

        // When
        viewModel.selectCoordinate(coordinate)

        // Then
        wait(for: [expectation], timeout: 1.0)
        cancellable.cancel()
    }

    func testAntipodeCalculation() {
        // Given
        let coordinate = CLLocationCoordinate2D(latitude: 10, longitude: 200)

        // When
        let antipode = viewModel.antipode(for: coordinate)

        // Then
        XCTAssertEqual(antipode.latitude, -10)
        XCTAssertEqual(antipode.longitude, 20)
    }
}
