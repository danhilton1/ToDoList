//
//  CustomCell.swift
//  ToDoList
//
//  Created by Daniel Hilton on 08/04/2019.
//  Copyright © 2019 Daniel Hilton. All rights reserved.
//

import UIKit

class CustomCell: UITableViewCell {
    
    
    @IBOutlet weak var noteLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var tickButton: UIButton!
    
    let toDoListVC = ToDoListViewController()
    
    
    @IBAction func tickButtonPressed(_ sender: Any) {


        if tickButton.currentImage == UIImage(named: "UncheckedTick") {

            tickButton.setImage(UIImage(named: "CheckedTick"), for: .normal)
        } else {
            tickButton.setImage(UIImage(named: "UncheckedTick"), for: .normal)
        }

        //toDoListVC.saveItems()
        
    }
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        
//        toDoListVC.loadItems()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
