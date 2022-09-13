//
//  MovieDetailsTests.swift
//  E-MovieTests
//
//  Created by Sourav Basu Roy on 12/09/22.
//

import XCTest

class MovieDetailsTests: XCTestCase, MovieDetailsDelegate {

    var viewModel: MovieDetailsViewModel!
    var promise: XCTestExpectation!
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        viewModel = MovieDetailsViewModel(delegate: self)
        promise = expectation(description: "Status code: 200")
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        viewModel = nil
        promise = nil
    }

    func testMovieDetailsService() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
        viewModel.fetchMovieDetails(movieId: 438148)
        wait(for: [promise], timeout: 60)
    }

    func testMovieDetaisRating() throws {
        
    }
    
    func onFetchCompleted(with result: MovieDetails) {
        promise.fulfill()
    }
    
    func onFetchFailed(with reason: String) {
        XCTFail(reason)
    }

}
