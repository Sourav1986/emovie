//
//  MovieCell.swift
//  E-Movie
//
//  Created by Sourav Basu Roy on 09/09/22.
//

import UIKit
import SDWebImage

class MovieCell: UICollectionViewCell {

    @IBOutlet weak var movieBanner: UIImageView!
    @IBOutlet weak var movieTitle: UILabel!
    @IBOutlet weak var releaseDate: UILabel!
    @IBOutlet weak var activity: UIActivityIndicatorView!
    @IBOutlet weak var baseView: UIView!
    
    var baseUrl = ""
    var posterSize: String = ""
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        cellConfiguration(with: .none)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
        viewConfiguration()
    }
    
    func cellConfiguration(with movie: Movie?) {
        if let movie = movie {
            movieTitle.text = movie.title
            releaseDate.text = movie.releaseDate
            movieTitle.alpha = 1
            releaseDate.alpha = 1
            movieBanner.alpha = 1
            let imageUrl = "\(baseUrl)\(posterSize)\(movie.posterPath ?? "")?api_key=\(Secrets.apiKey)"
            movieBanner.sd_setImage(with: URL(string: imageUrl), placeholderImage:UIImage(named:"default") )
            activity.stopAnimating()
        }
        else {
            movieTitle.alpha = 0
            releaseDate.alpha = 0
            movieBanner.alpha = 0
            activity.startAnimating()
        }
    }
    
    private func viewConfiguration()  {
        baseView.layer.cornerRadius = 10
        baseView.layer.shadowColor = UIColor.black.cgColor
        baseView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        baseView.layer.shadowOpacity = 0.05
        baseView.layer.shadowRadius = 10.0
        
        baseView.layer.shadowPath = UIBezierPath(roundedRect: baseView.bounds, cornerRadius: 10).cgPath
        baseView.layer.shouldRasterize = true
        baseView.layer.rasterizationScale = UIScreen.main.scale
        baseView.clipsToBounds = true
        
        activity.hidesWhenStopped = true
    }
}
