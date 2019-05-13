//
//  ViewController.swift
//  ToDoList
//
//  Created by Daniel Hilton on 30/03/2019.
//  Copyright © 2019 Daniel Hilton. All rights reserved.
//

import UIKit
import RealmSwift

class ToDoListViewController: UITableViewController {
    
    let realm = try! Realm()
    
    
    var categories: Results<Category>?
    var categoryTitle = ""

    @IBOutlet weak var editButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationController?.setToolbarHidden(true, animated: false)
        
        tableView.register(UINib(nibName: "CustomCell", bundle: nil), forCellReuseIdentifier: "customCell")
        
//        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))

        loadItems()
        
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
//        self.navigationItem.largeTitleDisplayMode = .always
//        self.navigationController?.navigationBar.prefersLargeTitles = true
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
        cell.dateLabel.text = category.date
        
        if category.done == false {
            cell.accessoryType = .none
        } else if category.done == true {
            cell.accessoryType = .checkmark
        }
       
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.view.frame.size.height * 0.08
    }
    
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, complete) in
            self.deleteRowAtIndexPath(indexPath: indexPath)
            complete(true)
        }
        deleteAction.image = UIImage(named: "delete-icon")
        
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
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
        
        let cell = tableView.cellForRow(at: indexPath) as! CustomCell

        categoryTitle = cell.noteLabel.text!
        
        if isEditing == false {
            performSegue(withIdentifier: "goToItem", sender: categoryTitle)
            tableView.deselectRow(at: indexPath, animated: true)
        }
        

    }
    
    
    //MARK: - Button Methods

    @IBAction func newItemPressed(_ sender: Any) {
        
        var myTextField = UITextField()
        
        let alert = UIAlertController(title: "Add a New Item to ToDoList", message: "", preferredStyle: .alert)
       
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            myTextField = alertTextField
            myTextField.autocapitalizationType = .sentences
            
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
    
    
    //MARK: - Save and Load Data Methods
    
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

//MARK: - Search Bar Extension

extension ToDoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        categories = categories?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "title", ascending: false)
        
        tableView.reloadData()

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
            
            categories = categories?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "title", ascending: false)
            
            tableView.reloadData()
         
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

