//
//  ViewController.swift
//  ToDoList
//
//  Created by Daniel Hilton on 30/03/2019.
//  Copyright © 2019 Daniel Hilton. All rights reserved.
//

import UIKit

class ToDoListViewController: UITableViewController {
    
    let defaults = UserDefaults()
    
    var itemArray = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let items = defaults.array(forKey: "ToDoListArray") as? [String] {
            itemArray = items
        }
        
    }
    
    //MARK: - Tableview Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoListCell", for: indexPath)
        
        cell.textLabel?.text = itemArray[indexPath.row]
        
        return cell
    }
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView.cellForRow(at: indexPath)?.accessoryType != .checkmark {
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        } else {
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    

    @IBAction func newItemPressed(_ sender: Any) {
        
        var myTextField = UITextField()
        
        let alert = UIAlertController(title: "Add a New Item to ToDoList", message: "", preferredStyle: .alert)
       
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            myTextField = alertTextField
            
        }
        
        let alertAddAction = UIAlertAction(title: "Add", style: .default) { (UIAlertAction) in
            
            if myTextField.text != "" {
                self.itemArray.append(myTextField.text!)
                self.defaults.set(self.itemArray, forKey: "ToDoListArray")
                self.tableView.reloadData()
            } else {
                self.dismiss(animated: true, completion: nil)
            }
 
//            if let newItem = myTextField.text {
//            self.itemArray.append(newItem)
//            self.tableView.reloadData()
//            } else {
//                self.dismiss(animated: true, completion: nil)
//            }
        }
        
        let alertCancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (UIAlertAction) in
            self.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(alertAddAction)
        alert.addAction(alertCancelAction)
        
        present(alert, animated: true, completion: nil)
        
        
    }
    
    
}

