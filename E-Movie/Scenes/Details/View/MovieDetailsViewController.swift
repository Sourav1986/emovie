//
//  MovieDetailsViewController.swift
//  E-Movie
//
//  Created by Sourav Basu Roy on 11/09/22.
//

import UIKit
import SDWebImage

/**
    DashboardViewController:  Contain UIcollectionView and Header. CollectionView load movie based on user scroll.
    Properties:
        IBOutlet: mainActivity - activity indicator. Link to storyboard.
        IBOutlet: bannerImage - image poster background view.
        IBOutlet: posterImage - image poster background view.
        IBOutlet: posterImageView - image poster view. show movie poster.
        IBOutlet: movieTitle - display movie title.
        IBOutlet: ratingView - display circualr progress view.
        IBOutlet: ratingLabel - display user rating.
        IBOutlet: movieDetails - display movie attributes.
        IBOutlet: overviewTitle - overview header.
        IBOutlet: overviewDescription - display movie overview.
        viewModel - viewModel object to call service methods and computing functions.
    Methods:
        viewConfiguration() - map movie details to UI..
*/

class MovieDetailsViewController: UIViewController {
    // MARK: - Properties
    @IBOutlet weak var bannerImage: UIImageView!
    @IBOutlet weak var posterImage: UIImageView!
    @IBOutlet weak var posterImageView: UIView!
    @IBOutlet weak var movieTitle: UILabel!
    @IBOutlet weak var ratingView: UIView!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var movieDetails: UILabel!
    @IBOutlet weak var overviewTitle: UILabel!
    @IBOutlet weak var overviewDescription: UILabel!
    @IBOutlet weak var mainActivity: UIActivityIndicatorView!
    
    var movieId: Int = 0
    var imgBaseUrl = ""
    var posterSizes: [String] = []
    var viewModel: MovieDetailsViewModel!
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.viewModel = MovieDetailsViewModel(delegate: self)
        
        mainActivity.startAnimating()
        viewModel.fetchMovieDetails(movieId: movieId)
        
        // Do any additional setup after loading the view.
    }
    // MARK: - Navigation
    @IBAction func clickBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UI Configuration
extension MovieDetailsViewController {
    func viewConfiguration(result: MovieDetails) {
        movieTitle.text = result.title
        ratingLabel.text = String(format: "%.1f", result.voteAverage ?? 0.0)
        overviewTitle.text = "Overview"
        overviewDescription.text = result.overview
        movieDetails.text = viewModel.convertMovieAttributes(movie: result)
        let imageUrl = "\(imgBaseUrl)\(posterSizes.first(where: { $0 == "w185"}) ?? "")\(result.posterPath ?? "")?api_key=\(Secrets.apiKey)"
        bannerImage.sd_setImage(with: URL(string: imageUrl), placeholderImage: nil)
        posterImage.sd_setImage(with: URL(string: imageUrl), placeholderImage: UIImage(named: "default"))
        
        posterImageView.layer.cornerRadius = 10
        posterImageView.layer.shadowColor = UIColor.black.cgColor
        posterImageView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        posterImageView.layer.shadowOpacity = 0.05
        posterImageView.layer.shadowRadius = 10.0
        
        posterImageView.layer.shadowPath = UIBezierPath(roundedRect: posterImageView.bounds, cornerRadius: 10).cgPath
        posterImageView.layer.shouldRasterize = true
        posterImageView.layer.rasterizationScale = UIScreen.main.scale
        posterImageView.clipsToBounds = true
        
        let progressView = CircularProgressView(frame: CGRect(x: 0, y: 0, width: ratingView.frame.width, height: ratingView.frame.height), lineWidth: 5, rounded: false)
        
        progressView.trackColor = .lightGray
        ratingView.addSubview(progressView)
        let result = viewModel.calculateRating(userRating: result.voteAverage ?? 0.0)
        progressView.progress = result.rating
        progressView.progressColor = result.color
        ratingView.bringSubviewToFront(ratingLabel)
        
       let constraints = [
            //progressView.centerXAnchor.constraint(equalTo: ratingView.centerXAnchor),
            progressView.topAnchor.constraint(equalTo: ratingView.topAnchor),
            progressView.bottomAnchor.constraint(equalTo: ratingView.bottomAnchor),
            progressView.leadingAnchor.constraint(equalTo: ratingView.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: ratingView.trailingAnchor),
        ]
        NSLayoutConstraint.activate(constraints)
    }
}
// MARK: - Delegate
extension MovieDetailsViewController: MovieDetailsDelegate, AlertDisplayer {
    func onFetchCompleted(with result: MovieDetails) {
        mainActivity.stopAnimating()
        viewConfiguration(result: result)
    }
    
    func onFetchFailed(with reason: String) {
        mainActivity.stopAnimating()
        print(reason)
        let title = "Warning"
        let action = UIAlertAction(title: "OK", style: .default)
        displayAlert(with: title , message: reason, actions: [action])
    }
}

