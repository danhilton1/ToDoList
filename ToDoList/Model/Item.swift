//
//  Item.swift
//  ToDoList
//
//  Created by Daniel Hilton on 01/04/2019.
//  Copyright © 2019 Daniel Hilton. All rights reserved.
//

import Foundation

class Item: Encodable, Decodable {
    
    var title: String?
    
    var done: Bool = false
    
    
    
}
