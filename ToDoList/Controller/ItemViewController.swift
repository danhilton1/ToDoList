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
    
    //MARK: - Variables
    
    let realm = try! Realm()
    
    var selectedCategory: Category?
    var selectedItem: String?
    var items: Results<Item>?
    
    @IBOutlet weak var itemTitle: UILabel!
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        itemTitle.text = selectedItem
        
        loadItems()
        
        navigationController?.setToolbarHidden(false, animated: true)
        
        tableView.register(UINib(nibName: "CustomCell", bundle: nil), forCellReuseIdentifier: "customCell")
        

        
    }
    
    //MARK: - Tableview Datasource Methods
    
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
        
        if isEditing == false {
        
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
        
    }
    
    
        
    
    //MARK: - Button Methods
   
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
    
    
    @IBAction func editButtonPressed(_ sender: Any) {
        
        tableView.allowsMultipleSelection = true
        tableView.allowsMultipleSelectionDuringEditing = true
        
        isEditing = !isEditing
        
        var myToolbarItems = [UIBarButtonItem]()
        
        if editButton.title == "Edit" {
            editButton.title = "Cancel"
        } else {
            editButton.title = "Edit"
        }
        
        if isEditing == true {
            
            let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            
            let deleteBarButtonItem = UIBarButtonItem(title: "Delete", style: .plain, target: self, action: #selector(deleteRows))
            deleteBarButtonItem.tintColor = UIColor.red
            
            myToolbarItems.append(editButton)
            myToolbarItems.append(flexibleSpace)
            myToolbarItems.append(deleteBarButtonItem)
            
            self.toolbarItems = myToolbarItems
        } else {
            
            self.toolbarItems = [editButton]
        }
        
   
    }
    
    @objc func deleteRows(_ sender: Any) {
        if let selectedRows = tableView.indexPathsForSelectedRows {
            
            var titleArray = [String]()
            for title in 0...items!.count - 1 {
                titleArray.append((items?[title].name)!)
            }
            // 1
            var itemArray = [String]()
            for indexPath in selectedRows  {
                itemArray.append(items?[indexPath.row].name ?? "")
                
            }
            // 2
    
            for item in itemArray {
                if let index = titleArray.firstIndex(of: item) {
                    do {
                        
                        try realm.write {
                            realm.delete(items![index])
                        }
                        //                        tableView.deleteRows(at: selectedRows, with: .fade)
                        
                    } catch {
                        print(error)
                    }
                }
            }
            tableView.reloadData()
            // 3
            //            tableView.beginUpdates()
            //            tableView.deleteRows(at: selectedRows, with: UITableView.RowAnimation.fade)
            //            tableView.endUpdates()
            
            
        }
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
