//
//  MainViewController.swift
//  MahotoSasaki-Lab4
//
//  Created by Mahoto Sasaki on 10/30/20.
//  Copyright © 2020 mo3aru. All rights reserved.
//

import UIKit
import CoreData

class MainViewController: UIViewController {
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var popularMovieData:[Movie] = []
    var latestMovieData:[Movie] = []
    var upcomingMovieData:[Movie] = []
    
    var upcomingMovieImageCache:[UIImage] = []
    var latestMovieImageCache:[UIImage] = []
    
    var popularMovieImageCache:[UIImage] = []
    var currentMovie:Movie?
    var currentImage:UIImage?
    
    var count = 0
    var numItemsInSectionOfCollectionView = 3
    var numSection = 0
    
    @IBOutlet weak var popularCollectionView: UICollectionView!
    @IBOutlet weak var latestCollectionView: UICollectionView!
    @IBOutlet weak var upcomingCollectionView: UICollectionView!
    
    var favorites:[FavoriteMovie] = []
    
    let activityView = UIActivityIndicatorView(style: .large)
    
    func fetchData(key:String, urlString:String){
        guard let url = URL(string: urlString) else {
            return
        }
        
        //https://stackoverflow.com/questions/8090579/how-to-display-activity-indicator-in-middle-of-the-iphone-screen
        activityView.startAnimating()
        
        DispatchQueue.global().async {
            do {
                let data = try Data(contentsOf: url)
                let json = try JSONDecoder().decode(APIResults.self, from: data)
                
                if key == "popular" {
                    self.popularMovieData = json.results
                    self.popularMovieImageCache = self.cacheImages(movieData: self.popularMovieData, movieImageCache: self.popularMovieImageCache)
                } else if key == "latest" {
                    self.latestMovieData = json.results
                    self.latestMovieImageCache = self.cacheImages(movieData: self.latestMovieData, movieImageCache: self.latestMovieImageCache)
                } else if key == "upcoming" {
                    self.upcomingMovieData = json.results
                    self.upcomingMovieImageCache = self.cacheImages(movieData: self.upcomingMovieData, movieImageCache: self.upcomingMovieImageCache)
                }
                
                DispatchQueue.main.async {
                    self.activityView.stopAnimating()
                    
                    if key == "popular" {
                        self.popularCollectionView.reloadData()
                    } else if key == "latest" {
                        self.latestCollectionView.reloadData()
                    } else if key == "upcoming" {
                        self.upcomingCollectionView.reloadData()
                    }
                    print("Succesfully fetched DATA")
                }
            } catch {
                if key == "popular" {
                    self.popularMovieData = []
                    let popularData = self.emptyMovieCache(k: key, movieData: self.popularMovieData, movieImageCache: self.popularMovieImageCache)
                    self.popularMovieData = popularData.0
                    self.popularMovieImageCache = popularData.1
                } else if key == "latest" {
                    self.latestMovieData = []
                    let latestData = self.emptyMovieCache(k: key, movieData: self.latestMovieData, movieImageCache: self.latestMovieImageCache)
                    self.latestMovieData = latestData.0
                    self.latestMovieImageCache = latestData.1
                } else if key == "upcoming" {
                    self.upcomingMovieData = []
                    let upcomingData = self.emptyMovieCache(k: key, movieData: self.upcomingMovieData, movieImageCache: self.upcomingMovieImageCache)
                    self.upcomingMovieData = upcomingData.0
                    self.upcomingMovieImageCache = upcomingData.1
                }
                print("FAILED TO FETCH")
            }
        }
    }
    
    func cacheImages(movieData:[Movie], movieImageCache:[UIImage]) -> [UIImage] {
        var mutatedMovieImageCache = movieImageCache
        
        for (index, movie) in movieData.enumerated() {
            guard let posterPath = movie.poster_path else {
                mutatedMovieImageCache.append(UIImage())
                continue
            }
            
            let urlstring = "https://image.tmdb.org/t/p/original\(posterPath)"
            guard let url = URL(string: urlstring) else {
                return mutatedMovieImageCache
            }
            
            do {
                let data = try Data(contentsOf: url)
                guard let image = UIImage(data: data) else {
                    return mutatedMovieImageCache
                }
                if index < mutatedMovieImageCache.count {
                    mutatedMovieImageCache[index] = image
                } else {
                    mutatedMovieImageCache.append(image)
                }
            } catch {
                print("ERROR on caching images")
            }
        }
        return mutatedMovieImageCache
    }
    
    func emptyMovieCache(k:String, movieData:[Movie], movieImageCache:[UIImage]) -> ([Movie] , [UIImage]) {
        var mutatedMovieArray = movieData
        var mutatedMovieImageCache = movieImageCache
        for (index, _) in mutatedMovieArray.enumerated() {
            mutatedMovieImageCache[index] = UIImage()
            mutatedMovieArray[index] = Movie(id: 0, poster_path: "", title: "", release_date: "", vote_average: 0, overview: "", vote_count: 0)
        }
        DispatchQueue.main.async {
            if k == "popular" {
                self.popularCollectionView.reloadData()
            } else if k == "latest" {
                self.latestCollectionView.reloadData()
            } else if k == "upcoming" {
                self.upcomingCollectionView.reloadData()
            }
        }
        let data = (mutatedMovieArray, mutatedMovieImageCache)
        return data
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
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: popularCollectionView.frame.width/3, height: popularCollectionView.frame.height)
        layout.minimumInteritemSpacing = CGFloat.greatestFiniteMagnitude
        layout.scrollDirection = .horizontal
        
