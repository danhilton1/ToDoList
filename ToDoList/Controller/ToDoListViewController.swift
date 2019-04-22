//
//  ViewController.swift
//  ToDoList
//
//  Created by Daniel Hilton on 30/03/2019.
//  Copyright © 2019 Daniel Hilton. All rights reserved.
//

import UIKit
import CoreData

class ToDoListViewController: UITableViewController {
    
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var itemArray = [Item]()
    
//    var itemTitleArray = [String]()
    var itemTitle = ""

    @IBOutlet weak var editButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
         tableView.register(UINib(nibName: "CustomCell", bundle: nil), forCellReuseIdentifier: "customCell")
        
//        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))

        loadItems()
        
        
        
        
    }
    
    //MARK: - Tableview Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as! CustomCell
        
        let item = itemArray[indexPath.row]
        
        cell.noteLabel?.text = item.title
//        itemTitleArray.append(cell.noteLabel.text!)
        cell.dateLabel.text = item.date
        
        if item.done == false {
            cell.accessoryType = .none
        } else if item.done == true {
            cell.accessoryType = .checkmark
        }
        
         //cell.tickButton.addTarget(self, action: #selector(ToDoListViewController.tickButtonPressed), for: .touchUpInside)
        
        
        
        
//        cell.accessoryType = item.done ? .checkmark : .none
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            
            context.delete(itemArray[indexPath.row])
            itemArray.remove(at: indexPath.row)
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.fade)
            tableView.endUpdates()
            
            do {
                try context.save()
            } catch {
                print(error)
            }
            

        }
    }
    
    
    // TRYING TO GET THE TICK BUTTON TO CHANGE THE DONE PROPERTY EACH TIME IT IS PRESSED!!
    
//    @objc func tickButtonPressed() {
//
//
//
//
//    }
    
    //MARK: - TableView Delegate Methods
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goToItem" {
            
            let destVC = segue.destination as! ItemViewController
            destVC.selectedItem = sender as? String
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
//        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
//
//        saveItems()
        
    
        
        let cell = tableView.cellForRow(at: indexPath) as! CustomCell
//        print(cell.noteLabel.text!)

        itemTitle = cell.noteLabel.text!
        print(itemTitle)
        

        if isEditing == false {
            performSegue(withIdentifier: "goToItem", sender: itemTitle)
            tableView.deselectRow(at: indexPath, animated: true)
        }
        

    }
    
    
    

    @IBAction func newItemPressed(_ sender: Any) {
        
        var myTextField = UITextField()
        
        let alert = UIAlertController(title: "Add a New Item to ToDoList", message: "", preferredStyle: .alert)
       
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            myTextField = alertTextField
            
        }
        
        let alertAddAction = UIAlertAction(title: "Add", style: .default) { (UIAlertAction) in
            
            
            
            let newItem = Item(context: self.context)
            
            if myTextField.text != "" {
                
                let date = Date()
                let formatter = DateFormatter()
                formatter.dateFormat = "dd.MM.yyyy"
                
                newItem.title = myTextField.text!
                newItem.date = formatter.string(from: date)
                newItem.done = false
                self.itemArray.append(newItem)
                
                self.saveItems()
                
            } else {
                self.dismiss(animated: true, completion: nil)
            }
 
        }
        
        let alertCancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (UIAlertAction) in
            self.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(alertAddAction)
        alert.addAction(alertCancelAction)
        
        present(alert, animated: true, completion: nil)
        
        
    }
    
    
    @IBAction func editButtonPressed(_ sender: UIBarButtonItem) {
        
        tableView.allowsMultipleSelection = true
        tableView.allowsMultipleSelectionDuringEditing = true
        
        isEditing = !isEditing
        
        
        
        if editButton.title == "Edit" {
            editButton.title = "Cancel"
        } else {
            editButton.title = "Edit"
        }
        
        if isEditing == true {
            let rightBarButtonItem = UIBarButtonItem(title: "Delete", style: .plain, target: self, action: #selector(deleteRows))
            rightBarButtonItem.tintColor = UIColor.white
        
            navigationItem.rightBarButtonItem = rightBarButtonItem
        } else {
            let addButton = UIBarButtonItem(title: "", style: .plain, target: self, action: #selector(newItemPressed))
            addButton.image = UIImage(named: "icons8-plus-50")
            addButton.tintColor = UIColor.white
            
            navigationItem.rightBarButtonItem = addButton
        }

    }
    
    @objc func deleteRows(_ sender: Any) {
        if let selectedRows = tableView.indexPathsForSelectedRows {
            // 1
            var items = [Item]()
            for indexPath in selectedRows  {
                items.append(itemArray[indexPath.row])
            }
            // 2
            for item in items {
                if let index = itemArray.firstIndex(of: item) {
                    context.delete(itemArray[index])
                    itemArray.remove(at: index)
                }
            }
            // 3
            tableView.beginUpdates()
            tableView.deleteRows(at: selectedRows, with: UITableView.RowAnimation.fade)
            tableView.endUpdates()
            
            do {
                try context.save()
            } catch {
                print(error)
            }
        }
    }
    
    func saveItems() {
        
        do {
            try context.save()
        } catch {
            print(error)
        }
        
        tableView.reloadData()
        
    }
    
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest()) {

        
        do {
            itemArray = try context.fetch(request)
        } catch {
            print(error)
        }
        
        tableView.reloadData()
    }
    

}

extension ToDoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        request.predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        loadItems(with: request)
        
        searchBar.resignFirstResponder()
        
        
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText != "" {
            let request: NSFetchRequest<Item> = Item.fetchRequest()
            request.predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchText)
        
            request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
            loadItems(with: request)
            
        } else {
            loadItems()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.text = ""
        searchBar.resignFirstResponder()
        loadItems()
        tableView.reloadData()
        
        
    }
    
}

