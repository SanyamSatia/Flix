//
//  DetailViewController.swift
//  flix
//
//  Created by Sanyam Satia on 2/3/17.
//  Copyright © 2017 Sanyam Satia. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var infoView: UIView!
    
    var movie: NSDictionary!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: infoView.frame.origin.y + infoView.frame.size.height)
        
        titleLabel.text = movie.value(forKey: "title") as? String
        navigationItem.title = movie.value(forKey: "title") as? String
        descriptionLabel.text = movie.value(forKey: "overview") as? String
        descriptionLabel.sizeToFit()
        
        let baseLowResPosterUrl = "https://image.tmdb.org/t/p/w45/"
        let baseHighResPosterUrl = "https://image.tmdb.org/t/p/original/"
        
        if let moviePosterUrl = movie.value(forKey: "poster_path") as? String {
            let lowResImageRequest = URLRequest(url: URL(string: baseLowResPosterUrl + moviePosterUrl)!)
            let highResImageRequest = URLRequest(url: URL(string: baseHighResPosterUrl + moviePosterUrl)!)
            
            posterImageView.setImageWith(
                lowResImageRequest,
                placeholderImage: nil,
                success: { (lowResImageRequest, lowResImageResponse, lowResImage) -> Void in
                    self.posterImageView.alpha = 0.0
                    self.posterImageView.image = lowResImage
                    
                    UIView.animate(
                        withDuration: 0.3,
                        animations: { () -> Void in
                            self.posterImageView.alpha = 1.0
                        },
                        completion: { (success) -> Void in
                            self.posterImageView.setImageWith(
                                highResImageRequest,
                                placeholderImage: lowResImage,
                                success: { (highResImageRequest, highResImageResponse, highResImage) -> Void in
                                    self.posterImageView.image = highResImage
                                })
                        }
                    )
                }
            )
        }

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
