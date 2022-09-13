//
//  SplashProtocol.swift
//  E-Movie
//
//  Created by Sourav Basu Roy on 10/09/22.
//

import Foundation
/**
    SplashDelegate: Delegate handle configuration service events. View model passing reponse to the controller to map the UI.
*/
protocol SplashDelegate: AnyObject {
    //Get image configuration from TMDB
    func onConfigCompleted(with response: Configuration)
    //Get Api error message
    func onConfigError(with reason: String)
    //Set random status messages
    func updateStatus(messages: String)
}
