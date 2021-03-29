//
//  DataService.swift
//  MortyRickApp
//
//  Created by Павел on 28.03.2021.
//

import Foundation

protocol DataSaver {
    func saveCharacters(_ characters: [Int])
    func loadSavedharacters() -> [Int]
}

class DataService: DataSaver{
    
    func saveCharacters(_ characters: [Int]) {
        UserDefaults.standard.set(characters, forKey: "SavedCharacters")
        print("SAVE")
        
    }
    
    func loadSavedharacters() -> [Int] {
        print("LOAD")
        return UserDefaults.standard.array(forKey: "SavedCharacters") as? [Int] ?? [Int]()
    }
    
    
    
    
}
