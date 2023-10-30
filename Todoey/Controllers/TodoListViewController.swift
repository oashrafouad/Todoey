//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController {
    
    var itemArray = [Item]()
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        loadItems()
//        searchBar.delegate = self
    }

    //MARK: - UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)
        let item = itemArray[indexPath.row]
        cell.textLabel?.text = item.title
        
        // Check whether to place checkmark or not when drawing each cell
        cell.accessoryType = item.done ? .checkmark : .none
        
        return cell
    }
    
    //MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Toggle between checking and unchecking a cell
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        saveItems()
        
//        tableView.reloadData()
        // Not needed as reloadData deselects all rows
//        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // Swipe to delete action
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { action, view, completionHandler in
            let alert = UIAlertController(title: "Delete Item", message: "Are you sure you want to delete this item?", preferredStyle: .alert)
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive)
            { _ in
                self.context.delete(self.itemArray[indexPath.row])
                self.itemArray.remove(at: indexPath.row)
                self.saveItems()
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            alert.addAction(deleteAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true)
            completionHandler(true)
        }
        deleteAction.image = UIImage(systemName: "trash")
        
        let actions = UISwipeActionsConfiguration(actions: [deleteAction])
        return actions
    }

    //MARK: - Add new items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        // Change the color of alert controller according to dark mode or light mode
        alert.view.tintColor = traitCollection.userInterfaceStyle == .dark ? .white : .black

        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Create new item"
        }

        let addAction = UIAlertAction(title: "Add Item", style: .default) { action in
            let textField = alert.textFields![0]
            let item = Item(context: self.context)
            item.title = textField.text!
            self.itemArray.append(item)
            self.saveItems()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    func saveItems()
    {
        do
        {
            try context.save()
        }
        catch
        {
            print("Error saving context: \(error)")
        }
        self.tableView.reloadData()
    }
    
    func loadItems()
    {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        do
        {
            itemArray = try context.fetch(request)
        }
        catch
        {
            print("Error reading data from context: \(error)")
        }
    }
}

extension TodoListViewController: UISearchBarDelegate
{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        request.predicate = predicate
        
        
//        let result = fetchItemsFromContext(request: request)
        do
        {
            let result = try context.fetch(request)
//            print(result)
            itemArray = result
            
            tableView.reloadData()

        }
        catch
        {
            print(error)
        }
    }
    
    func fetchItemsFromContext(request: NSFetchRequest<Item>) -> [Item]
    {
        var items: [Item] = []
        
        do
        {
            items = try context.fetch(request)
        
        }
        catch
        {
            print("Error reading data from context: \(error)")
        }
        
        return items
    }
    
//    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
//        let request: NSFetchRequest<Item> = Item.fetchRequest()
//        do
//        {
//            print("cancelled")
//            let result = try context.fetch(request)
//            itemArray = result
//            tableView.reloadData()
//            searchBar.endEditing(true)
//
//        }
//        catch
//        {
//            print(error)
//        }
//    }
//    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
//        print("ended")
//    }
}
