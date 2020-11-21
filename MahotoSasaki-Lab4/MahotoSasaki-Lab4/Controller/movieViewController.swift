//
//  movieViewController.swift
//  MahotoSasaki-Lab4
//
//  Created by Mahoto Sasaki on 10/22/20.
//  Copyright © 2020 mo3aru. All rights reserved.
//

import UIKit

class movieViewController: UIViewController {
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var addToFavoritesButton: UIButton!
    @IBOutlet weak var movieTitleNavigationItem: UINavigationItem!
    
    var movieID = 0
    var movieTitle:String = "default"
    var releaseDate:String = "default"
    var score:Int = 0
    var overview:String = "default"
    var movieImage:UIImage = UIImage()
    
    var favorites:[FavoriteMovie] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        movieTitleNavigationItem.title = movieTitle
        image.image = movieImage
        releaseDateLabel.text = "Released: " + releaseDate
        scoreLabel.text = "Score: \(score)/100"
        overviewLabel.text = "Description: \(overview)"
    }
    
    func updateAccountFavorites(id:Int){
        let data = updateAccountStruct(media_type: "movie", media_id: id, favorite: true)
        guard let jsonData = try? JSONEncoder().encode(data) else {
            return
        }
        print(sessionID)
        
        let urlstring:String = "https://api.themoviedb.org/3/account/{account_id}/favorite?api_key=6674a05c20e4cc8c1e9c584ac5b7b041&session_id=" + sessionID
        
        print(urlstring)
        guard let url = URL(string: urlstring.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) else {
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.uploadTask(with: request, from: jsonData) { data, response, error in
            if let error = error {
                print ("error: \(error)")
                return
            }
            guard let response = response as? HTTPURLResponse,
                (200...299).contains(response.statusCode) else {
                    print ("server error")
                    return
            }
            if let mimeType = response.mimeType, mimeType == "application/json", let data = data, let dataString = String(data: data, encoding: .utf8) {
                print ("got data: \(dataString)")
            }
            
        }
        task.resume()
    }
    
    
    @IBAction func addToFavoritesButtonPressed(_ sender: UIButton) {
        fetchFavorites()
        for f in favorites {
            if f.id == movieID {
                return
            }
        }
        let favoriteMovie = FavoriteMovie(context: self.context)
        favoriteMovie.id = Int64(movieID)
        favoriteMovie.title = movieTitle
        favoriteMovie.release_date = releaseDate
        favoriteMovie.vote_average = Int64(score)
        favoriteMovie.overview = overview
        favoriteMovie.image = movieImage
        do {
            try self.context.save()
        } catch {
            print("failed to save favorite movie")
        }
        
        if sessionID != "" {
            self.updateAccountFavorites(id: self.movieID)
        }
    }
    
    func fetchFavorites(){
        do {
            self.favorites = try context.fetch(FavoriteMovie.fetchRequest())
        } catch {
            print("Failed to fetch favorite movies")
        }
    }
    
    /*
     MARK: - Navigation
     
     In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     Get the new view controller using segue.destination.
     Pass the selected object to the new view controller.
     }
     */
    
}
