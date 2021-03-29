//
//  Model.swift
//  MortyRickApp
//
//  Created by Павел on 16.03.2021.
//

import Foundation

struct Info:Decodable{
    var count: Int
    var pages: Int
    var next: String?
    var prev: String?
}


struct Response: Decodable{
    var info: Info
    var results: [Character]
}


struct Character: Codable, Equatable{
    var id: Int
    var name: String
    var image: URL
}


struct Episodes: Decodable{
    var info: Info
    var results: [Episode]
}

struct Episode: Decodable{
    var id: Int
    var name: String
    var episode: String
    var characters: [String]
}
