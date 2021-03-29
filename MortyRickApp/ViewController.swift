//
//  ViewController.swift
//  MortyRickApp
//
//  Created by Павел on 16.03.2021.
//

import UIKit
import Alamofire
import Kingfisher



class ViewController: UIViewController, UICollectionViewDelegateFlowLayout {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchEssentials {
            DispatchQueue.main.async {[weak self] in
                self?.collectionView?.reloadData()
            }
        }
        
        makeRequest(){
            DispatchQueue.main.async {[weak self] in
                self?.collectionView?.reloadData()
            }
        }
        setCollectionView()
        //resetDefaults()
        
        navigationItem.rightBarButtonItem?.image = UIImage(named: "star")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.main.async {
            self.collectionView?.reloadData()
        }
    }
    
    func resetDefaults() {
        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            defaults.removeObject(forKey: key)
        }
    }
    


    @IBOutlet weak var collectionView: UICollectionView!
    
    var characters: [Character] = []
    var info: Info?
    var page = 1
    var essentialCharacters: [Character] = []
    static let dataSaver = DataService()
    var characterIDs: [Int] = []
    
    @IBAction func essentialsButton(_ sender: Any) {
        performSegue(withIdentifier: "star", sender: self)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "star"{
            let essentialViewController = segue.destination as? EssentialViewController
            essentialViewController?.essentialCharacters = self.essentialCharacters
            essentialViewController?.delegate = self
        }
    }
    
    
    func fetchEssentials(completion: @escaping (() -> ())){
        characterIDs = ViewController.dataSaver.loadSavedharacters()
        print(characterIDs)
        for id in Set(characterIDs){
            let request = AF.request("https://rickandmortyapi.com/api/character/\(String(describing: id))")
            request.validate().responseDecodable(of: Character.self){response in
                
                //print(response.value)
                //debugPrint(response)
                guard let response = response.value else {return}
                self.essentialCharacters.append(response)
                //print(self.essentialCharacters)
            }
        
            completion()
        }
        
    }
    
    
    func makeRequest(completion: @escaping (() -> ())){
        let request = AF.request("https://rickandmortyapi.com/api/character/?page=\(String(describing: page))")
        request.validate().responseDecodable(of: Response.self){response in
            
            guard let response = response.value else {return}
            self.characters.append(contentsOf: response.results)
            self.info = response.info
            //print(self.characters)
            DispatchQueue.main.async {
                self.isLoading = false
            }
            completion()
        }
    }

    func setCollectionView(){
        collectionView.dataSource = self
        collectionView.delegate = self
        let loadingReusableNib = UINib(nibName: "CollectionReusableView", bundle: nil)
                collectionView.register(loadingReusableNib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "loadingresuableviewid")
        let essential = EssentialViewController()
        essential.delegate = self
    }

    var isLoading = false
    var loadingView: CollectionReusableView?
}


extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, DisplayEssentialDelegate{
    func displayEssential(characters: [Character]) {
        self.essentialCharacters = characters
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.characters.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: SingleCellView = collectionView.dequeueReusableCell(withReuseIdentifier: "characterCell", for: indexPath) as! SingleCellView
        
        let item = characters[indexPath.row]
        cell.titleLabel.text = item.name
        cell.titleLabel.adjustsFontSizeToFitWidth = true
        cell.titleLabel.sizeToFit()
        
        let imageURL = item.image
        cell.imageView.kf.setImage(with: imageURL)
        cell.setNeedsLayout()
        
        cell.addButon.isEnabled = true
        cell.addButon.tag = item.id
        cell.addButon.addTarget(self, action: #selector(addCharacter), for: .touchUpInside)
        cell.addButon.isSelected = false
        
        for character in self.essentialCharacters{
            if  character.id == cell.addButon.tag {
                print(cell.addButon.tag)
                print(character.id)
                print(self.essentialCharacters)
                DispatchQueue.main.async {
                    cell.addButon.isSelected = true
                    print(cell.addButon.isSelected)
                }
            }
        }
        return cell
    }
    
    @objc func addCharacter(sender: UIButton, cell: UICollectionViewCell){
        
        let character = characters[sender.tag-1]
        
        sender.isSelected = !sender.isSelected

        if !sender.isSelected{
            self.essentialCharacters.removeAll{$0.id == sender.tag}
            self.characterIDs.removeAll{$0 == sender.tag}
            print(self.characterIDs)
        } else {
            self.essentialCharacters.append(character)
            self.characterIDs.append(character.id)
        }
        print(self.essentialCharacters)
        
        
        ViewController.dataSaver.saveCharacters(characterIDs)
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
    
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if indexPath.row == characters.count - 2 && !self.isLoading && self.page != self.info?.pages {
                self.page += 1
                print(self.page)
                makeRequest(){
                    DispatchQueue.main.async {[weak self] in
                        self?.collectionView?.reloadData()
                    }
                }
            }
    }
        
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if self.page == self.info?.pages{
            self.isLoading = true
            print(self.isLoading)
        }
        if self.isLoading {
                    return CGSize.zero
                } else {
                    return CGSize(width: collectionView.bounds.size.width, height: 65)
                }
    }
    

    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionFooter {
            let aFooterView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "loadingresuableviewid", for: indexPath) as! CollectionReusableView
            loadingView = aFooterView
            return aFooterView
        }
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        if elementKind == UICollectionView.elementKindSectionFooter {
                    self.loadingView?.activityIndicator.startAnimating()
                }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath) {
            if elementKind == UICollectionView.elementKindSectionFooter {
                self.loadingView?.activityIndicator.stopAnimating()
            }
        }
}



extension Array {
    public mutating func append(_ newElement: Element?) {
        if let element = newElement {
            self.append(element)
        }
    }
}




