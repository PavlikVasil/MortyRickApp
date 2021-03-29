//
//  EpisodesViewController.swift
//  MortyRickApp
//
//  Created by Павел on 24.03.2021.
//

import UIKit
import Alamofire
import Kingfisher

class EpisodesViewController: UIViewController, UICollectionViewDelegateFlowLayout {

    override func viewDidLoad() {
        super.viewDidLoad()
        setTableView()
        makeRequest{
            DispatchQueue.main.async {[weak self] in
                self?.tableView?.reloadData()
            }
        }
    }
    

    @IBOutlet weak var tableView: UITableView!
    
    

    var episodes: [Episode] = []
    var info: Info?
    var page = 1
    
    func makeRequest(completion: @escaping (() -> ())){
        let request = AF.request("https://rickandmortyapi.com/api/episode/?page=\(String(describing: page))")
        request.validate().responseDecodable(of: Episodes.self){response in
            //debugPrint(response)
            
            guard let response = response.value else {return}
            self.episodes.append(contentsOf: response.results)
            self.info = response.info
            print(self.episodes)
            DispatchQueue.main.async {
                self.isLoading = false
            }
            completion()
        }
    }

    func setTableView(){
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    var isLoading = false
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "show"{
            
            let detailViewController = segue.destination as? ListCharactersViewController
            let index = tableView.indexPathsForSelectedRows!.first!.row
            detailViewController?.episode = episodes[index]
        }
    }

}


extension EpisodesViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return self.episodes.count
                
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell: SingleTableCellView = tableView.dequeueReusableCell(withIdentifier: "episodeCell", for: indexPath) as! SingleTableCellView
            let item = episodes[indexPath.row]
            cell.nameLabel.text = item.name
            cell.nameLabel.adjustsFontSizeToFitWidth = true
            cell.nameLabel.sizeToFit()
            cell.episodeLabel.text = item.episode
            return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
                return 44
        }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let pages = self.info?.pages else {return}
        if self.page == pages{
            self.isLoading = true
        }
        
        if indexPath.row == episodes.count - 2 && !self.isLoading && self.page != pages {
                self.page += 1
                makeRequest(){
                    DispatchQueue.main.async {[weak self] in
                        self?.tableView?.reloadData()
                    }
                }
            }
    }
    
    
}

