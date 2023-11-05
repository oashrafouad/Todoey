//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Omar Ashraf on 31/10/2023.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {
    
    //    let categories: [Item] = [Item()]
    var categoryArray: [`Category`] = [`Category`]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(dataFilePath)
        loadCategories()
        
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        let category = categoryArray[indexPath.row]
        cell.textLabel?.text = category.name
        
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
        
        destinationVC.selectedCategory = categoryArray[indexPath!.row]
    }
    
    // Swipe to delete action
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { action, view, completionHandler in
            let alert = UIAlertController(title: "Delete Category", message: "Are you sure you want to delete this category?", preferredStyle: .alert)
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive)
            { _ in
                self.context.delete(self.categoryArray[indexPath.row])
                self.categoryArray.remove(at: indexPath.row)
                self.saveCategories()
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
    
    func saveCategories()
    {
        do
        {
            try context.save()
        }
        catch
        {
            print("Error saving context: \(error)")
        }
        tableView.reloadData()
    }
    
    func loadCategories()
    {
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        do
        {
            categoryArray = try context.fetch(request)
        }
        catch
        {
            print("Error reading data from context: \(error)")
        }
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
            let category = Category(context: self.context)
            category.name = textField.text!
            self.categoryArray.append(category)
            self.saveCategories()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
}

