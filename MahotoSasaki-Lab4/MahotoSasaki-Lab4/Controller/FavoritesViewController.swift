//
//  FavoritesViewController.swift
//  MahotoSasaki-Lab4
//
//  Created by Mahoto Sasaki on 9/20/20.
//  Copyright © 2020 mo3aru. All rights reserved.
//

import UIKit
import CoreData

class FavoritesViewController: UIViewController {
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet weak var tableView: UITableView!
    
    var favorites:[FavoriteMovie] = []
        
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.dataSource = self
        tableView.delegate = self
        
        fetchFavorites()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        fetchFavorites()
    }
    
    func fetchFavorites(){
        do {
            self.favorites = try context.fetch(FavoriteMovie.fetchRequest())
            DispatchQueue.main.async(){
                self.tableView.reloadData()
            }
        } catch {
            print("Failed to fetch favorite movies")
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "goToFavoriteMovie") {
            guard let indexPath = sender as? IndexPath else {
                return
            }
            let favoriteMovieMC = segue.destination as? FavoriteMovieViewController
            favoriteMovieMC?.movieTitle = favorites[indexPath.row].title ?? "N/A"
            favoriteMovieMC?.releaseDate = favorites[indexPath.row].release_date ?? "N/A"
            favoriteMovieMC?.score = Int(favorites[indexPath.row].vote_average * 10)
            favoriteMovieMC?.overview = favorites[indexPath.row].overview ?? "N/A"
            favoriteMovieMC?.movieImage = favorites[indexPath.row].image as? UIImage ?? UIImage()
        }
    }


}

extension FavoritesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return favorites.count
        }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")! as UITableViewCell
        cell.textLabel?.text = favorites[indexPath.row].title
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "goToFavoriteMovie", sender: indexPath);
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let movieBeingDeleted = favorites[indexPath.row]
            self.context.delete(movieBeingDeleted)
            do {
                try self.context.save()
            } catch {
                print("Failed to delete data")
            }
            self.fetchFavorites()
        }
    }
}
