//
//  MovieDetailsViewModel.swift
//  E-Movie
//
//  Created by Sourav Basu Roy on 11/09/22.
//

import Foundation
import Combine
import UIKit
/**
    MovieDetailsViewModel: DashboardViewModel calculate all the business logic like calling api , maintain array count, hold filter option etc.
    Properties:
        isFetchInProgress - check if any service is already running or not.
        delegate - delegate variable.
        anyCancellables - subscriber implementations can use this type to provide a “cancellation token”.
    Methods:
        reset() - reset currentPage to 1 and clear movies array.
        reserveSize() -
        fetchMovieDetails(movieId: Int)- get movie information from response .
        convertMovieAttributes - style movie attributes.
        calculateRating(userRating: Double) -> (rating: Float, color: UIColor) - return rating and color based on user rating.
*/
final class MovieDetailsViewModel {
    
    private var isFetchInProgress = false
    
    private weak var delegate: MovieDetailsDelegate?
    private var anyCancellables = Set<AnyCancellable>()
    
    init(delegate: MovieDetailsDelegate) {
        self.delegate = delegate
    }
    
    func fetchMovieDetails(movieId: Int) {
        
        guard !isFetchInProgress else { return }
        
        isFetchInProgress = true
        
        let parameters = [
            "api_key" : Secrets.apiKey,
        ]
        
        ServiceManager(baseURLString: ServiceURL.baseUrl).getPublisherResponse(endpoint: "\(ServiceURL.movieDetails)/\(movieId)", queryParameters: parameters)
            .sink { completion in
                if case let .failure(error) = completion {
                    DispatchQueue.main.async { [weak self] in
                        self?.isFetchInProgress = false
                        self?.delegate?.onFetchFailed(with: error.errorMessageString)
                    }
                }
                else if case .finished = completion {
                    print("Data downloaded successfully")
                }
            } receiveValue: { (response: MovieDetails) in
                print(response)
                DispatchQueue.main.async { [weak self] in
                    self?.isFetchInProgress = false
                    self?.delegate?.onFetchCompleted(with: response)
                }
            }
            .store(in: &anyCancellables)
    }
    
    func convertMovieAttributes(movie: MovieDetails) -> String {
        var attributes: [String] = []
        var details = ""
        
        if let releaseDate = movie.releaseDate {
            attributes.append(releaseDate)
        }
        
        if let originalLanguage = movie.originalLanguage {
            attributes.append(originalLanguage)
        }
        
        if let genres = movie.genres {
            let filteredGenres = genres.compactMap({ $0.name })
            attributes.append(contentsOf: filteredGenres)
        }
        
        for attribute in attributes {
            details += attribute + " | "
        }
        return details
    }
    
    func calculateRating(userRating: Double) -> (rating: Float, color: UIColor) {
        let rating = Float(userRating) / 10
        var color: UIColor = .green
        if userRating < 7 && userRating > 3 {
            color = UIColor(red: 255/255.0, green: 192/255.0, blue: 0/255.0, alpha: 1.0)
        }
        else if userRating < 4 {
            color = .red
        }
        
        return (rating, color)
    }
}
