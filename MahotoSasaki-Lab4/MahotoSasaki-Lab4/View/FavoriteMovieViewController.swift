//
//  FavoriteMovieViewController.swift
//  MahotoSasaki-Lab4
//
//  Created by Mahoto Sasaki on 10/27/20.
//  Copyright © 2020 mo3aru. All rights reserved.
//

import UIKit

class FavoriteMovieViewController: UIViewController {
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var movieTitleNavigationItem: UINavigationItem!

    var movieID = 0
    var movieTitle:String = "default"
    var releaseDate:String = "default"
    var score:Int = 0
    var overview:String = "default"
    var movieImage:UIImage = UIImage()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        movieTitleNavigationItem.title = movieTitle
        image.image = movieImage
        releaseDateLabel.text = "Released: " + releaseDate
        scoreLabel.text = "Score: \(score)/100"
        overviewLabel.text = "Description: \(overview)"
    }
}

