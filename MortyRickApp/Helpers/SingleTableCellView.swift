//
//  SingleTableCellView.swift
//  MortyRickApp
//
//  Created by Павел on 24.03.2021.
//

import UIKit

class SingleTableCellView: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var episodeLabel: UILabel!
   
    @IBOutlet weak var characterLabel: UILabel!
    
}
