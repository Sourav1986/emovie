//
//  SpashLoadingTests.swift
//  E-MovieTests
//
//  Created by Sourav Basu Roy on 12/09/22.
//

import XCTest
import E_Movie

class SpashLoadingTests: XCTestCase, SplashDelegate {
    
    var viewModel: SplashViewModel!
    var promise: XCTestExpectation!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        viewModel = SplashViewModel(delegate: self)
        promise = expectation(description: "Status code: 200")
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        viewModel = nil
        promise = nil
    }

    func testWebserviceResponse() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
        
        
        viewModel.getConfiguration()
        wait(for: [promise], timeout: 60)
    }
    
    func onConfigCompleted(with response: Configuration) {
        promise.fulfill()
    }
    
    func onConfigError(with reason: String) {
        XCTFail(reason)
    }
    
    func updateStatus(messages: String) { }

}
