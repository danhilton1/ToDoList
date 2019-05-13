//
//  Item.swift
//  ToDoList
//
//  Created by Daniel Hilton on 22/04/2019.
//  Copyright © 2019 Daniel Hilton. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    
    @objc dynamic var name: String?
    @objc dynamic var completed = false
    @objc dynamic var datetime: Date?
    
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
    
    
}
