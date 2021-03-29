//
//  ListCharactersViewController.swift
//  MortyRickApp
//
//  Created by Павел on 24.03.2021.
//

import UIKit
import Alamofire

class ListCharactersViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeRequest(){
            self.setTableView()
            DispatchQueue.main.async {[weak self] in
                self?.tableView?.reloadData()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let index = self.tableView.indexPathForSelectedRow{
            self.tableView.deselectRow(at: index, animated: true)
        }
    }
    

    
    func setTableView(){
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    var episode: Episode?
    var characters: [Character] = []
    var character: Character?
    
    func makeRequest(completion: @escaping (() -> ())){
        for character in episode!.characters{
            let request = AF.request("\(String(describing: character))")
            request.validate().responseDecodable(of: Character.self){response in
                guard let response = response.value else {return}
                self.character = response
                self.characters.append(self.character!)
                print(self.characters)
                completion()
        }
        }
    }
}

extension ListCharactersViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.characters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: SingleTableCellView = tableView.dequeueReusableCell(withIdentifier: "characterCell", for: indexPath) as! SingleTableCellView
        let item = characters[indexPath.row]
        cell.characterLabel.text = item.name
        return cell
    }
    
}
