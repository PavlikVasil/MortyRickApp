//
//  SearchViewController.swift
//  MortyRickApp
//
//  Created by Павел on 24.03.2021.
//

import UIKit
import Alamofire
import Kingfisher

class SearchViewController: UIViewController, UICollectionViewDelegateFlowLayout {
    

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var infoLabel: UILabel!
    

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        infoLabel.isHidden = true
        setCollectionView()
        //makeRefreshActivityIndicator()
        
    }
    
    func setCollectionView(){
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    var pendingRequestWorkItem: DispatchWorkItem?
    var activityIndicatorView: UIActivityIndicatorView!
    var activityIndicatorBackgroundView: UIView!
    var characters: [Character] = []
    
    
    func makeRequest(searchTerm: String, completion: @escaping () -> ()){
        pendingRequestWorkItem?.cancel()
        
        let requestWorkItem = DispatchWorkItem { [weak self] in
            DispatchQueue.main.async { [weak self] in
                self?.activityIndicatorView.isHidden = false
                self?.activityIndicatorBackgroundView.isHidden = false
            }
        
            let request = AF.request("https://rickandmortyapi.com/api/character/?name=\(searchTerm)")
            request.validate().responseDecodable(of: Response.self){data in
            //debugPrint(response)
                switch data.result{
                case .success(var response):
                    response = data.value!
                    self?.characters.append(contentsOf: response.results)
                case .failure(var error):
                    error = data.error!
                }
            //print(self?.characters)
            completion()
            }
        }
        
        pendingRequestWorkItem = requestWorkItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: requestWorkItem)
    }
    
    
    func makeRefreshActivityIndicator() {
        activityIndicatorBackgroundView = UIView()
        activityIndicatorBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorBackgroundView.backgroundColor = UIColor.init(white: 1, alpha: 0.8)
        activityIndicatorBackgroundView.layer.cornerRadius = 15
        activityIndicatorBackgroundView.isHidden = true
        
        view.addSubview(activityIndicatorBackgroundView)
        
        let activityIndicatorBackgroundViewConstraints = [
            activityIndicatorBackgroundView.centerYAnchor.constraint(equalTo: collectionView.centerYAnchor),
            activityIndicatorBackgroundView.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor),
            activityIndicatorBackgroundView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.15),
            activityIndicatorBackgroundView.heightAnchor.constraint(equalTo: activityIndicatorBackgroundView.widthAnchor)]
        NSLayoutConstraint.activate(activityIndicatorBackgroundViewConstraints)
        
        activityIndicatorView = UIActivityIndicatorView(style: .gray)
        activityIndicatorView.tintColor = .gray
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.startAnimating()
        activityIndicatorView.isHidden = true
        
        activityIndicatorBackgroundView.addSubview(activityIndicatorView)
        
        let activityIndicatorViewConstraints = [
            activityIndicatorView.centerYAnchor.constraint(equalTo: activityIndicatorBackgroundView.centerYAnchor),
            activityIndicatorView.centerXAnchor.constraint(equalTo: activityIndicatorBackgroundView.centerXAnchor)]
        NSLayoutConstraint.activate(activityIndicatorViewConstraints)
    }

}

extension SearchViewController: UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.characters.removeAll()
        print(self.characters)
        guard let searchText = searchBar.text?.lowercased() else {return print("error")}
        //searchBar.resignFirstResponder()
        self.makeRequest(searchTerm: searchText) {
                DispatchQueue.main.async {
                    self.activityIndicatorView.isHidden = true
                    self.activityIndicatorBackgroundView.isHidden = true
                    self.collectionView.reloadData()
                    if  self.characters.isEmpty{
                        self.activityIndicatorView.isHidden = true
                        self.activityIndicatorBackgroundView.isHidden = true
                        self.infoLabel.isHidden = false
                        self.infoLabel?.text = "Nothing found"
                    } else {
                         self.infoLabel.isHidden = true
                    }
            }
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        makeRefreshActivityIndicator()
        activityIndicatorView.isHidden = true
        activityIndicatorBackgroundView.isHidden = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.makeRequest(searchTerm: searchText) {
                DispatchQueue.main.async {
                    self.activityIndicatorView.isHidden = true
                    self.activityIndicatorBackgroundView.isHidden = true
                    self.collectionView.reloadData()
                    if  self.characters.isEmpty{
                        self.activityIndicatorView.isHidden = true
                        self.activityIndicatorBackgroundView.isHidden = true
                        self.infoLabel.isHidden = false
                        self.infoLabel?.text = "Nothing found"
                    } else {
                         self.infoLabel.isHidden = true
                    }
            }
        }
    }
}

extension SearchViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.characters.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: SingleCellView = collectionView.dequeueReusableCell(withReuseIdentifier: "searchCell", for: indexPath) as! SingleCellView
        
        let item = characters[indexPath.row]
        cell.titleLabel.text = item.name
        cell.titleLabel.adjustsFontSizeToFitWidth = true
        cell.titleLabel.sizeToFit()
        
        let imageURL = item.image
        cell.imageView.kf.setImage(with: imageURL)
        cell.setNeedsLayout()

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let noOfCellsInRow = 2
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let totalSpace = flowLayout.sectionInset.left
            + flowLayout.sectionInset.right
            + (flowLayout.minimumInteritemSpacing * CGFloat(noOfCellsInRow - 1))
        let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(noOfCellsInRow))
        return CGSize(width: size, height: size)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let searchView: UICollectionReusableView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "SearchBar", for: indexPath)
        return searchView
    }
    
    
    
}


