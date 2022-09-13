//
//  MovieDetailsDelegate.swift
//  E-Movie
//
//  Created by Sourav Basu Roy on 11/09/22.
//

import Foundation
/**
 MovieDetailsDelegate: Delegate handle movie details service events. View model passing reponse to the controller to map the UI.
*/
protocol MovieDetailsDelegate: AnyObject {
    func onFetchCompleted(with result: MovieDetails)
    func onFetchFailed(with reason: String)
}
