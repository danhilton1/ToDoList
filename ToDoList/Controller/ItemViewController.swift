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
    var myToolbarItems = [UIBarButtonItem]()
    
    @IBOutlet weak var itemTitle: UILabel!
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadItems()
        setUpViews()
          
    }
    
    func setUpViews() {
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.setToolbarHidden(false, animated: true)
        tableView.register(UINib(nibName: "CustomCell", bundle: nil), forCellReuseIdentifier: "customCell")
        itemTitle.text = selectedItem
        
        tableView.tableFooterView = UIView()
    }

    
    
        
    
    //MARK: - Button Methods
   
    @IBAction func addButtonPressed(_ sender: Any) {
        
        var myTextField = UITextField()
        
        let alert = UIAlertController(title: "Add a New Item to \(itemTitle.text!)", message: "", preferredStyle: .alert)
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            myTextField = alertTextField
            myTextField.autocapitalizationType = .sentences
            
        }
        
        let alertAddAction = UIAlertAction(title: "Add", style: .default) { (UIAlertAction) in
            

            if myTextField.text != "" {
                
                if let currentCategory = self.selectedCategory {
                    do {
                        try self.realm.write {
                            let newItem = Item()
                            newItem.name = myTextField.text!
                            newItem.completed = false
                            newItem.datetime = Date()
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
        
        if editButton.title == "Edit" {
            editButton.title = "Cancel"
        } else {
            editButton.title = "Edit"
        }
        
        if isEditing == true {
            
            if tableView.indexPathsForSelectedRows?.count == nil {
            
                setDeleteAllToolbarItems()
                
            } else {
                
               setDeleteToolbarItems()
                
            }
        } else {
            
            self.toolbarItems = [editButton]
        }

        
   
    }
    
    //MARK: - Toolbar Methods
    
    func setDeleteToolbarItems() {
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        let deleteBarButtonItem = UIBarButtonItem(title: "Delete", style: .plain, target: self, action: #selector(deleteRows))
        deleteBarButtonItem.tintColor = UIColor.red
        
        myToolbarItems = [editButton, flexibleSpace, deleteBarButtonItem]
        
        self.toolbarItems = myToolbarItems
    }
    
    
    func setDeleteAllToolbarItems() {
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        let deleteAllBarButtonItem = UIBarButtonItem(title: "Delete All", style: .plain, target: self, action: #selector(deleteAllRows))
        deleteAllBarButtonItem.tintColor = UIColor.red
        
        myToolbarItems = [editButton, flexibleSpace, deleteAllBarButtonItem]
        
        self.toolbarItems = myToolbarItems
    }
    
    //MARK: Delete row methods
    
    
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
    
    @objc func deleteAllRows() {
        
        let alert = UIAlertController(title: "Delete all items?", message: nil, preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (UIAlertAction) in
            
            if let allRows = self.items {
                
                do {
                    try self.realm.write {
                        self.realm.delete(allRows)
                    }
                } catch {
                    print("Error deleting all rows - \(error)")
                }
                
                self.tableView.reloadData()
                self.isEditing = false
                self.toolbarItems = [self.editButton]
                if self.editButton.title == "Cancel" {
                    self.editButton.title = "Edit"
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (UIAlertAction) in
            self.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    
    //MARK: - Save and load item methods
    
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
        
        items = selectedCategory?.items.sorted(byKeyPath: "datetime", ascending: true)
        
        tableView.reloadData()
    }
    

}


//MARK:- Extension for TableView Delegate and DataSource methods

extension ItemViewController {
    
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
        
        } else if isEditing == true && tableView.indexPathForSelectedRow?.count != nil {
            
            setDeleteToolbarItems()

        }
        
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {

        if isEditing == true && tableView.indexPathsForSelectedRows?.count == nil {

            setDeleteAllToolbarItems()
        }
        

    }
}