        popularCollectionView.dataSource = self
        popularCollectionView.delegate = self
        popularCollectionView.collectionViewLayout = layout
        
        let layout2: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout2.itemSize = CGSize(width: latestCollectionView.frame.width/3, height: latestCollectionView.frame.height)
        layout2.minimumInteritemSpacing = CGFloat.greatestFiniteMagnitude
        layout2.scrollDirection = .horizontal
        
        latestCollectionView.dataSource = self
        latestCollectionView.delegate = self
        latestCollectionView.collectionViewLayout = layout2
        
        let layout3: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout3.itemSize = CGSize(width: upcomingCollectionView.frame.width/3, height: upcomingCollectionView.frame.height)
        layout3.minimumInteritemSpacing = 0
        layout3.scrollDirection = .horizontal
        
        
        upcomingCollectionView.dataSource = self
        upcomingCollectionView.delegate = self
        upcomingCollectionView.collectionViewLayout = layout3
        
        activityView.center = self.view.center
        self.view.addSubview(activityView)
        fetchData(key: "popular", urlString: "https://api.themoviedb.org/3/movie/popular?api_key=6674a05c20e4cc8c1e9c584ac5b7b041")
        fetchData(key: "latest", urlString: "https://api.themoviedb.org/3/movie/now_playing?api_key=6674a05c20e4cc8c1e9c584ac5b7b041")
        fetchData(key: "upcoming", urlString: "https://api.themoviedb.org/3/movie/upcoming?api_key=6674a05c20e4cc8c1e9c584ac5b7b041")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var index:Int = -1
        var movie:[Movie] = []
        var movieImageCache:[UIImage] = []
        if segue.identifier == "first" {
            if let popularIndexPath = popularCollectionView.indexPathsForSelectedItems?.first {
                index = popularIndexPath.row
                movie = popularMovieData
                movieImageCache = popularMovieImageCache
                print(popularIndexPath.row)
            }
        } else if segue.identifier == "second" {
            if let latestIndexPath = latestCollectionView.indexPathsForSelectedItems?.first {
                index = latestIndexPath.row
                movie = latestMovieData
                movieImageCache = latestMovieImageCache
            }
        } else if segue.identifier == "third" {
            if let upcomingIndexPath = upcomingCollectionView.indexPathsForSelectedItems?.first {
                index = upcomingIndexPath.row
                movie = upcomingMovieData
                movieImageCache = upcomingMovieImageCache
            }
        }
        
        if index >= 0 && index < movie.count {
            let movieVC = segue.destination as? movieViewController
            movieVC?.movieID = movie[index].id
            movieVC?.movieTitle = movie[index].title
            movieVC?.releaseDate = movie[index].release_date ?? "N/A"
            movieVC?.score = Int(movie[index].vote_average * 10)
            movieVC?.overview = movie[index].overview
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
extension MainViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView === popularCollectionView {
            return popularMovieData.count
        } else if collectionView === latestCollectionView {
            return latestMovieData.count
        } else if collectionView == upcomingCollectionView {
            return upcomingMovieData.count
        }
        return popularMovieData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath) as! HomeCollectionViewCell
        let index = indexPath.row
        
        var movieData:[Movie] = []
        var movieCacheImage:[UIImage] = []
        
        if collectionView === popularCollectionView {
            movieData = popularMovieData
            movieCacheImage = popularMovieImageCache
        } else if collectionView === latestCollectionView {
            movieData = latestMovieData
            movieCacheImage = latestMovieImageCache
        } else if collectionView === upcomingCollectionView {
            movieData = upcomingMovieData
            movieCacheImage = upcomingMovieImageCache
        }
        
        if movieData.count > 0 && index < movieData.count {
            cell.movieTitle.isHidden = false
            cell.image.isHidden = false
            cell.movieTitle.text = movieData[index].title
            cell.image.image = movieCacheImage[index]
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
                
                let index = indexPath.row
                
                var movieData:[Movie] = []
                var movieCacheImage:[UIImage] = []
                if collectionView === self.popularCollectionView {
                    movieData = self.popularMovieData
                    movieCacheImage = self.popularMovieImageCache
                } else if collectionView === self.latestCollectionView {
                    movieData = self.latestMovieData
                    movieCacheImage = self.latestMovieImageCache
                } else if collectionView === self.upcomingCollectionView {
                    movieData = self.upcomingMovieData
                    movieCacheImage = self.upcomingMovieImageCache
                }
                
                self.fetchFavorites()
                
                for f in self.favorites {
                    if f.id == movieData[index].id {
                        return
                    }
                }
                
                let favoriteMovie = FavoriteMovie(context: self.context)
                favoriteMovie.id = Int64(movieData[index].id)
                favoriteMovie.title = movieData[index].title
                favoriteMovie.release_date = movieData[index].release_date
                favoriteMovie.vote_average = Int64(movieData[index].vote_average * 10)
                favoriteMovie.overview = movieData[index].overview
                favoriteMovie.image = movieCacheImage[index]
                
                do {
                    try self.context.save()
                } catch {
                    print("failed to save favorite movie")
                }
                
                if sessionID != "" {
                    self.updateAccountFavorites(id: movieData[index].id)
                }
            }
            return UIMenu(__title: "Menu", image: nil, identifier: nil, children:[favorite])
        }
        return configuration
    }
}


