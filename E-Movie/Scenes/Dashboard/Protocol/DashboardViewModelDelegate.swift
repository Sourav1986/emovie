//
//  DashboardViewModelDelegate.swift
//  E-Movie
//
//  Created by Sourav Basu Roy on 09/09/22.
//

import Foundation
/**
    DashboardViewModelDelegate:  Delegate handle Popular or  service events. View model passing reponse to the controller map the UI.
*/
protocol DashboardViewModelDelegate: AnyObject {
  func onFetchCompleted(with newIndexPathsToReload: [IndexPath]?)
  func onFetchFailed(with reason: String)
}
