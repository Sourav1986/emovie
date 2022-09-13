//
//  SplashViewModel.swift
//  E-Movie
//
//  Created by Sourav Basu Roy on 10/09/22.
//

import Foundation
import Combine

/**
 SplashViewModel: ViewModel handle business logic like configuration api calling and hold loading status.
*/
class SplashViewModel {
    
    // MARK: - Properties
    
    // Random status message
    private let statusMessages = [
        "I'm gonna make him an offer he can't refuse.",
        "It's alive! It's alive!",
        "I'm the king of the world!",
        "Hasta la vista baby.",
        "Life finds a way.",
        "Great power comes with great responsibility!"
    ]
    // Bool value to check if Configuration service is prevously called.
    private var isConfigurationInProgress = false
    //Delegate to pass service events.
    private weak var delegate: SplashDelegate?
    // Subscriber implementations can use this type to provide a “cancellation token”.
    private var anyCancellables = Set<AnyCancellable>()
    // MARK: - Init
    init(delegate: SplashDelegate) {
        // initialize the delegate
        self.delegate = delegate
    }
    /**
     Call TMDB image configuration api using Combine framework .

     - Parameter api_key: api key provided by the TMDB.
     - getPublisherResponse  baseURLString: pass base url string of TMDB base domain , endpoint:  passing `configuration`api url.
                
     */
    func getConfiguration() {
        guard !isConfigurationInProgress else { return } // check if Configuration service is already running
        
        isConfigurationInProgress = true
        
        let parameters = [
            "api_key" : Secrets.apiKey, // Set api key
        ]
        // Show random status messages on screen while loading
        delegate?.updateStatus(messages: statusMessages.randomElement() ?? "Loading...")
        // Call Configuration service
        ServiceManager(baseURLString: ServiceURL.baseUrl).getPublisherResponse(endpoint: ServiceURL.configuration, queryParameters: parameters)
            //This accepts a closure that receives any resulting values from the publisher.
            .sink { completion in
                //The block get error message and pass it through delegate.
                if case let .failure(error) = completion {
                    DispatchQueue.main.async { [weak self] in
                        self?.isConfigurationInProgress = false
                        self?.delegate?.onConfigError(with: error.errorMessageString)
                    }
                } //The block update status message in UI.
                else if case .finished = completion {
                    print("Data downloaded successfully")
                    DispatchQueue.main.async { [weak self] in
                        self?.delegate?.updateStatus(messages:  "Hold on your popcorn!")
                    }
                    
                    
                }
                //The block update status message in UI.
            } receiveValue: { (response: Configuration) in
                print(response)
                DispatchQueue.main.async { [weak self] in
                    
                    self?.isConfigurationInProgress = false
                  
                    self?.delegate?.onConfigCompleted(with: response)
                  
                }
            }
            .store(in: &anyCancellables)
    }
    
}
