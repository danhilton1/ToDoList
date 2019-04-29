//
//  ViewController.swift
//  ToDoList
//
//  Created by Daniel Hilton on 30/03/2019.
//  Copyright © 2019 Daniel Hilton. All rights reserved.
//

import UIKit
import CoreData
import RealmSwift

class ToDoListViewController: UITableViewController {
    
    let realm = try! Realm()
    
//    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var categories: Results<Category>?
    
//    var itemTitleArray = [String]()
    var categoryTitle = ""

    @IBOutlet weak var editButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setToolbarHidden(true, animated: false)
        
        tableView.register(UINib(nibName: "CustomCell", bundle: nil), forCellReuseIdentifier: "customCell")
        
//        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))

        loadItems()
        
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.setToolbarHidden(true, animated: false)
    }
    
    //MARK: - Tableview Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as! CustomCell
        
        let category = categories?[indexPath.row] ?? Category()
        
        cell.noteLabel?.text = category.title
//        itemTitleArray.append(cell.noteLabel.text!)
        cell.dateLabel.text = category.date
        
        if category.done == false {
            cell.accessoryType = .none
        } else if category.done == true {
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
            
            deleteRowAtIndexPath(indexPath: indexPath)

        }
    }
    
    private func deleteRowAtIndexPath(indexPath: IndexPath) {
        
        if let category = categories?[indexPath.row] {
        do {
            try realm.write() {
                realm.delete(category)
            }
            tableView.deleteRows(at: [indexPath as IndexPath], with: .fade)
        } catch {
            print("Could not delete item - \(error)")
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
            if let indexPath = tableView.indexPathForSelectedRow {
                destVC.selectedCategory = categories?[indexPath.row]
            }
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
//        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
//
//        saveItems()
        
    
        
        let cell = tableView.cellForRow(at: indexPath) as! CustomCell
//        print(cell.noteLabel.text!)

        categoryTitle = cell.noteLabel.text!
        
        

        if isEditing == false {
            performSegue(withIdentifier: "goToItem", sender: categoryTitle)
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
            
            
            
            let newCategory = Category()
            
            if myTextField.text != "" {
                
                let date = Date()
                let formatter = DateFormatter()
                formatter.dateFormat = "dd.MM.yyyy"
                
                newCategory.title = myTextField.text!
                newCategory.date = formatter.string(from: date)
                newCategory.done = false
                
                
                self.save(category: newCategory)
                
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
            
            var titleArray = [String]()
            for title in 0...categories!.count - 1 {
                titleArray.append((categories?[title].title)!)
            }
            // 1
            var items = [String]()
            for indexPath in selectedRows  {
                items.append(categories?[indexPath.row].title ?? "")
                
            }
            // 2
//            print(categories!)
//            print(items[0])
            for item in items {
                if let index = titleArray.firstIndex(of: item) {
                    do {
                        
                        try realm.write {
                            realm.delete(categories![index])
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
    
    func save(category: Category) {
        
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print(error)
        }
        
        tableView.reloadData()
        
    }
    
    func loadItems() {

        categories = realm.objects(Category.self)
       
        
        tableView.reloadData()
    }
    

}

extension ToDoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
//        let request: NSFetchRequest<Category> = Category.fetchRequest()
//        request.predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
//
//        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
//
//        loadItems(with: request)
//
//        searchBar.resignFirstResponder()
        
        
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
//        if searchText != "" {
//            let request: NSFetchRequest<Category> = Category.fetchRequest()
//            request.predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchText)
//        
//            request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
//        
//            loadItems(with: request)
//            
//        } else {
//            loadItems()
//        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.text = ""
        searchBar.resignFirstResponder()
        loadItems()
        tableView.reloadData()
        
        
    }
    
}

