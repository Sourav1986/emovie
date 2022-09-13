//
//  SplashViewController.swift
//  E-Movie
//
//  Created by Sourav Basu Roy on 10/09/22.
//

import UIKit
import SDWebImage

/**
 SplashViewController:  handle UI logic display loading status messages etc..
*/
class SplashViewController: UIViewController {

    
    @IBOutlet weak var splashIconBg: UIView!
    @IBOutlet weak var activity: UIActivityIndicatorView!
    @IBOutlet weak var statusMessage: UILabel!
    
    // View Model
    var viewModel: SplashViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel = SplashViewModel(delegate: self)
        // UI Configuration - Splash, Image Cache Configuration
        viewConfiguration()
        
        // Api service - Image Configuration 
        activity.startAnimating()
        viewModel.getConfiguration()
    }
    
   // MARK: - UIConfiguration
    /**
        Configure  main icon background`splashIconBg`variable and add shadow, curve corners and configure`SDImageCache`library.

         - Parameters: None
    */
    func viewConfiguration() {
        // Setting splash icon round
        splashIconBg.layer.cornerRadius = 60
        splashIconBg.layer.shadowColor = UIColor.black.cgColor
        splashIconBg.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        splashIconBg.layer.shadowOpacity = 0.05
        splashIconBg.layer.shadowRadius = 60.0
        splashIconBg.layer.shadowPath = UIBezierPath(roundedRect: splashIconBg.bounds, cornerRadius: 60).cgPath
        splashIconBg.layer.shouldRasterize = true
        splashIconBg.layer.rasterizationScale = UIScreen.main.scale
        splashIconBg.clipsToBounds = true
        
        // Setting disk cache
        SDImageCache.shared.config.maxDiskSize = 1000000 * 20 // 20 MB

        // Setting memory cache
        SDImageCache.shared.config.maxMemoryCost = 15 * 1024 * 1024 // 15 MB
        
    }

}

extension SplashViewController: SplashDelegate, Navigation {
    
    // MARK: - Api Service Delegates
    /**
        Delegates handle `Configuration` api response
            - `onConfigCompleted`: if success it will return `Configuration` JSON respnse decoded into `response` object.
            -  `onConfigError`: If error it will return error mssage in `reason` object.
            - `updateStatus` : update UI status.
    */
    func onConfigCompleted(with response: Configuration) {
        // Stop main activity.
        activity.stopAnimating()
        // Dashboard navigation block.
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        if let dashboardVC = mainStoryboard.instantiateViewController(withIdentifier: "DashboardViewController") as? DashboardViewController {
            if let imgUrl = response.images?.secureBaseURL, let posterSizes = response.images?.posterSizes  {
                dashboardVC.imgBaseUrl = imgUrl
                dashboardVC.posterSizes = posterSizes
            }
            navigate(from: self, to: dashboardVC)
        }
        
    }
    
    func onConfigError(with reason: String) {
        // Stop main activity.
        activity.stopAnimating()
        // Dashboard navigation block.
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        if let dashboardVC = mainStoryboard.instantiateViewController(withIdentifier: "DashboardViewController") as? DashboardViewController {
            navigate(from: self, to: dashboardVC)
        }
    }
    
    func updateStatus(messages: String) {
        statusMessage.text = messages
    }
}
