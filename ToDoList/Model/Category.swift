//
//  Category.swift
//  ToDoList
//
//  Created by Daniel Hilton on 22/04/2019.
//  Copyright © 2019 Daniel Hilton. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    
    @objc dynamic var date: String?
    @objc dynamic var title: String?
    @objc dynamic var done = false
    
    let items = List<Item>()
    
}
