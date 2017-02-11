//
//  MoviesViewController.swift
//  flix
//
//  Created by Sanyam Satia on 2/2/17.
//  Copyright © 2017 Sanyam Satia. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var movies: [NSDictionary]?
    var filteredMovies: [NSDictionary]?
    var endpoint: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        tableView.addGestureRecognizer(tap)
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.makeRequest(_:)), for: UIControlEvents.valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
        
        makeRequest()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let filteredMovies = filteredMovies {
            return filteredMovies.count
        }
        else {
            return 0
        }
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
        
        let movie = filteredMovies![indexPath.row]
        let title = movie.value(forKey: "title") as! String
        let overview = movie.value(forKey: "overview") as! String
        
        let basePosterUrl = "https://image.tmdb.org/t/p/w500/"
        if let moviePosterUrl = movie.value(forKey: "poster_path") as? String {
            let imageUrl = URL(string: basePosterUrl + moviePosterUrl)
            cell.posterView.setImageWith(imageUrl!)
        }
    
        cell.titleLabel.text = title
        cell.overviewLabel.text = overview
        let cellBackgroundView = UIView()
        cellBackgroundView.backgroundColor = UIColor.lightGray
        cell.selectedBackgroundView = cellBackgroundView
        
        return cell
    }
    
    public func makeRequest(_ refreshControl: UIRefreshControl? = nil) {
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = "https://api.themoviedb.org/3/movie/" + self.endpoint + "?api_key=" + apiKey
        let queryUrl = URL(string: url)!
        let request = URLRequest(url: queryUrl, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        let task: URLSessionDataTask = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            if let data = data {
                if let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                    self.movies = dataDictionary.value(forKey: "results") as! [NSDictionary]?
                    self.filteredMovies = self.movies
                    MBProgressHUD.hide(for: self.view, animated: true)
                    self.tableView.reloadData()
                    
                    if(refreshControl != nil) {
                        refreshControl!.endRefreshing()
                    }
                }
            }
        }
        task.resume()
    }
    
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredMovies = searchText.isEmpty ? movies : movies!.filter({(dict: NSDictionary) -> Bool in
            let title = dict.value(forKey: "title") as! String
            return title.range(of: searchText, options: .caseInsensitive) != nil
        })
        
        tableView.reloadData()
    }
    
    func dismissKeyboard() {
        tableView.endEditing(true)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        let selectedCell = sender as! UITableViewCell
        let indexPath = tableView.indexPath(for: selectedCell)
        let selectedMovie = filteredMovies![indexPath!.row]
        
        let detailViewController = segue.destination as! DetailViewController
        detailViewController.movie = selectedMovie
        
    }

}
