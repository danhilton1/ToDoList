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
    @IBOutlet weak var mainView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        mainView.layer.cornerRadius = 18
//        mainView.layer.shadowPath = UIBezierPath(rect: mainView.bounds).cgPath
        
        mainView.layer.shadowColor = UIColor.gray.cgColor
        mainView.layer.shadowOpacity = 0.2
        mainView.layer.shadowOffset = .zero
        mainView.layer.shadowRadius = 3
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
