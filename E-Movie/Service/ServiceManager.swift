//
//  ServiceManager.swift
//  E-Movie
//
//  Created by Sourav Basu Roy on 08/09/22.
//

import Foundation
import Combine

/**
    ServiceManager:  Manage all service calls. Reactive programming using Combine framework .Generic decoding type has been used for reusablity.
        
*/
final class ServiceManager {
    
    let urlSession: URLSession
    let baseURLString: String
    
    init(urlSession: URLSession = .shared, baseURLString: String) {
        self.urlSession = urlSession
        self.baseURLString = baseURLString
    }
    
    func getPublisherResponse<T: Decodable>(endpoint: String, queryParameters: [String : String]) -> AnyPublisher<T, NetworkServiceError> {
        let queryItems = queryParameters.map { URLQueryItem(name: $0, value: $1) }
        
        let urlComponents = NSURLComponents(string: baseURLString + endpoint)
        urlComponents?.queryItems = queryItems
        
        guard let url = urlComponents?.url else {
            return Fail(error: NetworkServiceError.invalidURL).eraseToAnyPublisher()
        }
        
        return urlSession.dataTaskPublisher(for: url)
            .tryMap { (data, response) -> Data in
                if let httpResponse = response as? HTTPURLResponse {
                    guard (200..<300) ~= httpResponse.statusCode else {
                        throw NetworkServiceError.invalidResponseCode(httpResponse.statusCode)
                    }
                }
                return data
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError { error -> NetworkServiceError in
                if let decodingError = error as? DecodingError {
                    return NetworkServiceError.decodingError((decodingError as NSError).debugDescription)
                }
                return NetworkServiceError.genericError(error.localizedDescription)
            }
            .eraseToAnyPublisher()
    }
    
}
