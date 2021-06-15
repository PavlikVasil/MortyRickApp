//
//  EssentialViewController.swift
//  MortyRickApp
//
//  Created by Павел on 25.03.2021.
//

import UIKit

protocol DisplayEssentialDelegate{
    func displayEssential(characters: [Character])
}

class EssentialViewController: UIViewController, UICollectionViewDelegateFlowLayout {

    //MARK: -Properties
    @IBOutlet weak var collectionView: UICollectionView!
    
    var delegate: DisplayEssentialDelegate?
    private var dataSaver: DataService!
    var essentialCharacters: [Character] = []
    private var characterIDs: [Int] = []
    
    
    //MARK: -Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setCollectionView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        delegate?.displayEssential(characters: self.essentialCharacters)
        print(self.essentialCharacters)
        print("BACK")
    }
    

    //MARK: -Methods
    private func setCollectionView(){
        collectionView.dataSource = self
        collectionView.delegate = self
        
    }
}


//MARK: -Extension
extension EssentialViewController: UICollectionViewDataSource, UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.essentialCharacters.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: SingleCellView = collectionView.dequeueReusableCell(withReuseIdentifier: "essentialCell", for: indexPath) as! SingleCellView
        
        let item = essentialCharacters[indexPath.row]
        cell.titleLabel.text = item.name
        cell.titleLabel.adjustsFontSizeToFitWidth = true
        cell.titleLabel.sizeToFit()
        
        let imageURL = item.image
        cell.imageView.kf.setImage(with: imageURL)
        cell.setNeedsLayout()
        
        cell.addButon.isEnabled = true
        cell.addButon.tag = item.id
        cell.addButon.addTarget(self, action: #selector(removeCharacter), for: .touchUpInside)
        
        cell.addButon.isSelected = true
        print(cell.addButon.tag)
        return cell
    }
    
    @objc func removeCharacter(sender: UIButton, cell: UICollectionViewCell){
        //let character = essentialCharacters[sender.tag]
        sender.isSelected = !sender.isSelected
        print(sender.tag)
        
        essentialCharacters.removeAll{$0.id == sender.tag}
        
        print(self.essentialCharacters)
        /*if sender.isSelected{
            self.characterIDs.append(sender.tag)
        }*/
        for character in essentialCharacters{
            self.characterIDs.append(character.id)
            print(characterIDs)
        }
        ViewController.dataSaver.saveCharacters(characterIDs)
        self.collectionView.reloadData()
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
    
    
    
}
