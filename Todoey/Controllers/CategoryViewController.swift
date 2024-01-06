//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Omar Ashraf on 31/10/2023.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: UITableViewController {
    
    let realm = try! Realm()
    var categories: Results<Category>!
    
//    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        print(dataFilePath)
        loadCategories()
        
        tableView.rowHeight = 60
        tableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Clear the background color of navigation bar
        navigationController?.navigationBar.backgroundColor = .none
        navigationController?.navigationBar.tintColor = .label
        navigationController?.navigationBar.largeTitleTextAttributes = [.foregroundColor: UIColor.label]

    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        let category = categories[indexPath.row]
        let categoryColor = UIColor(hexString: category.color)
        
        cell.textLabel?.text = category.name
        cell.backgroundColor = categoryColor
        let contrastCategoryColor = ContrastColorOf(categoryColor!, returnFlat: true)
        cell.textLabel?.textColor = contrastCategoryColor
        cell.tintColor = contrastCategoryColor
        
        return cell
    }
    
    //MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO: perform segue to items in this category
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        let indexPath = tableView.indexPathForSelectedRow
        
        destinationVC.selectedCategory = categories[indexPath!.row]
    }
    
    // Swipe to delete action
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { action, view, completionHandler in
            let alert = UIAlertController(title: "Delete Category", message: "Are you sure you want to delete this category and all items inside of it?", preferredStyle: .alert)
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive)
            { _ in
                do
                {
                    try self.realm.write {
                        // Check if category has any items
                        let category = self.categories[indexPath.row]
                        if !category.items.isEmpty
                        {
                            // Delete all items in category
                            self.realm.delete(category.items)
                        }
                        // Delete category
                        self.realm.delete(category)
                    }
                    tableView.reloadData()
                }
                catch
                {
                    print("Error deleting category: \(error)")
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
    
    func saveCategory(category: Category)
    {
        do
        {
            try realm.write {
                realm.add(category)
            }
        }
        catch
        {
            print("Error saving category: \(error)")
        }
        tableView.reloadData()
    }
    
    func loadCategories()
    {
        
        categories = realm.objects(Category.self)
        
        tableView.reloadData()
        
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "Add New Todoey Category", message: "", preferredStyle: .alert)
        
        // Change the color of alert controller according to dark mode or light mode
        alert.view.tintColor = traitCollection.userInterfaceStyle == .dark ? .white : .black
        
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Create new category"
        }
        
        let addAction = UIAlertAction(title: "Add Category", style: .default) { action in
            let textField = alert.textFields![0]
            
            let newCategory = Category()
            newCategory.name = textField.text!
            newCategory.color = UIColor.randomFlat().hexValue()
            
            self.saveCategory(category: newCategory)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
}
