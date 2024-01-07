//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: UITableViewController {
    let realm = try! Realm()
    var todoItems: Results<Item>!
    var selectedCategory: Category?
    {
        didSet
        {
            loadItems()
        }
    }
    var categoryColor = UIColor()
    
//    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        searchBar.delegate = self
        
        tableView.rowHeight = 60
        tableView.separatorStyle = .none
        
        categoryColor = UIColor(hexString: selectedCategory!.color)!

    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        title = selectedCategory!.name
        
        // Change title color
        navigationController?.navigationBar.largeTitleTextAttributes = [.foregroundColor: categoryColor]
        
        navigationController?.navigationBar.tintColor = categoryColor
        
        addButton.tintColor = categoryColor
    }

    //MARK: - UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)
        let item = todoItems[indexPath.row]
        
        cell.textLabel?.text = item.title
        
        let categoryColor = UIColor(hexString: selectedCategory!.color)
        let itemColor = categoryColor!.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(todoItems.count))
        cell.backgroundColor = itemColor
        
        let contrastItemColor = ContrastColorOf(itemColor!, returnFlat: true)
        cell.textLabel?.textColor = contrastItemColor
        cell.tintColor = contrastItemColor

        // Check whether to place checkmark or not when drawing each cell
        cell.accessoryType = item.done ? .checkmark : .none
        
        return cell
    }
    
    //MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Toggle between checking and unchecking a cell

        if let item = todoItems?[indexPath.row]
        {
            do {
                try realm.write {
                    item.done = !item.done
                }
            } catch {
                print("Error saving done status: \(error)")
            }
        }
        tableView.reloadData()
    }
    
    // Swipe to delete action
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { action, view, completionHandler in
            let alert = UIAlertController(title: "Delete Item", message: "Are you sure you want to delete this item?", preferredStyle: .alert)
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive)
            { _ in
                do
                {
                    try self.realm.write {
                        self.realm.delete(self.todoItems[indexPath.row])
                    }
                    tableView.reloadData()
                }
                catch
                {
                    print("Error deleting item: \(error)")
                }

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
        alert.view.tintColor = categoryColor

        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Create new item"
        }

        let addAction = UIAlertAction(title: "Add Item", style: .default) { action in
            let textField = alert.textFields![0]

            if self.selectedCategory != nil {
                do
                {
                    try self.realm.write {
                        let newItem = Item()
                        newItem.title = textField.text!
                        
                        self.selectedCategory!.items.append(newItem)
                    }
                }
                catch
                {
                    print("Error saving new items: \(error)")
                }
                self.tableView.reloadData()
                
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    func loadItems()
    {
        todoItems = selectedCategory?.items.sorted(byKeyPath: "dateCreated", ascending: true)
        
        tableView.reloadData()
    }
}

extension TodoListViewController: UISearchBarDelegate
{
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)

    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.text = ""
        loadItems()
        DispatchQueue.main.async {
            searchBar.resignFirstResponder()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.isEmpty == true
        {
            loadItems()
        }
        else
        {
            todoItems = todoItems.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "title", ascending: true)
            tableView.reloadData()        }
    }
}
