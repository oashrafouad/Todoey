//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit

class TodoListViewController: UITableViewController {

    var defaults = UserDefaults.standard
    var itemArray: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let array = defaults.array(forKey: "TodoListArray") as? [String]
        {
            itemArray = array
        }
    }

    //MARK: - UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)
        cell.textLabel?.text = itemArray[indexPath.row]
        return cell
    }
    
    //MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        
        // Switch between checking and unchecking a cell
        switch cell?.accessoryType {
        case .checkmark:
            cell?.accessoryType = .none
        default:
            cell?.accessoryType = .checkmark
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
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
            self.itemArray.append(textField.text!)
            self.defaults.set(self.itemArray, forKey: "TodoListArray")
            self.tableView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
        
    }
    
}
