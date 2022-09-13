//
//  DashboardViewModel.swift
//  E-Movie
//
//  Created by Sourav Basu Roy on 09/09/22.
//

import Foundation
import Combine

/**
    DashboardViewModel: DashboardViewModel calculate all the business logic like calling api , maintain array count, hold filter option etc.
    Properties:
        movies - collection of movies information
        currentPage  - hold recient page number. Each service call page count will increase.
        total - hold current items count in a page.
        isFetchInProgress - check if any service is already running or not.
        delegate - delegate variable.
        anyCancellables - subscriber implementations can use this type to provide a “cancellation token”.
        filter -  filtering option popular or rating.
        totalCount - return total pages.
        currentCount - return current movie array count.
    Subscript: return each movie item based on indexPath
    Methods:
        reset() - reset currentPage to 1 and clear movies array.
        reserveSize() -
        fetchMovies(with filterOption: FilterOptions) - get Popular/highest rating movies response.
        calculateIndexPathsToReload - calculate which index path to reload next.
*/

final class DashboardViewModel {
    
    private var movies: [Movie] = []
    private var currentPage = 1
    private var total = 0
    private var isFetchInProgress = false
    private weak var delegate: DashboardViewModelDelegate?
    private var anyCancellables = Set<AnyCancellable>()
    var filter: FilterOptions = .popular
    
    var totalCount: Int {
        return total
    }
    
    var currentCount: Int {
        return movies.count
    }
    
    init(delegate: DashboardViewModelDelegate) {
        self.delegate = delegate
    }

    subscript(index: Int) -> Movie? {
        return movies[safe: index]
    }
    
    func reset() {
        movies.removeAll()
        currentPage = 1
    }
    
    func fetchMovies(with filterOption: FilterOptions) {
        
        guard !isFetchInProgress else { return }
        
        isFetchInProgress = true
        
        let parameters = [
            "api_key" : Secrets.apiKey,
            "language" : "en-US",
            "page" : "\(currentPage)"
        ]
        let endpoint = filterOption == .popular ? ServiceURL.popular : ServiceURL.topRated
        filter = filterOption
        ServiceManager(baseURLString: ServiceURL.baseUrl).getPublisherResponse(endpoint: endpoint, queryParameters: parameters)
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
            } receiveValue: { (response: Response) in
                print(response)
                DispatchQueue.main.async { [weak self] in
                    
                    if self?.currentPage == 1, let totalItems = response.totalResults {
                        self?.movies.reserveCapacity(totalItems)
                    }
                    
                    self?.currentPage += 1
                    self?.isFetchInProgress = false
                    
                    self?.total = response.totalPages ?? 0
                    
                    self?.movies.append(contentsOf: response.results ?? [])
                    
                    if let page = response.page, page > 1 {
                        let indexPathsToReload = self?.calculateIndexPathsToReload(from: response.results ?? [])
                        self?.delegate?.onFetchCompleted(with: indexPathsToReload)
                    }
                    else {
                        self?.delegate?.onFetchCompleted(with: .none)
                    }
                }
            }
            .store(in: &anyCancellables)
    }
    
    private func calculateIndexPathsToReload(from newMovies: [Movie]) -> [IndexPath] {
      let startIndex = movies.count - newMovies.count
      let endIndex = startIndex + newMovies.count
      return (startIndex..<endIndex).map { IndexPath(item: $0, section: 0) }
    }
}

enum FilterOptions {
    case popular
    case rating
}
