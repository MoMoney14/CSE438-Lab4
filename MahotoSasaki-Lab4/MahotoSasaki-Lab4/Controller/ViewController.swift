//
//  ViewController.swift
//  MahotoSasaki-Lab4
//
//  Created by Mahoto Sasaki on 9/20/20.
//  Copyright © 2020 mo3aru. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    //https://www.youtube.com/watch?v=6XASUd7h5-s
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var movieData:[Movie] = []
    var movieImageCache:[UIImage] = []
    var currentMovie:Movie?
    var currentImage:UIImage?
    
    var count = 0
    var numItemsInSectionOfCollectionView = 3
    var numSection = 0
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var favorites:[FavoriteMovie] = []
    
    let activityView = UIActivityIndicatorView(style: .large)
    
    func fetchData(query:String){
        var urlstring:String = ""
        if query == "" {
            self.movieData = []
            self.emptyMovieCache()
            return
        } else {
            urlstring = "https://api.themoviedb.org/3/search/movie?api_key=6674a05c20e4cc8c1e9c584ac5b7b041&language=en-US&page=1&include_adult=false&query=" + query
        }
        guard let url = URL(string: urlstring) else {
            return
        }
        
        //https://stackoverflow.com/questions/8090579/how-to-display-activity-indicator-in-middle-of-the-iphone-screen
        activityView.startAnimating()
        
        DispatchQueue.global().async {
            do {
                let data = try Data(contentsOf: url)
                let json = try JSONDecoder().decode(APIResults.self, from: data)
                self.movieData = json.results
                self.cacheImages()
                
                DispatchQueue.main.async {
                    self.activityView.stopAnimating()
                    self.collectionView.reloadData()
                    print("RELOADED DATA")
                }
            } catch {
                self.movieData = []
                self.emptyMovieCache()
                print("FAILED TO FETCH")
            }
        }
    }
    
    func cacheImages(){
        for (index, movie) in movieData.enumerated() {
            guard let posterPath = movie.poster_path else {
                movieImageCache.append(UIImage())
                continue
            }
            
            let urlstring = "https://image.tmdb.org/t/p/original\(posterPath)"
            guard let url = URL(string: urlstring) else {
                return
            }
            
            do {
                let data = try Data(contentsOf: url)
                guard let image = UIImage(data: data) else {
                    return
                }
                if index < movieImageCache.count {
                    movieImageCache[index] = image
                } else {
                    movieImageCache.append(image)
                }
            } catch {
                print("ERROR on caching images")
            }
        }
    }
    
    func emptyMovieCache(){
        for (index, _) in movieData.enumerated() {
            movieImageCache[index] = UIImage()
            movieData[index] = Movie(id: 0, poster_path: "", title: "", release_date: "", vote_average: 0, overview: "", vote_count: 0)
        }
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    func fetchFavorites(){
        do {
            self.favorites = try context.fetch(FavoriteMovie.fetchRequest())
        } catch {
            print("Failed to fetch favorite movies")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        collectionView.dataSource = self
        collectionView.delegate = self
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: collectionView.frame.width/3, height: collectionView.frame.height/3)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        collectionView.collectionViewLayout = layout
        
        activityView.center = self.view.center
        self.view.addSubview(activityView)
    }
    
    @IBAction func searchMovieEditingChanged(_ sender: UITextField) {
        guard let searchText = sender.text else {
            return
        }
        fetchData(query: searchText)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let indexPath = collectionView.indexPathsForSelectedItems?.first else {
            return
        }
        let index = indexPath.section * numItemsInSectionOfCollectionView + indexPath.row
        if index >= 0 && index < movieData.count {
            let movieVC = segue.destination as? movieViewController
            movieVC?.movieID = movieData[index].id
            movieVC?.movieTitle = movieData[index].title
            movieVC?.releaseDate = movieData[index].release_date ?? "N/A"
            movieVC?.score = Int(movieData[index].vote_average * 10)
            movieVC?.overview = movieData[index].overview
            movieVC?.movieImage = movieImageCache[index]
        }
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
    
}

//https://stackoverflow.com/questions/35306862/uitableview-delegate-using-extensions-swift learned how to use extensions for cleaner code
extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if movieData.count > 0 {
            if movieData.count % numItemsInSectionOfCollectionView != 0 {
                return Int(ceil(Double(movieData.count) / Double(numItemsInSectionOfCollectionView)))
            } else {
                return movieData.count / numItemsInSectionOfCollectionView
            }
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == movieData.count / numItemsInSectionOfCollectionView {
            return movieData.count % numItemsInSectionOfCollectionView
        }
        return numItemsInSectionOfCollectionView
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath) as! CustomCollectionCell
        
        let index = indexPath.section * numItemsInSectionOfCollectionView + indexPath.row
        if movieData.count > 0 && index < movieData.count {
            cell.movieTitle.isHidden = false
            cell.image.isHidden = false
            cell.movieTitle.text = movieData[index].title
            cell.image.image = movieImageCache[index]
        } else {
            cell.image.isHidden = true
            cell.movieTitle.isHidden = true
        }
        return cell
    }
    
    //https://developer.apple.com/documentation/uikit/uicollectionviewdelegate/3295917-collectionview?language=objc
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let configuration = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { actions -> UIMenu? in
            let favorite = UIAction(title: "Favorite", image: nil, identifier: nil) { action in
                
                let index = indexPath.section * self.numItemsInSectionOfCollectionView + indexPath.row
                
                self.fetchFavorites()
                for f in self.favorites {
                    if f.id == self.movieData[index].id {
                        return
                    }
                }
                
                let favoriteMovie = FavoriteMovie(context: self.context)
                favoriteMovie.id = Int64(self.movieData[index].id)
                favoriteMovie.title = self.movieData[index].title
                favoriteMovie.release_date = self.movieData[index].release_date
                favoriteMovie.vote_average = Int64(self.movieData[index].vote_average * 10)
                favoriteMovie.overview = self.movieData[index].overview
                favoriteMovie.image = self.movieImageCache[index]
                
                
                do {
                    try self.context.save()
                } catch {
                    print("failed to save favorite movie")
                }
                
                if sessionID != "" {
                    self.updateAccountFavorites(id: self.movieData[index].id)
                }
            }
            return UIMenu(__title: "Menu", image: nil, identifier: nil, children:[favorite])
        }
        return configuration
    }
}


