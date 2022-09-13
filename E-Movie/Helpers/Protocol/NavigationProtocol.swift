//
//  NavigationProtocol.swift
//  E-Movie
//
//  Created by Sourav Basu Roy on 10/09/22.
//

import Foundation
import UIKit

protocol Navigation {
    func navigate(from source: UIViewController, to destination: UIViewController)
}

extension Navigation {
    func navigate(from source: UIViewController, to destination: UIViewController) {
        source.navigationController?.pushViewController(destination, animated: true)
    }
}
