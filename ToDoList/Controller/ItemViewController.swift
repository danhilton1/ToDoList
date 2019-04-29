//
//  ItemViewController.swift
//  ToDoList
//
//  Created by Daniel Hilton on 09/04/2019.
//  Copyright © 2019 Daniel Hilton. All rights reserved.
//

import UIKit
import RealmSwift

class ItemViewController: UITableViewController {
    
    let realm = try! Realm()
    
    var selectedCategory: Category?
    
    var selectedItem: String?
    
    var items: Results<Item>?
    
    var itemArray: Results<Item>?

    @IBOutlet weak var itemTitle: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        print(toDoListVC.itemTitle)
        
//        itemTitle.text = toDoListVC.itemTitle
        itemTitle.text = selectedItem
        
        loadItems()
        
        navigationController?.setToolbarHidden(false, animated: true)
        
        tableView.register(UINib(nibName: "CustomCell", bundle: nil), forCellReuseIdentifier: "customCell")
        

        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath)
        
        let item = items?[indexPath.row] ?? Item()
        
        cell.textLabel?.text = item.name
        
        cell.accessoryType = item.completed ? .checkmark : .none
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            
            deleteRowAtIndexPath(indexPath: indexPath)
            
        }
    }
    
    private func deleteRowAtIndexPath(indexPath: IndexPath) {
        
        if let item = items?[indexPath.row] {
            do {
                try realm.write() {
                    realm.delete(item)
                }
                tableView.deleteRows(at: [indexPath as IndexPath], with: .fade)
            } catch {
                print("Could not delete item - \(error)")
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = items?[indexPath.row] {
            do {
                try realm.write {
                    item.completed = !item.completed
                }
            } catch {
                    print("Error getting checkmark - \(error)")
                }
            }
        
        tableView.reloadData()
        
        }
    
    
        
    

   
    @IBAction func addButtonPressed(_ sender: Any) {
        
        var myTextField = UITextField()
        
        let alert = UIAlertController(title: "Add a New Item to \(itemTitle.text!)", message: "", preferredStyle: .alert)
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            myTextField = alertTextField
            
        }
        
        let alertAddAction = UIAlertAction(title: "Add", style: .default) { (UIAlertAction) in
            
            
            
            
            
            if myTextField.text != "" {
                
                if let currentCategory = self.selectedCategory {
                    do {
                        try self.realm.write {
                            let newItem = Item()
                            newItem.name = myTextField.text!
                            newItem.completed = false
                            currentCategory.items.append(newItem)
                        }
                    } catch {
                            print("Error saving item - \(error)")
                        }
                } else {
                }
            } else {
                self.dismiss(animated: true, completion: nil)
            }
            
            self.tableView.reloadData()
        }
        
        let alertCancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (UIAlertAction) in
            self.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(alertAddAction)
        alert.addAction(alertCancelAction)
        
        present(alert, animated: true, completion: nil)
        
        
    }
        
    func saveItems(item: Item) {
        
        do {
            try realm.write {
                realm.add(item)
            }
        } catch {
            print(error)
        }
        
        tableView.reloadData()
        
    }
    
    func loadItems() {
        
        items = selectedCategory?.items.sorted(byKeyPath: "name", ascending: false)
//        items = realm.objects(Item.self)
        
        tableView.reloadData()
    }
    

}
