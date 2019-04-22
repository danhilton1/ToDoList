//
//  ItemViewController.swift
//  ToDoList
//
//  Created by Daniel Hilton on 09/04/2019.
//  Copyright © 2019 Daniel Hilton. All rights reserved.
//

import UIKit
import CoreData

class ItemViewController: UITableViewController {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var selectedItem: String?
    
    var itemArray = [ItemEntry]()

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
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as! CustomCell
        
        let item = itemArray[indexPath.row]
        
        cell.noteLabel?.text = item.name
        
        
        if item.done == false {
            cell.accessoryType = .none
        } else if item.done == true {
            cell.accessoryType = .checkmark
        }
        
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
            itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
            saveItems()
        
    }

   
    @IBAction func addButtonPressed(_ sender: Any) {
        
        var myTextField = UITextField()
        
        let alert = UIAlertController(title: "Add a New Item to \(itemTitle.text!)", message: "", preferredStyle: .alert)
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            myTextField = alertTextField
            
        }
        
        let alertAddAction = UIAlertAction(title: "Add", style: .default) { (UIAlertAction) in
            
            
            
            let newItem = ItemEntry(context: self.context)
            
            if myTextField.text != "" {
                
                
                newItem.name = myTextField.text!
                newItem.completed = false
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
        
    func saveItems() {
        
        do {
            try context.save()
        } catch {
            print(error)
        }
        
        tableView.reloadData()
        
    }
    
    func loadItems(with request: NSFetchRequest<ItemEntry> = ItemEntry.fetchRequest()) {
        
        
        do {
            itemArray = try context.fetch(request)
        } catch {
            print(error)
        }
        
        tableView.reloadData()
    }
    

}
