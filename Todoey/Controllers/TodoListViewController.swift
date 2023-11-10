////
////  ViewController.swift
////  Todoey
////
////  Created by Philipp Muellauer on 02/12/2019.
////  Copyright © 2019 App Brewery. All rights reserved.
////
//
//import UIKit
//import CoreData
//
//class TodoListViewController: UITableViewController {
//    
//    var itemArray = [Item]()
//    var selectedCategory: Category?
//    {
//        didSet
//        {
//            // loadItems()
//        }
//    }
//    
//    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
//    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
//    
//    @IBOutlet weak var searchBar: UISearchBar!
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
////        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
//        searchBar.delegate = self
//    }
//
//    //MARK: - UITableViewDataSource
//    
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return itemArray.count
//    }
//    
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)
//        let item = itemArray[indexPath.row]
//        cell.textLabel?.text = item.title
//        
//        // Check whether to place checkmark or not when drawing each cell
//        cell.accessoryType = item.done ? .checkmark : .none
//        
//        return cell
//    }
//    
//    //MARK: - UITableViewDelegate
//    
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        // Toggle between checking and unchecking a cell
//        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
//        saveItems()
//        
////        tableView.reloadData()
//        // Not needed as reloadData deselects all rows
////        tableView.deselectRow(at: indexPath, animated: true)
//    }
//    
//    // Swipe to delete action
//    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//        
//        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { action, view, completionHandler in
//            let alert = UIAlertController(title: "Delete Item", message: "Are you sure you want to delete this item?", preferredStyle: .alert)
//            let deleteAction = UIAlertAction(title: "Delete", style: .destructive)
//            { _ in
//                self.context.delete(self.itemArray[indexPath.row])
//                self.itemArray.remove(at: indexPath.row)
//                self.saveItems()
//            }
//            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
//            alert.addAction(deleteAction)
//            alert.addAction(cancelAction)
//            self.present(alert, animated: true)
//            completionHandler(true)
//        }
//        deleteAction.image = UIImage(systemName: "trash")
//        
//        let actions = UISwipeActionsConfiguration(actions: [deleteAction])
//        return actions
//    }
//
//    //MARK: - Add new items
//    
////    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
////        
////        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
////        
////        // Change the color of alert controller according to dark mode or light mode
////        alert.view.tintColor = traitCollection.userInterfaceStyle == .dark ? .white : .black
////
////        alert.addTextField { alertTextField in
////            alertTextField.placeholder = "Create new item"
////        }
////
////        let addAction = UIAlertAction(title: "Add Item", style: .default) { action in
////            let textField = alert.textFields![0]
////            let item = Item(context: self.context)
////            item.title = textField.text!
////            item.parentCategory = self.selectedCategory
////            self.itemArray.append(item)
////            self.saveItems()
////        }
////        
////        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
////        
////        alert.addAction(addAction)
////        alert.addAction(cancelAction)
////        present(alert, animated: true)
////    }
//    
//    func saveItems()
//    {
//        do
//        {
//            try context.save()
//        }
//        catch
//        {
//            print("Error saving context: \(error)")
//        }
//        tableView.reloadData()
//    }
//    
////    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil)
////    {
////        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
////        if let additionalPredicate = predicate
////        {
////            let compoundPredicate = NSCompoundPredicate(type: .and, subpredicates: [categoryPredicate, additionalPredicate])
////            request.predicate = compoundPredicate
////        }
////        else
////        {
////            request.predicate = categoryPredicate
////        }
////        do
////        {
////            itemArray = try context.fetch(request)
////        }
////        catch
////        {
////            print("Error reading data from context: \(error)")
////        }
////        tableView.reloadData()
////    }
//}
//
//extension TodoListViewController: UISearchBarDelegate
//{
//    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
//        searchBar.setShowsCancelButton(true, animated: true)
//
//    }
//    
//    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
//        searchBar.setShowsCancelButton(false, animated: true)
//        searchBar.text = ""
//        loadItems()
//        DispatchQueue.main.async {
//            searchBar.resignFirstResponder()
//        }
//    }
//    
//    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        searchBar.resignFirstResponder()
//    }
//    
//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        if searchBar.text?.isEmpty == true
//        {
//            loadItems()
//        }
//        else
//        {
//            let request: NSFetchRequest<Item> = Item.fetchRequest()
//            let searchPredicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
//            loadItems(with: request, predicate: searchPredicate)
//        }
//    }
//}
